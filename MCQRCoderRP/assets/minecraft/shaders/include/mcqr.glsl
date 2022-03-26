int i;
int j;
    //set positions
vec2 texsize = textureSize(Sampler0, 0);
vec2 tpos = floor(texCoord0 * texsize / 16.0) * 16.0 + mod(texCoord0 * texsize, 16.0) / 16.0;
vec2 p = mod(texCoord0 * texsize, 16.0) / 16.0;
p.y = 1.0 - p.y;
p = p * 2 - 1;
p *= 1.1;
float f = float(abs(p.x) < 1.0 && abs(p.y) < 1.0);
p = (p + 1.0) / 2.0;
p = ceil(p * fSize);
p += vec2(step(p.x, 0.0), step(p.y, 0.0));
ivec2 pbl = ivec2(p);
ivec2 pul = ivec2(pbl.x, Size - pbl.y + 1);
vec2 fpbr = vec2(fSize + 1.0 - p.x, p.y);
fpbr -= step(fSize - 5.0, fpbr);
ivec2 pbr = ivec2(fpbr);
    //set data number
int c = - 1;
int l = (pbr.x + 1) / 2;
int n = xlen(l, 2, 10, SizeR) + xlen(l, 10, Size - 7, SizeM) + xlen(l, Size - 7, Size - 1, SizeL) + ylen(l, pbr.y) * 2 + (pbr.x + 1) % 2;
n -= int(nlen(2) <= n) * 10 + int(nlen(4) - 2 * 4 * 2 <= n) * 10 + clamp(n - nlen(4) + 2, 0, 2 * 5) / 2;

    //Main data
int nn = 1;
int intemp = 0;
int msg_in[Ct];
    //mode(1,4)
bytes(nn, 4, 4, msg_in, intemp);
    //count(bytecount,8)
vec3 tc = floor(outColor.rgb * 255.1);
float value = tc.r * 65536.0 + tc.g * 256.0 + tc.b;
int digi = 1 + int(log2(value) / log2(10.0)) * int(value != 0.0);
int scount = int(texture(Sampler0, (tpos + vec2(1, 0)) / texsize).r * 255);
int bytecount = 0;
for(i = 0;
i < scount;
i ++) {
ivec3 vs = ivec3(texture(Sampler0, (tpos + vec2(2 + i, 0)) / texsize).rgb * 255);
vs.g = vs.g == 255 ? digi : vs.g;
bytecount += abs(vs.b - vs.g) + vs.r;
}
bytes(nn, bytecount, 8, msg_in, intemp);
    //character data(texdata,bytecount)
for(i = 0;
i < scount;
i ++) {
ivec3 vs = ivec3(texture(Sampler0, (tpos + vec2(2 + i, 0)) / texsize).rgb * 255);
if(vs.r == 0) {
                //characters
for(j = vs.g;
j < vs.b;
j ++) {
bytes(nn, ntov(j, ivec2(0, 1), tpos, texsize, Sampler0), 8, msg_in, intemp);
}
} else {
                //values
vs.g = vs.g == 255 ? digi : vs.g;
if(vs.g < vs.b) vs.g = vs.b;
for(j = vs.g;
vs.b <= j;
j --) {
int vn = int(mod(value, pow(10.0, float(j))) / pow(10.0, float(j - 1)));
bytes(nn, 48 + vn, 8, msg_in, intemp);
}
}
}
    //terminator(0,4)
bytes(nn, 0, 4, msg_in, intemp);
    //bit padding(0,nbit)
int nb = Ct * 8 + 1 - nn;
int nbyte = nb / 8;
int nbit = nb - nbyte * 8;
bytes(nn, 0, nbit, msg_in, intemp);
    //byte padding(0xEC or 0x11,nbyte*8)
for(i = 1;
i <= nbyte;
i ++) {
        //EC,11,EC...
int pad = (i % 2 == 1) ? 0xEC : 0x11;
bytes(nn, pad, 8, msg_in, intemp);
}
    //1 ~ Ct*8

    //Ct*8+1 ~ Ca*8 (Cnsym*8)
if(Ct * 8 <= n) {
    //Reed-Solomon error correction codes
    //generate agen
int agen[gen];
for(i = 0;
i < gen;
i ++) {
agen[i] = ntov(i, ivec2(11, 3), tpos, texsize, Sampler0);
}
    //generate msg_out
int msg_out[Ca / 2];
int np = (n / 8) % 2 == 1 ? Ct / 2 : 0;
for(i = 0;
i < Ct / 2;
i ++) {
msg_out[i] = msg_in[i + np];
}
for(i = Ct / 2;
i < Ca / 2;
i ++) {
msg_out[i] = 0;
}
if(msg_out[49] == 0x06) {
//discard;
}
for(i = 0;
i < Ct / 2;
i ++) {
int coef = msg_out[i];
if(coef != 0) {
for(j = 1;
j < gen;
j ++) {
int x = ntov(agen[j], ivec2(0, 4), tpos, texsize, Sampler0);
int y = ntov(coef, ivec2(0, 4), tpos, texsize, Sampler0);
msg_out[i + j] ^= ntov(x + y, ivec2(0, 8), tpos, texsize, Sampler0);
}
}
}
n = n % 8 + Ct * 8 / 2 + 8 * ((n - Ct * 8) / 8 / 2);
c = n / 8 < Ca / 2 ? setc(n % 8, msg_out[n / 8]) : 0;
} else {
n = n % 8 + 8 * (n / 8 / 2) + (Ct * 8 / 2) * int((n / 8) % 2 == 1);
c = setc(n % 8, msg_in[n / 8]);
}

    //Fixed patterns
    //set mask0
c = int(c == abs(pbl.x % 2 - pbl.y % 2));
    //set format(11101111,11000100->0xEF,0xC4)
ivec2 fds = ivec2(0xEF, 0xC4);
ptoc(pbl, ivec2(9, 1), ivec2(9, 8), fds.x, c);
ptoc(pbl, ivec2(PosE + 1, PosE), ivec2(Size, PosE), fds.y, c);
ptoc(pbl, ivec2(1, PosE), ivec2(8, PosE), fds.x, c);
ptoc(pbl, ivec2(9, PosE), ivec2(9, Size), fds.y, c);
    //set timing
if(any(equal(pul, ivec2(7)))) c = pul.x % 2 * pul.y % 2;
    //set position pattern
corner(pul, ivec2(0), c);
corner(pul, ivec2(PosE, 0), c);
corner(pul, ivec2(0, PosE), c);
sub(pbr, ivec2(5), c);

    //Output
vec3 col = vec3(mix(1.0, float(1 - c), f));
fragColor = vec4(col, 1.0);