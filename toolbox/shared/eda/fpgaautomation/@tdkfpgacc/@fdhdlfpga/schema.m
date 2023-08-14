function schema





    mlock;

    pk=findpackage('hdlcoderui');
    parentcls=findclass(pk,'abstracthdlcomps');
    pk=findpackage('tdkfpgacc');
    c=schema.class(pk,'fdhdlfpga',parentcls);

    findclass(findpackage('fpgaworkflowprops'),'FDHDLCoder');
    p=schema.prop(c,'FPGAProperties','fpgaworkflowprops.FDHDLCoder');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'FPGAProjectPropTableSource','handle');
    p.AccessFlags.Serialize='off';
    p.Visible='off';





    m=schema.method(c,'getTabDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(c,'fpgaPropToSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(c,'sourceToFpgaProp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};







    m=schema.method(c,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};














