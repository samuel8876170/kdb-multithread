/ q main.q -p <port number> -writerList <path to writer list file>.txt

//  Force positive port
$[.multhr.config.port:abs system"p"; system"p ",string .multhr.config.port; '"Port must be set and should not change manually during the process runtime."];

if[not count .multhr.config.env: getenv`QMULTITHREAD; '"Environment variable `QMULTITHREAD is not found."];

system each "l ",/:.multhr.config.env,/:("/lib/txtReader.q"; "/lib/trap.q"; "/lib/user.q"; "/lib/config.q");

.multhr.user.init $[`writerList in key .multhr.config.kwargs; .multhr.config.getWriterList[]; `$()];

.z.ts: .multhr.user.ts;
.z.po: .multhr.user.po;
.z.pc: .multhr.user.pc;
.z.ps: .multhr.user.ps;
.z.pg: .multhr.user.pg;
