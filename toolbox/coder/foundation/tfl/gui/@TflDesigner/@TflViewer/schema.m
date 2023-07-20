function schema





    mlock;


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('TflDesigner');


    hThisClass=schema.class(hCreateInPackage,'TflViewer',hDeriveFromClass);




    hThisProp=schema.prop(hThisClass,'Children','TflDesigner.TflViewer vector');
    hThisProp.FactoryValue={};

    hThisProp=schema.prop(hThisClass,'Type','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Description','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Version','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='0.0';

    hThisProp=schema.prop(hThisClass,'Key','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'ArrayLayout','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Implementation','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'NumIn','double');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'OutType','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'In1Type','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'In2Type','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Priority','double');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'UsageCount','double');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'Content','mxArray');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'MeObj','handle');
    hThisProp.FactoryValue=[];


    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'getInstanceProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};


    m=schema.method(hThisClass,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};


    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputType={'handle'};
    s.OutputType={'bool'};




