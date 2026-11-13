#!/usr/bin/env python3
"""Regression checks: compact greeting, isolated Fish overrides, Kitty profiles."""
from pathlib import Path
import os
import re
import subprocess
import sys
import json

HOME=Path.home()
ROOT=Path(__file__).resolve().parents[2]
BIN=ROOT/"bin"
def run(cmd, env=None, timeout=12):
    p=subprocess.run(cmd,capture_output=True,text=True,env=env,timeout=timeout)
    return p.returncode,(p.stdout or "")+(p.stderr or "")
for profile in ("imperial","sith","rakatan"):
    env={**os.environ,"STARWARS_TERMINAL_PROFILE":profile}
    code,out=run([sys.executable,str(BIN/"hypr-galactic-greeting")],env)
    assert code==0,(profile,out)
    lines=out.splitlines()
    assert len(lines)==5,(profile,len(lines))
    assert max(len(line) for line in lines)<=76,(profile,max(map(len,lines)))
    assert "BAT " in out and "ARCH LINUX" in out
    assert profile.upper() in lines[0]
    cfg=ROOT/f"config/kitty/galactic-{profile}.conf"
    code,kitty=run(["kitty","-c",str(HOME/".config/kitty/kitty.conf"),"-c",str(cfg),"/usr/bin/true"],env)
    assert code==0 and not re.search(r"(?i)(unknown config|invalid.*config)",kitty),(profile,kitty)
    print(f"PASS: {profile} compact banner and Kitty settings")

themed={**os.environ,"STARWARS_TERMINAL_PROFILE":"sith"}
code,out=run(["fish","-ic","functions --details fish_prompt; functions --details fish_greeting; false; fish_prompt"],themed)
assert code==0 and "galactic_terminal.fish" in out and "EXIT 1" in out,out
print("PASS: themed Fish prompt, greeting, and failure indicator")
plain={k:v for k,v in os.environ.items() if k!="STARWARS_TERMINAL_PROFILE"}
code,out=run(["fish","-c","functions --details fish_prompt; functions --details fish_greeting"],plain)
assert code==0 and "fish_prompt.fish" in out and "fish_greeting.fish" in out,out
assert "galactic_terminal.fish" not in out
print("PASS: ordinary Fish prompt and fastfetch greeting unchanged")
# A plain Kitty window is no longer plain under Imperial hybrid:
# it picks the selected global profile without needing a special launcher.
kitty_env={**plain,"KITTY_WINDOW_ID":"98241"}
code,out=run(["fish","-ic","printf 'PROFILE:%s\\n' $STARWARS_TERMINAL_PROFILE; functions --details fish_prompt"],kitty_env)
assert code==0 and "PROFILE:imperial" in out and "galactic_terminal.fish" in out,out
print("PASS: generic Kitty inherits Imperial greeting and prompt")
# Explicit launchers must override that default when present.
sith_env={**kitty_env,"STARWARS_TERMINAL_PROFILE":"sith"}
code,out=run(["fish","-ic","printf 'PROFILE:%s\\n' $STARWARS_TERMINAL_PROFILE"],sith_env)
assert code==0 and "PROFILE:sith" in out,out
print("PASS: explicit Sith profile takes precedence")
for profile in ("auto","sith","rakatan","imperial"):
    code,out=run([sys.executable,str(BIN/"hypr-galactic-terminal"),profile,"--print"])
    assert code==0 and "--class galactic-" in out and "/usr/bin/fish" in out,(profile,out)
    assert " -C " not in out,(profile,out)
print("PASS: terminal launcher and auto-selection command generation")
