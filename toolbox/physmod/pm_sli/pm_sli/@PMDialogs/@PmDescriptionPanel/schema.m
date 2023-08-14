function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmDescriptionPanel',hBaseObj);




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

    p=schema.prop(hThisClass,'DescrText','ustring');


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

