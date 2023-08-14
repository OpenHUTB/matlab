function schema()


















    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'Resource');


    hThisProp=schema.prop(hThisClass,'id','string');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='''resource''';

    hThisProp=schema.prop(hThisClass,'resources','string vector');

    hThisProp=schema.prop(hThisClass,'allocations','handle');
