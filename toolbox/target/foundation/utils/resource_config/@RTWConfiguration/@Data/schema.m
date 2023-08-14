function schema()


















    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'Data');


    hThisProp=schema.prop(hThisClass,'help_callback','string');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.FactoryValue='disp(''No Help Available'')';

    hThisProp=schema.prop(hThisClass,'configuration_type','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='RTW Configuration';

    hThisProp=schema.prop(hThisClass,'hidden_configuration','bool');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.Init='on';

    hThisProp.FactoryValue=logical(0);

    hThisProp=schema.prop(hThisClass,'listeners','handle vector');
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.PublicSet='off';
