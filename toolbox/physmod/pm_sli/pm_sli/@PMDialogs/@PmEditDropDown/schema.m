function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmEditDropDown',hBaseObj);


    schema.prop(hThisClass,'Label','mxArray');
    schema.prop(hThisClass,'LabelAttrb','int');
    schema.prop(hThisClass,'Value','ustring');
    schema.prop(hThisClass,'Choices','MATLAB array');
    schema.prop(hThisClass,'ChoiceVals','mxArray');
    schema.prop(hThisClass,'MapVals','mxArray');
    schema.prop(hThisClass,'PreApplyFcn','mxArray');


    m=schema.method(hThisClass,'PreApply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

