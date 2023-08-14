function schema




    hCreateInPackage=findpackage('AUTOSAR');
    hPackage=findpackage('DAStudio');
    hBaseClass=findclass(hPackage,'Explorer');

    hThisClass=schema.class(hCreateInPackage,'Explorer',hBaseClass);

    hThisProp=schema.prop(hThisClass,'SelChangedCB','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'ListSelChangedCB','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'AccordionChangedCB','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'closeListener','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'stfChangedListener','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'MappingToolbar','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'TargetToolbar','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'EditToolbar','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'TraversedRoot','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'MappingManager','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'DAObjectMappingRoot','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'SharedAutosarDictionary','string');
    hThisProp.FactoryValue='';


