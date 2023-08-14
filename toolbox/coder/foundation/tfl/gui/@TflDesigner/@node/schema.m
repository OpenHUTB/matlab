function schema()





    hDeriveFromPackage=findpackage('TflDesigner');
    hDeriveFromClass=findclass(hDeriveFromPackage,'abstractnode');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'node',hDeriveFromClass);


    p=schema.prop(clsH,'parentroot','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';



    p=schema.prop(clsH,'Type','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'object','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=0;



    p=schema.prop(clsH,'path','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'isValid','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;


    p=schema.prop(clsH,'errLog','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'isDirty','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;





    p=schema.prop(clsH,'Name','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Description','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'allowchildrentopopulate','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;




    p=schema.prop(clsH,'validelementtypes','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};





    p=schema.prop(clsH,'currentelement','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'okToClose','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;



    m=schema.method(clsH,'node');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'isHierarchical');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

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

    m=schema.method(clsH,'getPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'ustring'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'isHierarchyReadonly');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getRoot');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'setPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','ustring'};
    s.OutputTypes={};

    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'setproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'applyproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'isValidProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'addchild');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray','bool'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'validateChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};



