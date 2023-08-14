function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'aRam');

    p=schema.prop(c,'isVHDL','bool');
    p=schema.prop(c,'isVerilog','bool');
    p=schema.prop(c,'isStdLogicIn','bool');
    p=schema.prop(c,'isStdLogicOut','bool');
    p=schema.prop(c,'hasClkEnable','bool');
    p=schema.prop(c,'dataIsComplex','bool');

    p=schema.prop(c,'entityName','ustring');
    p=schema.prop(c,'fullFileName','ustring');
    p=schema.prop(c,'fullPathName','ustring');
    p=schema.prop(c,'fileHeader','ustring');

    p=schema.prop(c,'numRam','int32');
    set(p,'FactoryValue',1);

