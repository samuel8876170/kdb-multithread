.multhr.user.registry: ([handle:`u#"i"$()] username:`$(); role:`$());
.multhr.user.writerList: `$();

.multhr.user.register: {[]
    if[not null .multhr.user.registry[.z.w; `role]; '"User was registered before."];

    userRole: `reader`writer .multhr.user.registry[.z.w; `username] in .multhr.user.writerList;
    system "p ",string $[`reader~userRole;neg;] port:abs system"p";
    h: .z.w (hopen; `$":" sv string (`; .Q.host .z.a; port; .multhr.user.registry[.z.w; `username]; `bypass));

    .multhr.user.registry[.z.w (h; ".z.w"); `role]: userRole;
    delete from `.multhr.user.registry where handle=.z.w;
    h
    };

.multhr.user.init: {[writerList] .multhr.user.writerList: writerList };

.multhr.user.ts: { if[count hs:(key .z.W) except exec handle from .multhr.user.registry; hclose each hs] };
.multhr.user.po: { `.multhr.user.registry upsert (.z.w; .z.u; `) };
.multhr.user.pc: { delete from `.multhr.user.registry where handle=x };
.multhr.user.ps: .multhr.user.pg: {
    if[10h~type x; x: parse x];
    if[not all (null .multhr.user.registry[.z.w;`role]; 2~count x; `.multhr.user.register~first x); '"Unregistered user is not allowed to run any command. Execute `.multhr.user.register to register."];
    value x
    };
