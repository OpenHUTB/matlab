function schema()




    mlock;

    hCreateInPackage=findpackage('mpt');
    hThisClass=schema.class(hCreateInPackage,'MiscCustomizer');

    hThisProp=schema.prop(hThisClass,'MPFToolVersion','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PrivateSet='on';
    hThisProp.Visible='off';
    hThisProp.FactoryValue='';

    sym_factory={};
    hThisProp=schema.prop(hThisClass,'MPFSymbolDefinition','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PrivateSet='on';
    hThisProp.Visible='off';
    hThisProp.FactoryValue=sym_factory;
