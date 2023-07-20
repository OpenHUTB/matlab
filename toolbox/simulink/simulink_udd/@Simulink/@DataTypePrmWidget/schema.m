function schema()




    hPackage=findpackage('Simulink');

    hThisClass=schema.class(hPackage,'DataTypePrmWidget');

    schema.method(hThisClass,'getDataTypeWidget','static');






...
...
...
...
...
...

    m=schema.method(hThisClass,'getSPCDataTypeWidgets','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray','mxArray','mxArray','mxArray','mxArray'};

    m=schema.method(hThisClass,'getDataTypeWidgetTag','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'callbackDataTypeWidget','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','mxArray','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'createDataTypeAssistantFlyout','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','mxArray','string','string','string','string','mxArray','bool'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'callbackSPCDataTypeWidgets','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getUniqueTagPrefix','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'parseDataTypeString','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'fixdtFieldsToString','static');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getInheritList','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getBuiltinList','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getScalingModeList','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSignModeList','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'udtMessages','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'defaultRuleTranslator','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getDataTypeListForDataObjects','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getBuiltinListForDataObjects','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDataTypeAllowedItems','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'mxArray'};




