function schema






    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRam');
    this=schema.class(package,'dualPortRam',parent);

    p=schema.prop(this,'InputPortNames','mxArray');%#ok

    p=schema.prop(this,'OutputPortNames','mxArray');%#ok

    p=schema.prop(this,'blkParam','mxArray');

    p=schema.prop(this,'CodeGenMode','ustring');
