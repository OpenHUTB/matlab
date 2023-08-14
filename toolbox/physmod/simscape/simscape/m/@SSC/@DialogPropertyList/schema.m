function schema



    ;
    pkg=findpackage('SSC');
    cls=schema.class(pkg,'DialogPropertyList');

    a=SSC.DialogProperty;
    pP=schema.prop(cls,'Properties',[class(a),' vector']);
    pP.AccessFlags.PublicSet='off';

    m=schema.method(cls,'setupDialogProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'MATLAB array'...
    };
    s.OutputTypes={...
    };




