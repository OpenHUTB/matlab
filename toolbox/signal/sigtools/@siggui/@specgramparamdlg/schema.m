function schema





    hSuperPackage=findpackage('DAStudio');
    hSuperClass=findclass(hSuperPackage,'Object');
    pk=findpackage('siggui');
    c=schema.class(pk,'specgramparamdlg',hSuperClass);


    p=schema.prop(c,'NWindow','ustring');
    p.AccessFlags.Serialize='off';


    p=schema.prop(c,'Nfft','ustring');
    p.Accessflags.Serialize='off';


    p=schema.prop(c,'Nlap','ustring');
    p.Accessflags.Serialize='off';

    schema.event(c,'DialogClose');
    schema.event(c,'DialogApply');

    m=schema.method(c,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'dialogClosecallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(c,'dialogApplycallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'double','string'};


