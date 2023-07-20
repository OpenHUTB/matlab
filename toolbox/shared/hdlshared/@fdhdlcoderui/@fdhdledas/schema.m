function schema







    mlock;

    pk=findpackage('hdlcoderui');
    parentcls=findclass(pk,'abstracthdledas');
    pk=findpackage('fdhdlcoderui');
    c=schema.class(pk,'fdhdledas',parentcls);

    findclass(findpackage('hdlcoderprops'),'CLI');
    p=schema.prop(c,'CLIProperties','hdlcoderprops.CLI');
    p.AccessFlags.PublicSet='off';










    m=schema.method(c,'getTabDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(c,'getparam');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};


