function schema











    pkg=findpackage('StdRptDlg');
    pkgDAS=findpackage('DAStudio');
    sc=pkgDAS.findclass('Object');
    c=schema.class(pkg,'Base',sc);






    schema.prop(c,'title','ustring');


    schema.prop(c,'subtitle','ustring');


    schema.prop(c,'authorNames','ustring');


    schema.prop(c,'titleImgPath','ustring');


    schema.prop(c,'legalNotice','ustring');


    schema.prop(c,'outputFormat','double');


    schema.prop(c,'packageType','int');


    schema.prop(c,'outputName','ustring');


    schema.prop(c,'outputDir','ustring');


    schema.prop(c,'incrOutputName','bool');


    schema.prop(c,'stylesheetIndex','double');


    schema.prop(c,'stylesheetIDs','string vector');




    schema.prop(c,'reportCfg','MATLAB array');






    schema.prop(c,'retainXMLSource','bool');





    schema.prop(c,'noView','bool');




    schema.prop(c,'rootSystem','MATLAB array');


    p=schema.prop(c,'hModelCloseListener','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PrivateSet='on';







    m=schema.method(c,'getSysSelectionSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(c,'getTitlePageOptionsSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(c,'getContentOptionsSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(c,'getReportOutputOptionsSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(c,'getButtonPanelSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(c,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(c,'runReport');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};




    m=schema.method(c,'customizeReport');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};




    m=schema.method(c,'customizeStylesheet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};


    m=schema.method(c,'cancelReport');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};


    m=schema.method(c,'help');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(c,'saveCfg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(c,'getCfg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(c,'updateBaseCfg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(c,'updateCfg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};

    m=schema.method(c,'initBaseReportProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};


    m=schema.method(c,'initReportProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};


    m=schema.method(c,'browseImage');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};

    m=schema.method(c,'browseOutputDir');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};

    m=schema.method(c,'xlate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(c,'bxlate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(c,'installModelCloseListener');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle'};
    m.signature.outputTypes={};

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
    s.OutputTypes={'handle'};

end


