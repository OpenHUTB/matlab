function schema




    mlock;

    pkg=findpackage('rptgen');
    pkgSchema=findpackage('schema');

    h=schema.class(pkg,'enum',pkgSchema.findclass('EnumType'));

    p=schema.prop(h,'DisplayNames','string vector');