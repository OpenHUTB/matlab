function schema







    hCreateInPkg=findpackage('coder_coverage_ui');


    hPackage=findpackage('DAStudio');
    hBaseClass=findclass(hPackage,'Object');


    hThisClass=schema.class(hCreateInPkg,'CodeCovDlg',hBaseClass);



    hThisProp=schema.prop(hThisClass,'ToolName','string');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ToolClass','string');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ToolCompany','string');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ParentHSrc','handle');
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'IncludeTopModel','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IncludeReferencedModels','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'ExcludedModels','MATLAB array');
    hThisProp.FactoryValue={};
    hThisProp.Visible='off';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'ViewWidget','handle');
    hThisProp.FactoryValue=[];




    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'postApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'CloseCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};
