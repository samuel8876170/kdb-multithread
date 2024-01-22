.multhr.server.registry: ([addr:`u#`$()] handle:"i"$());

.multhr.server.init: {[addrs] .multhr.server.addServer addrs };
.multhr.server.addServer: {[addrs] if[not count addrs:(),addrs; :(::)]; `.multhr.server.registry upsert addrs,\:0Ni };
.multhr.server.rmServer: {[addrs]
    hclose each exec handle from .multhr.server.registry where addr in addrs, not null handle;
    delete from `.multhr.server.registry where addr in addrs;
    };

.multhr.server.getRegistry: {[addr] if[null h:.multhr.server.registry[addr; `handle]; :(::)]; (addr; h) };

.multhr.server.pc: { delete from `.multhr.server.registry where handle=x };
.multhr.server.ts: {
    hs: exec @[hopen;;0Ni] each (`$(string addr),\:":admin") from `.multhr.server.registry where null handle;
    if[count hs ind:where not null hs; update handle:hs from `.multhr.server.registry where null handle];
    };

//  main execution list in .z
{@[`.multhr; x; ,; `.multhr.server .Q.dd/: x]} `ts`pc;
