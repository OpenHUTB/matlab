function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmLabelSpinner');


    hThisClass=schema.class(hCreateInPackage,'DynLabelSpinner',hBaseObj);



    p=schema.prop(hThisClass,'ComboTag','ustring');
    p.FactoryValue='';
    schema.prop(hThisClass,'ValueTxt','ustring');




    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


    m=schema.method(hThisClass,'OnUpButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'OnDownButton');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'OnEditChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};

