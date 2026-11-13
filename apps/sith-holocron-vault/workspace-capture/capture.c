#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <unistd.h>
#include <turbojpeg.h>
#include <wayland-client.h>
#include "ext-workspace.h"
#include "ext-image-capture-source.h"
#include "ext-image-copy-capture.h"
#include "hyprland-workspace-image-capture-source.h"

static struct wl_shm *shm;
static struct ext_workspace_manager_v1 *workspaces;
static struct hyprland_workspace_image_capture_source_manager_v1 *sources;
static struct ext_image_copy_capture_manager_v1 *capture;
static struct ext_workspace_handle_v1 *target;
static const char *workspace_name;
static uint32_t width, height, format;
static bool supported, constraints, finished, success;
static uint32_t transform;

static void name(void *data, struct ext_workspace_handle_v1 *handle, const char *value) {
    if (strcmp(value, workspace_name) == 0)
        target = handle;
}
static void string_event(void *d, struct ext_workspace_handle_v1 *h, const char *v) {}
static void coordinates(void *d, struct ext_workspace_handle_v1 *h, struct wl_array *a) {}
static void workspace_uint(void *d, struct ext_workspace_handle_v1 *h, uint32_t v) {}
static void removed(void *d, struct ext_workspace_handle_v1 *h) {
    if (target == h)
        target = NULL;
    ext_workspace_handle_v1_destroy(h);
}
static const struct ext_workspace_handle_v1_listener handle_listener = {
    string_event, name, coordinates, workspace_uint, workspace_uint, removed
};
static void workspace(void *d, struct ext_workspace_manager_v1 *m, struct ext_workspace_handle_v1 *h) {
    ext_workspace_handle_v1_add_listener(h, &handle_listener, NULL);
}
static void group(void *d, struct ext_workspace_manager_v1 *m, struct ext_workspace_group_handle_v1 *h) {
    ext_workspace_group_handle_v1_destroy(h);
}
static void manager_event(void *d, struct ext_workspace_manager_v1 *m) {}
static const struct ext_workspace_manager_v1_listener workspace_listener = {
    group, workspace, manager_event, manager_event
};

static void global(void *data, struct wl_registry *registry, uint32_t id, const char *name, uint32_t version) {
    if (!strcmp(name, wl_shm_interface.name))
        shm = wl_registry_bind(registry, id, &wl_shm_interface, 1);
    else if (!strcmp(name, ext_workspace_manager_v1_interface.name)) {
        workspaces = wl_registry_bind(registry, id, &ext_workspace_manager_v1_interface, 1);
        ext_workspace_manager_v1_add_listener(workspaces, &workspace_listener, NULL);
    } else if (!strcmp(name, hyprland_workspace_image_capture_source_manager_v1_interface.name))
        sources = wl_registry_bind(registry, id, &hyprland_workspace_image_capture_source_manager_v1_interface, 1);
    else if (!strcmp(name, ext_image_copy_capture_manager_v1_interface.name))
        capture = wl_registry_bind(registry, id, &ext_image_copy_capture_manager_v1_interface, 1);
}
static void global_remove(void *d, struct wl_registry *r, uint32_t id) {}
static const struct wl_registry_listener registry_listener = {global, global_remove};

static void size(void *d, struct ext_image_copy_capture_session_v1 *s, uint32_t w, uint32_t h) {
    width = w;
    height = h;
}
static void shm_format(void *d, struct ext_image_copy_capture_session_v1 *s, uint32_t value) {
    if (value == WL_SHM_FORMAT_XRGB8888 || value == WL_SHM_FORMAT_ARGB8888) {
        supported = true;
        format = value;
    }
}
static void device(void *d, struct ext_image_copy_capture_session_v1 *s, struct wl_array *a) {}
static void modifiers(void *d, struct ext_image_copy_capture_session_v1 *s, uint32_t f, struct wl_array *a) {}
static void done(void *d, struct ext_image_copy_capture_session_v1 *s) { constraints = true; }
static void stopped(void *d, struct ext_image_copy_capture_session_v1 *s) { finished = true; }
static const struct ext_image_copy_capture_session_v1_listener session_listener = {
    size, shm_format, device, modifiers, done, stopped
};

static void frame_transform(void *d, struct ext_image_copy_capture_frame_v1 *f, uint32_t value) { transform = value; }
static void damage(void *d, struct ext_image_copy_capture_frame_v1 *f, int32_t x, int32_t y, int32_t w, int32_t h) {}
static void timestamp(void *d, struct ext_image_copy_capture_frame_v1 *f, uint32_t hi, uint32_t lo, uint32_t ns) {}
static void ready(void *d, struct ext_image_copy_capture_frame_v1 *f) { finished = success = true; }
static void failed(void *d, struct ext_image_copy_capture_frame_v1 *f, uint32_t reason) { finished = true; }
static const struct ext_image_copy_capture_frame_v1_listener frame_listener = {
    frame_transform, damage, timestamp, ready, failed
};

static bool write_preview(const unsigned char *pixels) {
    const double ratio = width / (double)height;
    const int w = ratio > 440.0 / 300 ? 440 : (int)(300 * ratio);
    const int h = ratio > 440.0 / 300 ? (int)(440 / ratio) : 300;
    if (w < 1 || h < 1)
        return false;
    unsigned char *thumb = malloc(w * h * 4);
    tjhandle jpeg = tjInitCompress();
    unsigned char *encoded = NULL;
    unsigned long bytes = 0;
    bool ok = false;
    if (thumb && jpeg) {
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
                memcpy(thumb + (y * w + x) * 4,
                       pixels + ((y * height / h) * width + x * width / w) * 4, 4);
        if (tjCompress2(jpeg, thumb, w, 0, h, TJPF_BGRX, &encoded, &bytes, TJSAMP_420, 68, 0) == 0)
            ok = fwrite(encoded, 1, bytes, stdout) == bytes;
    }
    if (jpeg)
        tjDestroy(jpeg);
    tjFree(encoded);
    free(thumb);
    return ok;
}

static bool snapshot(struct wl_display *display) {
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    if (wl_display_roundtrip(display) < 0 || !shm || !workspaces || !sources || !capture)
        return false;
    if (wl_display_roundtrip(display) < 0 || !target)
        return false;

    struct ext_image_capture_source_v1 *source =
        hyprland_workspace_image_capture_source_manager_v1_create_source(sources, target, 0);
    struct ext_image_copy_capture_session_v1 *session =
        ext_image_copy_capture_manager_v1_create_session(capture, source, 0);
    ext_image_copy_capture_session_v1_add_listener(session, &session_listener, NULL);
    while (!constraints && !finished && wl_display_dispatch(display) >= 0) {}
    if (finished || !constraints || !supported || !width || !height || width > 8192 || height > 8192)
        return false;

    size_t length = width * height * 4;
    int fd = memfd_create("vault-preview", MFD_CLOEXEC);
    if (fd < 0)
        return false;
    if (ftruncate(fd, length) != 0) {
        close(fd);
        return false;
    }
    unsigned char *pixels = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (pixels == MAP_FAILED) {
        close(fd);
        return false;
    }
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, length);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, width, height, width * 4, format);
    wl_shm_pool_destroy(pool);
    close(fd);

    struct ext_image_copy_capture_frame_v1 *frame = ext_image_copy_capture_session_v1_create_frame(session);
    ext_image_copy_capture_frame_v1_add_listener(frame, &frame_listener, NULL);
    ext_image_copy_capture_frame_v1_attach_buffer(frame, buffer);
    ext_image_copy_capture_frame_v1_damage_buffer(frame, 0, 0, width, height);
    ext_image_copy_capture_frame_v1_capture(frame);
    while (!finished && wl_display_dispatch(display) >= 0) {}
    bool ok = success && transform == WL_OUTPUT_TRANSFORM_NORMAL && write_preview(pixels);
    munmap(pixels, length);
    return ok;
}

int main(int argc, char **argv) {
    if (argc != 2)
        return 1;
    workspace_name = argv[1];
    alarm(2);
    struct wl_display *display = wl_display_connect(NULL);
    if (!display)
        return 1;
    bool ok = snapshot(display);
    wl_display_disconnect(display);
    return ok ? 0 : 1;
}
