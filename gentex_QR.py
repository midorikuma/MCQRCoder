import re
from PIL import Image

text ="Your score is %v(-1)"
filename ="display1.png"

#Referenced sites
#https://www.nayuki.io/page/creating-a-qr-code-step-by-step
#https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders
u=255
#flag4/4(1),sCount(1),vlist(byteType,byteStartPos,byteEndPos)*sCount(<=14)
#flags&vlist(16*1),tlist134/4(16*2+2),gen18/4(5),gf_log256/4(16*4),gf_exp512/4(16*8)
out = Image.new("RGBA", (16, 16), (u,u,u,u))
#convert text
slist = re.split('(%v\(.*?\))', text)
slist = [i for i in slist if i != '']
tlist=[]
vlist=[]
for s in slist:
    fvt = int('%v(' in s)
    if fvt == 0:
        ent = s.encode('utf-8')
        sv = len(tlist)
        ev = sv+len(ent)
        tlist += ent
    else:
        sv = re.search(r'(?<=%v\().*?(?=\-)', s).group()
        ev = re.search(r'(?<=\-).*?(?=\))', s).group()
        sv = 255 if sv == '' else int(sv)
        ev = 1 if ev == '' else int(ev)
    vlist += [fvt, sv, ev, 255]
flags = [12,34,56,78]+[len(slist)]
print(slist)
#print(tlist)
#print(vlist)

#gf_mul
def gf_mul(x,y):
    if x==0 or y==0:
        return 0
    return gf_exp[gf_log[x] + gf_log[y]]

#gf_log,gf_exp
gf_log = [0] * 256
gf_exp = [0] * 512
x = 1
for i in range(0, 255):
    gf_log[x] = i
    gf_exp[i] = x
    y = 2
    r = 0
    while y!=0:
        if y & 1: r ^= x
        y = y >> 1
        x = x << 1
        if 256 <= x: x ^= 0x11d
    x=r
for i in range(255, 512):
    gf_exp[i] = gf_exp[i - 255]

#gen
gen = [1]
for i in range(18):
    p=gen
    q=[1, gf_exp[(gf_log[2] * i) % 255]]
    gen = [0] * (len(p)+2-1)
    for j in range(0, 2):
        for k in range(0, len(p)):
            gen[k+j] ^= gf_mul(p[k], q[j])

#generate tex
def texrgba(array,sx,sy):
    array +=[u,u,u]
    for i in range(0,len(array)):
        ic=i%4
        p[ic]=array[i]
        if ic==3:
            ixy=i/4
            x=sx+int(ixy%16)
            y=sy+int(ixy/16)
            out.putpixel((x,y), tuple(p[0:4]))
texrgba(flags,0,0)
texrgba(vlist,2,0)
texrgba(tlist,0,1)
texrgba(gen,11,3)
texrgba(gf_log,0,4)
texrgba(gf_exp,0,8)

#with open('gf_exp.txt', 'w') as f:
#  print(gf_exp, file=f)
#with open('gf_log.txt', 'w') as f:
#  print(gf_log, file=f)
#print(gen)

out.save(filename)