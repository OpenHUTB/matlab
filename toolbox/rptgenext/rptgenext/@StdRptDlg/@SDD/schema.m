function schema








    pkg=findpackage('StdRptDlg');
    sc=pkg.findclass('Base');
    c=schema.class(pkg,'SDD',sc);






    schema.prop(c,'includeDetails','bool');


    schema.prop(c,'includeRequirementsLinks','bool');


    schema.prop(c,'includeModelRefs','bool');


    schema.prop(c,'includeCustomLibraries','bool');


    schema.prop(c,'includeGlossary','bool');


    schema.prop(c,'hModelCloseListener','mxArray');






    m=schema.method(c,'getContentOptionsSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'initReportProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(c,'getDialogTitle');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(c,'getPreferencesPath');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(c,'createCfg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


end

