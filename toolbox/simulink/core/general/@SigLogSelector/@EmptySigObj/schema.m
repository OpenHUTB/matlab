function schema



    mlock;


    sCls=findclass(findpackage('DAStudio'),'Object');
    cls=schema.class(findpackage('SigLogSelector'),'EmptySigObj',sCls);


    p=schema.prop(cls,'Name','ustring');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';


    m=schema.method(cls,'isEditableProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};
end
