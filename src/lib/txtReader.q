.multhr.txtReader.read: {[path]
    if[not path~key path:hsym $[10h~type path;`$;] path; '"No such .txt file: ", string path];
    `$text@'where each " "<>text: read0 path
    };
