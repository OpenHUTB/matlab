function schema()






    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DeviceAttrib_Microprocessor');


    hThisProp=schema.prop(hThisClass,'BitsPerChar','int32');
    hThisProp.FactoryValue=8;

    hThisProp=schema.prop(hThisClass,'BitsPerShort','int32');
    hThisProp.FactoryValue=16;

    hThisProp=schema.prop(hThisClass,'BitsPerInt','int32');
    hThisProp.FactoryValue=32;

    hThisProp=schema.prop(hThisClass,'BitsPerLong','int32');
    hThisProp.FactoryValue=32;
