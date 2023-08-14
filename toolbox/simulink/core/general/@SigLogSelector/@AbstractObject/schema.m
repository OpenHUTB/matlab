function schema




    mlock;


    sCls=findclass(findpackage('DAStudio'),'Object');
    cls=schema.class(findpackage('SigLogSelector'),'AbstractObject',sCls);


    p=schema.prop(cls,'Name','ustring');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';





    p=schema.prop(cls,'daobject','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';





    schema.prop(cls,'topMdlName','ustring');



    schema.prop(cls,'hParent','handle');





    schema.prop(cls,'hMdlRefBlock','handle');


    p=schema.prop(cls,'listeners','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';


    schema.prop(cls,'userData','MATLAB array');


    m=schema.method(cls,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};


    m=schema.method(cls,'getFullName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};


    m=schema.method(cls,'getBdOrTopMdlRefNode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};


    m=schema.method(cls,'getTopModelName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};


    m=schema.method(cls,'getFullMdlRefPath');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(cls,'isHierarchySimulating');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'view');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(cls,'registerDAListeners');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={};

end
