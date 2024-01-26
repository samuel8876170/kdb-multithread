.multhr.config.kwargs: .Q.opt .z.x;

.multhr.config.getTextConfigFileFromArg: {[k]
    if[not k in key .multhr.config.kwargs; '"Arg not exists: ",string k];
    res:.multhr.trap.trapFunc[.multhr.txtReader.read; enlist path:.multhr.config.kwargs k];
    if[res 0; :res 1];
    res:.multhr.trap.trapFunc[.multhr.txtReader.read; enlist (getenv`QMULTITHREAD), $["/"~first path;"";"/"], path];
    $[res 0; res 1; 'res 1]
    };

.multhr.config.getWriterList: { .multhr.config.getTextConfigFileFromArg`writerList };
.multhr.config.getServerList: { .multhr.config.getTextConfigFileFromArg`serverList };
