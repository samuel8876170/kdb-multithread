/ q client.q -p <port number> -t <timer> -writerList <path to writer list file>.txt -serverList <path to server list file>.txt

//  Force positive port
$[.multhr.config.port:abs system"p"; system"p ",string .multhr.config.port; '"Port must be set and should not change manually during the process runtime."];

if[not count .multhr.config.env: getenv`QMULTITHREAD; '"Environment variable `QMULTITHREAD is not found."];
.multhr[`ts`po`pc`ps`pg]: 5#();

system each "l ",/:.multhr.config.env,/:("/lib/txtReader.q"; "/lib/trap.q"; "/lib/user.q"; "/lib/config.q"; "/lib/server.q");

.multhr.user.init $[`writerList in key .multhr.config.kwargs; .multhr.config.getWriterList[]; `$()];
.multhr.server.init $[`serverList in key .multhr.config.kwargs; .multhr.config.getServerList[]; `$()];

.multhr.register: {[addr]
    if[null first addrHandle: .multhr.server.getRegistry addr; '"Failed to connect to address due to server not exist: ",string addr];
    .multhr.user.register . addrHandle
    };

.z.ts: { .multhr.ts@\:(::) };
.z.po: { .multhr.po@\:x };
.z.pc: { .multhr.pc@\:x };
.z.ps: { .multhr.ps@\:x; value x };
.z.pg: { .multhr.pg@\:x; value x };
