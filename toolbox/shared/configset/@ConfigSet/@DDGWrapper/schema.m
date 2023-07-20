function schema()



    hCreateInPackage=findpackage('ConfigSet');


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');


    hThisClass=schema.class(hCreateInPackage,'DDGWrapper',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'dialog','handle');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'value','mxArray');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'newvalue','mxArray');
    hThisProp.FactoryValue=[];
    hThisProp.GetFunction=@getValue;

    hThisProp=schema.prop(hThisClass,'name','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'parameter','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'tag','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'userData','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'storage','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'customized','mxArray');
    hThisProp.FactoryValue=[];

    hThisProp=schema.prop(hThisClass,'batchMode','bool');
    hThisProp.FactoryValue=false;
    hThisProp.Visible='off';



    m=schema.method(hThisClass,'getWidgetValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getUserData');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getComboBoxText');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'setWidgetValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setVisible');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'evalJS');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'disableWidgets');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'hideWidgets');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getDialogSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'disableDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'enableDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'expandTogglePanel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={};


    function val=getValue(this,~)
        val=this.value;
