function schema




    mlock;

    hPackage=findpackage('tdkfpgacc');
    this=schema.class(hPackage,'FPGAProjectPropRowSource');

    p=schema.prop(this,'name','string');
    p=schema.prop(this,'value','string');
    p=schema.prop(this,'process','string');


