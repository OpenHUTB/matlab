function schema





    hDeriveFromPackage=findpackage('TflDesigner');
    hDeriveFromClass=findclass(hDeriveFromPackage,'abstractnode');

    hCreateInPackage=findpackage('TflDesigner');

    clsH=schema.class(hCreateInPackage,'root',hDeriveFromClass);


    p=schema.prop(clsH,'defaulttypeprefix','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='Table';


    p=schema.prop(clsH,'tablecount','int32');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=1;



    p=schema.prop(clsH,'iseditorbusy','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;


    p=schema.prop(clsH,'uiclipboard','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'buildinfouiclipboard','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';





    p=schema.prop(clsH,'lastactionnodepath','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';




    p=schema.prop(clsH,'currenttreenode','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'setproperror','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'childListView','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='Default';




    m=schema.method(clsH,'root');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getRoot');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'isHierarchyReadonly');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};


    m=schema.method(clsH,'refreshchildrencache');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','bool'};
    s.OutputTypes={};

    m=schema.method(clsH,'insertnode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'deletenode');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray','bool'};
    s.OutputTypes={'handle'};


    m=schema.method(clsH,'resettablecounter');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};





