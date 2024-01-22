.multhr.token: ([password:`u#`$()] time:"p"$(); role:`$());
.multhr.addToken: {[password; role] .multhr.token,: (password; .z.P; role) };

.multhr.ts: { delete from `.multhr.token where 00:30:00 < .z.P-time };
.z.ts: { .multhr.ts[] };

.z.pw: {[u;p]
    if[u~`admin; :1b];
    if[not (p:`$p) in (key .multhr.token)`password; :0b];
    if[b: u ~ `reader`writer 0 < signum system "p"; delete from `.multhr.token where password=p];
    b
    };
