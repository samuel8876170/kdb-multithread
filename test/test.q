.multhrTest.beforeNamespace: {
    //  load config and environment variables
    if[not count .multhrTest.config.srcEnv: hsym`$getenv`QMULTITHREAD; '"Environment variable `QMULTITHREAD is not found."];
    if[not count .multhrTest.config.testEnv: hsym`$getenv`QMULTITHREAD_TEST; '"Environment variable `QMULTITHREAD_TEST is not found."];
    .multhrTest.config.writerListPath: 1_string` sv (.multhrTest.config.testEnv; `$"config/writerList.txt");
    .multhrTest.config.serverListPath: 1_string` sv (.multhrTest.config.testEnv; `$"config/serverList.txt");
    
    .multhrTest.config.serverPort: 16090;
    .multhrTest.config.allocatorPort: 5050;

    .multhrTest.command.server: "q ",(1_string .Q.dd[.multhrTest.config.srcEnv; `server.q])," -p ",(string .multhrTest.config.serverPort)," -t 3000";
    .multhrTest.command.allocator: "q ",(1_string .Q.dd[.multhrTest.config.srcEnv; `allocator.q])," -p ",(string .multhrTest.config.allocatorPort)," -t 3000 -writerList ",.multhrTest.config.writerListPath," -serverList ",.multhrTest.config.serverListPath;
    };

.multhrTest.setUp: {
    //  start server and allocator by system
    system .multhrTest.command.server; .qunit.wait 00:00:01;
    hopen `$"::",(string .multhrTest.config.serverPort),":admin";

    system .multhrTest.command.allocator; .qunit.wait 00:00:01;
    hopen `$"::",(string .multhrTest.config.allocatorPort),":tester";
    };

.multhrTest.testWriterAndReaderConnection: {
    //  spawn a writer process
    system "q -p 10510"; .qunit.wait 00:00:01;
    h: hopen `::10510:tester;
    res: h ({ h: hopen x; @[h; (`.multhr.register; y); {x}] }; 
        `$"::",(string .multhrTest.config.allocatorPort),":writer1";
        `$":localhost:",string .multhrTest.config.serverPort
        );
    .qunit.assertTrue[0Ni <> res; "Test process able to connect to server as writer"];
    
    //  spawn a reader process
    system "q -p 10511"; .qunit.wait 00:00:01;
    h: hopen `::10511:tester;
    res: h ({ h: hopen x; @[h; (`.multhr.register; y); 0Ni] }; 
        `$"::",(string .multhrTest.config.allocatorPort),":reader1"; 
        `$":localhost:",string .multhrTest.config.serverPort
        );
    .qunit.assertTrue[0Ni <> res; "Test process able to connect to server as reader"];
    };

.multhrTest.testWriterAndReaderPermission: {
    //  spawn a writer process
    system "q -p 10510"; .qunit.wait 00:00:01;
    h: hopen `::10510:tester;
    res: h ({ h: hopen x; serverH: @[h; (`.multhr.register; y); 0Ni]; @[serverH; "a:2; a"; {x}] }; 
        `$"::",(string .multhrTest.config.allocatorPort),":writer1"; 
        `$":localhost:",string .multhrTest.config.serverPort
        );
    .qunit.assertEquals[2; res; "Test process able to write on server as writer"];

    //  spawn a reader process
    system "q -p 10511"; .qunit.wait 00:00:01;
    h: hopen `::10511:tester;
    res: h ({ h: hopen x; serverH: @[h; (`.multhr.register; y); 0Ni]; @[serverH; "a:2; a"; {x}] };
        `$"::",(string .multhrTest.config.allocatorPort),":reader1"; 
        `$":localhost:",string .multhrTest.config.serverPort
        );
    .qunit.assertTrue[res like "noupdate*"; "Test process unable to write on server as reader"];
    };

.multhrTest.testMulthrFasterThanNormal: {
    //  Group A:
    //  spawn a writer process
    system "q -p 10510"; .qunit.wait 00:00:01;
    h: hopen `::10510:tester;
    h ({ h: hopen x; `serverH set @[h; (`.multhr.register; y); 0Ni] };
        `$"::",(string .multhrTest.config.allocatorPort),":writer1";
        `$":localhost:",string .multhrTest.config.serverPort
        );
    h ".z.ts:{serverH (set; `zp; .z.P)}; system\"t 100\"";

    //  spawn reader processes
    system each "q -p ",/:string ps:10511 + til 30; .qunit.wait 00:00:01*count ps;
    hs: hopen each ps;
    hs@\:({ h: hopen x; `serverH set @[h; (`.multhr.register; y); 0Ni] };
        `$"::",(string .multhrTest.config.allocatorPort),":reader1";
        `$":localhost:",string .multhrTest.config.serverPort
        );

    .qunit.wait 00:00:10;
    -25!(hs; "timeUsed: first first .Q.ts[{do[x; y z]}; (100000; serverH; `zp)]");
    timeUsed1: hs@\:"timeUsed";
    @[;"exit 0";{}]each hs;

    //  Group B:
    //  spawn a normal server
    system "q -p 11509"; .qunit.wait 00:00:01;
    hopen 11509;

    //  spawn another writer process
    system "q -p 11510"; .qunit.wait 00:00:01;
    h: hopen `::11510:tester;
    h "`serverH set hopen 11509; .z.ts: {serverH (set; `zp; .z.P)}; system\"t 100\"";

    //  spawn another reader processes
    system each "q -p ",/: string ps:11511 + til 30; .qunit.wait 00:00:01*count ps;
    hs: hopen each ps;
    hs@\:"serverH: hopen 11509";

    .qunit.wait 00:00:10;
    -25!(hs; "timeUsed: first first .Q.ts[{do[x; y z]}; (100000; serverH; `zp)]");
    timeUsed2: hs@\:"timeUsed";
    @[;"exit 0";{}]each hs;

    -1 "multhr   vs   normal";
    -1 "min time: ",(string min timeUsed1),"ms   ;   ",(string min timeUsed2),"ms.";
    -1 "max time: ",(string max timeUsed1),"ms   ;   ",(string max timeUsed2),"ms.";
    -1 "avg time: ",(string avg timeUsed1),"ms   ;   ",(string avg timeUsed2),"ms.";
    -1 "med time: ",(string med timeUsed1),"ms   ;   ",(string med timeUsed2),"ms.";

    .qunit.assertTrue[(max timeUsed1) < min timeUsed2; "Maximum time used to read by Multi-threaded readers faster than Minimum time used to read by normal readers"];
    .qunit.assertTrue[(avg timeUsed1) < avg timeUsed2; "Average time used to read by Multi-threaded readers faster than Average time used to read by normal readers"];
    .qunit.assertTrue[(med timeUsed1) < med timeUsed2; "Median time used to read by Multi-threaded readers faster than Median time used to read by normal readers"];
    };

.multhrTest.tearDown: { @[; "exit 0"; {}] each key .z.W; .qunit.wait 00:00:05 };

.multhrTest.afterNamespace: { delete config, command from `.multhrTest };

.z.exit: { @[; "exit 0"; {}] each key .z.W };