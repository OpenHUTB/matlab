function schema





    pkgRG=findpackage('rptgen');
    pkgUD=findpackage('rptgen_ud');


    c=schema.class(pkgUD,'ClassNode',...
    pkgRG.findclass('rpt_all'));


    p=schema.prop(c,'ClassPointer','schema.class');


    p=schema.prop(c,'IsCanonical','bool');
    p.AccessFlags.Init='on';
    p.FactoryValue=logical(1);

