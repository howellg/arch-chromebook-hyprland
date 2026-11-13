#!/usr/bin/env python3
"""Original cinematic Star Wars-inspired wallpapers (Episodes I-VI / Legends motifs)."""
from pathlib import Path
from math import sin,cos,pi
import random,subprocess,sys

ROOT=Path(__file__).resolve().parent
OUT=Path.home()/".local/share/starwars-theme/wallpapers"
OUT.mkdir(parents=True,exist_ok=True)
W,H=1920,1200
SCENES={
 "imperial":("#080e18","#18243a","#ea6260","#92a3b8","IMPERIAL COMMAND","SECTOR ONE • CORUSCANT"),
 "databank":("#11121a","#292523","#d6af6a","#95abb8","IMPERIAL DATABANK","RECORDS • SECURE ACCESS"),
 "comms":("#0b1524","#223146","#8ab9d2","#d3a47b","FLEET COMMUNICATIONS","HOLO-NET • ONLINE"),
}
def shape(seed):
    rng=random.Random(seed)
    return "\n".join(f'<circle cx="{rng.randrange(W)}" cy="{rng.randrange(H)}" r="{rng.choice([.6,.7,1,1.3,2])}" fill="#afc6d9" opacity="{rng.uniform(.17,.71):.2f}"/>' for _ in range(170))
def svg(name,palette):
    bg,deep,accent,secondary,title,subtitle=palette
    grid="\n".join([f'<path d="M {i} 0 V {H}" stroke="{accent}" opacity=".06"/>' for i in range(0,W+1,80)]+[f'<path d="M 0 {i} H {W}" stroke="{accent}" opacity=".06"/>' for i in range(0,H+1,80)])
    ring="".join(f'<circle cx="1510" cy="530" r="{r}" stroke="{accent}" stroke-width="{w}" fill="none" opacity="{o}"/>' for r,w,o in [(370,2,.19),(330,1,.25),(281,2,.35),(253,8,.11),(215,2,.55),(167,1,.23)])
    spokes="".join(f'<path d="M {1510+225*cos(n*pi/6):.1f} {530+225*sin(n*pi/6):.1f} L {1510+280*cos(n*pi/6):.1f} {530+280*sin(n*pi/6):.1f}" stroke="{accent}" stroke-width="4" opacity=".45"/>' for n in range(12))
    imperial=f'<g transform="translate(1510 530)" fill="none" stroke="{accent}" stroke-width="18" opacity=".8"><circle r="116"/><circle r="60"/>'+''.join(f'<path d="M {60*cos(k*pi/3):.1f} {60*sin(k*pi/3):.1f} L {113*cos(k*pi/3):.1f} {113*sin(k*pi/3):.1f}"/>' for k in range(6))+'</g>'
    sith=f'<g transform="translate(1510 530)" fill="none" stroke="{accent}" stroke-width="8"><path d="M 0 -172 L 148 85 L 0 157 L -148 85 Z" opacity=".8"/><path d="M 0 -172 V 157 M -148 85 L 148 85 M -85 -63 L 0 11 L 85 -63 M -85 85 L 0 11 L 85 85" opacity=".7"/></g>'
    rakatan=f'<g transform="translate(1510 530)" fill="none" stroke="{accent}" stroke-width="6"><path d="M -140 -110 L 15 -180 L 155 -25 L 90 145 L -75 150 L -155 5 Z" opacity=".8"/><path d="M -140 -110 L 90 145 L 155 -25 L -75 150 L 15 -180 L -155 5 L -140 -110"/><circle r="29" fill="{accent}" opacity=".42"/></g>'
    symbol = rakatan if name=="rakatan" else sith if name=="sith" else imperial
    horizon=f'<path d="M 0 995 C 365 920 550 982 750 915 S 1130 925 {W} 810 L {W} {H} L 0 {H} Z" fill="#030609" opacity=".42"/>'
    bars="".join(f'<rect x="{70+i*30}" y="1080" width="19" height="{22+8*(i%4)}" fill="{accent}" opacity="{.15+i*.011:.2f}"/>' for i in range(27))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
<defs><linearGradient id="bg" x2=".95" y2="1"><stop stop-color="{bg}"/><stop offset="1" stop-color="{deep}"/></linearGradient>
<radialGradient id="halo"><stop stop-color="{accent}" stop-opacity=".23"/><stop offset="1" stop-color="{accent}" stop-opacity="0"/></radialGradient>
<linearGradient id="beam"><stop stop-color="{accent}" stop-opacity="0"/><stop offset=".5" stop-color="{accent}" stop-opacity=".14"/><stop offset="1" stop-color="{accent}" stop-opacity="0"/></linearGradient></defs>
<rect width="{W}" height="{H}" fill="url(#bg)"/>{shape(name)}
<circle cx="1495" cy="535" r="670" fill="url(#halo)"/><g>{grid}</g>
<path d="M 800 0 L 1630 1200 L 1425 1200 L 730 0 Z" fill="url(#beam)"/>
<path d="M 1060 0 L 1400 1200" stroke="{accent}" opacity=".09" stroke-width="3"/>
{ring}{spokes}{symbol}
{horizon}
<g fill="none" stroke="{accent}" opacity=".48" stroke-width="3"><path d="M 75 235 V 125 H 205"/><path d="M 75 675 V 780 H 205"/><path d="M 1848 155 H 1788 V 220"/><path d="M 1848 790 H 1788 V 715"/></g>
<g font-family="DejaVu Sans, sans-serif" fill="{secondary}"><text x="145" y="170" font-size="22" letter-spacing="7" opacity=".85">GALACTIC SYSTEM INTERFACE</text>
<text x="145" y="450" font-size="63" font-weight="bold" letter-spacing="4" fill="#eef0ef">{title}</text>
<text x="150" y="502" font-size="21" letter-spacing="5" fill="{accent}">{subtitle}</text>
<text x="150" y="574" font-size="19" opacity=".7">ARCHIVES  /  NAVIGATION  /  OPERATIONS</text>
<text x="150" y="1132" font-size="19" letter-spacing="3" opacity=".8">SYSTEM STATUS: OPERATIONAL</text>
<text x="1460" y="1132" font-size="16" letter-spacing="3" fill="{accent}">SECURE TERMINAL</text></g>
<g fill="{accent}" opacity=".48"><rect x="150" y="625" width="440" height="3"/>{bars}</g></svg>'''
def main():
    for name in (*SCENES, "sith", "bridge", "rakatan"):
        source=ROOT/(name+".svg")
        if name in SCENES:
            source.write_text(svg(name, SCENES[name]))
        dest=OUT/(name+".png")
        subprocess.run(["rsvg-convert","--width",str(W),"--height",str(H),"--output",str(dest),str(source)],check=True)
        print(name,dest)
if __name__=="__main__":main()
