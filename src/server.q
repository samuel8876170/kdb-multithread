.multhr.token: ([password:`u#`$()] time:"p"$(); role:`$());
.multhr.addToken: {[password; role] .multhr.token,: (password; .z.P; role) };

.multhr.ts: { delete from `.multhr.token where 00:01:00 < .z.P-time };
.z.ts: { .multhr.ts[] };

.z.pw: {[u;p]
    //  u: `writer or `reader; u should match port (i.e. +ve port for `writer / -ve port for `reader)
    //  p: any .multhr.token`password
    if[u~`admin; :1b];
    if[not (p:`$p) in (key .multhr.token)`password; -1 "password:",(string p)," not in token list."; :0b];
    u ~ `reader`writer 0 < signum system "p"
    };
