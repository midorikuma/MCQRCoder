//Referenced sites
//https://www.nayuki.io/page/creating-a-qr-code-step-by-step
//https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders
//QR code version6L mask0

//sizes
const int Size = 41;
const float fSize = float(Size);
const int SizeR = Size - 8 - 1;
const int SizeM = Size - 1;
const int SizeL = Size - 8 * 2 - 1;
const int PosE = Size - 8;

//number of arrays
const int Ct = 68 * 2;
const int Cnsym = 18 * 2;
const int Ca = Ct + Cnsym;
const int gen = Cnsym / 2 + 1;

//converter n,v->c
int setc(int n, int v) {
    int nd = 1 << (8 - n);
    return (nd <= v * 2) ? v % nd * 2 / nd : 0;
}

//set position pattern
void sq(ivec2 p, ivec2 ss, ivec2 se, int v, inout int c) {
    if(all(lessThanEqual(ss, p)) && all(lessThanEqual(p, se)))
        c = v;
}
void corner(ivec2 p, ivec2 s, inout int c) {
    p -= s;
    s = sign(s);
    sq(p, ivec2(1), ivec2(8), 0, c);
    sq(p, 1 + s, 7 + s, 1, c);
    sq(p, 2 + s, 6 + s, 0, c);
    sq(p, 3 + s, 5 + s, 1, c);
}
void sub(ivec2 p, ivec2 s, inout int c) {
    p -= s;
    sq(p, ivec2(0), ivec2(4), 1, c);
    sq(p, ivec2(1), ivec2(3), 0, c);
    c = p == ivec2(2) ? 1 : c;
}
//set zigzag data number
int xlen(int l, int s, int e, int si) {
    return (clamp(l, s / 2, e / 2) - s / 2) * si * 2;
}
int ylen(int l, int py) {
    ivec2 se;
    if(l <= 8 / 2) {
        se = ivec2(1, SizeR);
    } else if(l <= (Size - 8 - 1) / 2) {
        se = ivec2(1, SizeM);
    } else {
        se = ivec2(9, SizeL);
    }
    py -= se.x;
    return (l % 2 == 1) ? py : se.y - 1 - py;
}
int nlen(int sl) {
    return (Size - 9) * sl * 2 + 2 * 4;
}
//data storage msg_in
void bytes(inout int nn, int v, int d, inout int msg_in[Ct], inout int intemp) {
    for(int i = d; 0 < i; i--) {
        int nt = 7 - (nn - 1) % 8;
        intemp += (1 << nt) * setc(8 - i, v);
        if(nt <= 0) {
            msg_in[(nn - 1) / 8] = intemp;
            intemp = 0;
        }
        nn += 1;
    }
}
//conversion from p to c (format information)
void ptoc(ivec2 p, ivec2 ss, ivec2 se, int fd, inout int c) {
    if(all(lessThanEqual(ss, p)) && all(lessThanEqual(p, se))) {
        ivec2 ps = p - ss;
        int pn = ps.x + ps.y * (se.x - ss.x + 1) - int(Size - 6 < p.y);
        c = setc(pn, fd);
    }
}
//conversion from n to v (tex data)
int ntov(int n, ivec2 p, vec2 tpos, vec2 texsize, sampler2D Sampler0) {
    int pn = n / 4;
    vec4 v = texture(Sampler0, (tpos + vec2(ivec2(p.x + pn % 16, p.y + pn / 16))) / texsize);
    return int(v[n % 4] * 255);
}
//detect flag
bool flag(vec2 texCoord0, sampler2D Sampler0) {
    vec2 texsize = textureSize(Sampler0, 0);
    vec2 tpos = floor(texCoord0 * texsize / 16.0) * 16.0 + mod(texCoord0 * texsize, 16.0) / 16.0;
    return vec4(12, 34, 56, 78) == texture(Sampler0, (tpos + vec2(0, 0)) / texsize) * 255;
}