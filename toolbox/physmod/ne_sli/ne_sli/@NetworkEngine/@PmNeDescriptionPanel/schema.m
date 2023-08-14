function schema








    hBasePackage=findpackage('PMDialogs');
    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hBasePackage.findclass('PmDescriptionPanel');


    hThisClass=schema.class(hCreateInPackage,'PmNeDescriptionPanel',hBaseObj);




    p=schema.prop(hThisClass,'Need2Realize','bool');
    p.AccessFlags.PrivateGet='on';
    p.AccessFlags.PrivateSet='on';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(hThisClass,'BlockTitle','ustring');
    p.AccessFlags.PrivateGet='on';
    p.AccessFlags.PrivateSet='on';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(hThisClass,'DescrText','ustring');%#ok


    p=schema.prop(hThisClass,'Label','ustring');%#ok



    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'viewSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'chooseSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setVariant');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

end
