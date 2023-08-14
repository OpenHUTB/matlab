function schema()




    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'uiclipboard',hDeriveFromClass);


    p=schema.prop(clsH,'contents','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};


    p=schema.prop(clsH,'type','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';



    p=schema.prop(clsH,'names','mxArray');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};


    m=schema.method(clsH,'fill');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'clear');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};



