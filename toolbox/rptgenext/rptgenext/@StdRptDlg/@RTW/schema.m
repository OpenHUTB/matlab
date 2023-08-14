function schema








    pkg=findpackage('StdRptDlg');
    sc=pkg.findclass('Base');
    c=schema.class(pkg,'RTW',sc);






    schema.prop(c,'codegenFolder','string');


    schema.prop(c,'modelInformation','bool');


    schema.prop(c,'generatedCodeListings','bool');


    schema.prop(c,'codeGenerationSummary','bool');


    schema.prop(c,'includeGlossary','bool');


    schema.prop(c,'templateFile','string');


    schema.prop(c,'hModelCloseListener','mxArray');


    schema.prop(c,'targetSystem','string');






    m=schema.method(c,'getContentOptionsSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'saveOptions');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(c,'getReportOutputOptionsSchema');
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

    m=schema.method(c,'browseGenCodeLocation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};

    m=schema.method(c,'browseTemplateFile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};

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

    m=schema.method(c,'helpCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
end

