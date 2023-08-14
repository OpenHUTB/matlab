function schema








    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('dvdialog');
    this=schema.class(package,'DSPDDG',parent);



    p=schema.prop(this,'Block','mxArray');
    p.SetFunction=@setBlock;
    schema.prop(this,'Root','mxArray');

