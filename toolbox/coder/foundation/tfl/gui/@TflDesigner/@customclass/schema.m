function schema




    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'customclass',hDeriveFromClass);

    p=schema.prop(clsH,'packagename','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='RTW';


    p=schema.prop(clsH,'classname','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'custombaseclass','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'customfilepath','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'applyproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'customlocation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};


