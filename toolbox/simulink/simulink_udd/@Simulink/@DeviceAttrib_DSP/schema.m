function schema()







    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DeviceAttrib_DSP');


    hThisProp=schema.prop(hThisClass,'NaturalWordSize','int32');

    hThisProp=schema.prop(hThisClass,'AccumulatorSize','int32');

    hThisProp=schema.prop(hThisClass,'SpecialScalingMAC','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(0);
