function schema





    mlock;


    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDSpreadsheetRow',hDeriveFromClass1);






    hThisProp=schema.prop(hThisClass,'DataSource','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'entryID','int32');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'propertyName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'entryName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'entryScope','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'ddEntry','mxArray');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'variantCondition','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'LastModified','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'LastModifiedBy','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Status','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'entryDDG','mxArray');
    hThisProp.FactoryValue='';






    hThisProp=schema.prop(hThisClass,'baseEntryID','int32');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'isDirty','bool');
    hThisProp.FactoryValue=false;





    m=schema.method(hThisClass,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'isReadonlyProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isValidProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getPropValue');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.OutputTypes={'string'};

    m=schema.method(hThisClass,'setPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','ustring'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPropertyStyle');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string','mxArray'};
    m.signature.OutputTypes={};

    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


