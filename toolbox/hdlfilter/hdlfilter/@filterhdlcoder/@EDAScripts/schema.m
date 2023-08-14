function schema




    pkg=findpackage('filterhdlcoder');
    shpkg=findpackage('hdlshared');
    parent=findclass(shpkg,'AbstractEDAScripts');

    schema.class(pkg,'EDAScripts',parent);
