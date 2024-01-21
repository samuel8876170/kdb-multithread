.multhr.config.kwargs: .Q.opt .z.x;

.multhr.config.getWriterList: {[]
    res:.multhr.trap.trapFunc[.multhr.txtReader.read; enlist path:.multhr.config.kwargs`writerList];
    if[res 0; :res 1];
    res:.multhr.trap.trapFunc[.multhr.txtReader.read; enlist (getenv`QMULTITHREAD), $["/"~first path;"";"/"], path];
    $[res 0; res 1; 'res 1]
    };
