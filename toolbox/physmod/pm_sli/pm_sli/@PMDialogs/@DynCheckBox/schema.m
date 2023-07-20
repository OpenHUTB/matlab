function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmCheckBox');


    hThisClass=schema.class(hCreateInPackage,'DynCheckBox',hBaseObj);


    schema.prop(hThisClass,'ResolveBuddyTags','bool');
    schema.prop(hThisClass,'MyTag','ustring');
    schema.prop(hThisClass,'BuddyItemsTags','string vector');




    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


    m=schema.method(hThisClass,'OnChkBoxChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','string'};
    s.OutputTypes={};



