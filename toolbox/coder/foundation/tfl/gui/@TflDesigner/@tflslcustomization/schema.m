function schema




    hDeriveFromPackage=findpackage('DAStudio');


    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'tflslcustomization',hDeriveFromClass);

    p=schema.prop(clsH,'object','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=0;

    p=schema.prop(clsH,'Name','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='RTW';


    p=schema.prop(clsH,'TableList','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'BaseTfl','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'TargetHWDeviceType','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Description','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'savepath','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'speccount','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=0;



    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getDataAlignmentDlgGroup');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'applyproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'applydataspec');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'setproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'adddataalignspec');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'removedataalignspec');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'printdataalignment');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};



