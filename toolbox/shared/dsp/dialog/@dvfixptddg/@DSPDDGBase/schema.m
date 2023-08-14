function schema





    parentPkg=findpackage('dvdialog');
    parent=findclass(parentPkg,'DSPDDG');
    package=findpackage('dvfixptddg');
    this=schema.class(package,'DSPDDGBase',parent);

    findclass(package,'FixptDialog');


    schema.prop(this,'FixptDialog','dvfixptddg.FixptDialog');

