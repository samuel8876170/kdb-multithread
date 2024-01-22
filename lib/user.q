.multhr.user.registry: ([handle:`u#"i"$()] username:`$(); role:`$());
.multhr.user.writerList: `$();

.multhr.user.register: {[serverAddr; serverH]
    if[not null .multhr.user.registry[.z.w; `role]; '"User was registered before."];

    userRole: `reader`writer .multhr.user.registry[.z.w; `username] in .multhr.user.writerList;
    token: `$string rand 0Ng;

    serverH ({[role; token] system "p ",string $[`reader~role;neg;::] abs system"p"; .multhr.addToken[token;role]}; userRole; token);
    .multhr.user.registry[.z.w; `role]: userRole;
    .z.w (hopen; `$":" sv string (serverAddr; userRole; token))
    };

.multhr.user.init: {[writerList] .multhr.user.writerList: writerList };

.multhr.user.po: { `.multhr.user.registry upsert (x; .z.u; `) };
.multhr.user.pc: { delete from `.multhr.user.registry where handle=x };

//  main execution list in .z
{@[`.multhr; x; ,; `.multhr.user .Q.dd/: x]} `po`pc;
