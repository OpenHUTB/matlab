function schema



mlock
    hCreateInPackage=findpackage('Simulink');
    hThisClass=schema.class(hCreateInPackage,'SampleTimeLegend');


    p=schema.prop(hThisClass,'currentTabIndex','int32');
    p.FactoryValue=0;

    p=schema.prop(hThisClass,'isModelUpdated','bool');
    p.FactoryValue=true;

    p=schema.prop(hThisClass,'ssSource','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'legendBlockInfo','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'studio','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'studioDiagramMap','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'modelLegendState','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'modelLegendHighlightState','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'modelList','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'modelName','string');
    p.FactoryValue='';

    p=schema.prop(hThisClass,'legendDlg','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'expandedVarTs','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'hasExpandedVarTs','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'hilitedVarTsBlks','MATLAB array');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'URL','string');
    p.FactoryValue='';

    m=schema.method(hThisClass,'showLegend');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'closeLegend','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'removeModel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'removeSpreadSheetSourceObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'removeColorAnnotation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'changeModelName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'switchModelName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getAsHTML');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getValueString','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray','double','double'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getValueStringAllowInv','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','bool','double'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'convertNumber2String','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'launchDDGSpreadSheet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'clearHilite');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray','string','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'rateHighlight');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray','mxArray','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getHiliteStyler');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getHiliteStyleClass');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getValueDataGroup','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','double','bool'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'hilite_system_legend');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray','bool'};
    s.OutputTypes={};
