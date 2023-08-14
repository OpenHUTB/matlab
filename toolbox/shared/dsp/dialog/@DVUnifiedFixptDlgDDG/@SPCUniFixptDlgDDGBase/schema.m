function schema





    parentPkg=findpackage('dvdialog');
    parent=findclass(parentPkg,'DSPDDG');
    package=findpackage('DVUnifiedFixptDlgDDG');
    this=schema.class(package,'SPCUniFixptDlgDDGBase',parent);


    findclass(package,'SPCUniFixptDialog');
    schema.prop(this,'SPCUniFixptDialog','DVUnifiedFixptDlgDDG.SPCUniFixptDialog');


