function schema()





    hDeriveFromPackage=findpackage('TflDesigner');
    hDeriveFromClass=findclass(hDeriveFromPackage,'node');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'elements',hDeriveFromClass);


    p=schema.prop(clsH,'parentnode','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'callerisinit','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.FactoryValue=false;






    p=schema.prop(clsH,'EntryType','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'iscommented','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'iscustomtype','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'customfilepath','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';


    p=schema.prop(clsH,'conceptualargs','handle vector');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'activeconceptarg','double');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=1;



    p=schema.prop(clsH,'activeconceptargIsMatrix','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'activedworkarg','double');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=1;

    p=schema.prop(clsH,'activeimplarg','double');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=1;

    p=schema.prop(clsH,'addedimplarg','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;



    p=schema.prop(clsH,'argtype','double');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=-1;


    p=schema.prop(clsH,'cargdtypeunapplied','string');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='on';
    p.FactoryValue='';



    p=schema.prop(clsH,'cargstructfields','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};


    p=schema.prop(clsH,'cargcustomdtype','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};


    p=schema.prop(clsH,'iargdtypeunapplied','string');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='on';
    p.FactoryValue='';



    p=schema.prop(clsH,'iargstructfields','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};

    p=schema.prop(clsH,'returnargname','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'implargdtype','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'makeimplargconstant','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'showErrLogTab','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'showBuildInfoTab','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;












    p=schema.prop(clsH,'copyconcepargsettings','double');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=3;

    p=schema.prop(clsH,'allocatesdwork','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'concepargerror','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'implargerror','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'showdataalign','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'applyerrorlog','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'applyinvalid','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'widgetStructList','handle vector');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'widgetTagList','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'apSet','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';




    m=schema.method(clsH,'elements');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'handle'};

    m=schema.method(clsH,'isReadonlyProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(clsH,'getPropAllowedValues');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'isEditableProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


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
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'getPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'ustring'};

    m=schema.method(clsH,'getkeyentries');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getconceptualarglist');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getdworkarglist');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getimplarglist');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getentries');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string','double'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getPossibleProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'applyproperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'addconceptualarg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'removeconceptualarg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'addimplarg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'removeimplarg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'applyconceptargchanges');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'applyimplargchanges');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'applybuildinfochanges');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(clsH,'addbuildinfofile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(clsH,'createConceptualArgs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'createDWorkArgs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'createImplementationArgs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'movearg');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(clsH,'removelistentry');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};

    m=schema.method(clsH,'opencustomdeffile');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'getConceptualDatatype');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'validateEntry');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'copyConceptualArgsSettings');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'allocateDWork');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'clearDWork');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'getdworkallocatorentries');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'clearlinks');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'createDialogWidget');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'getDialogWidget');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'setWidgetProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(clsH,'formatFixpointString');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'isDataTypeStruct');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'populateConceptualStructTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'updateStructFieldTypes');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'populateImplStructTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'formatNumericTypeString');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string','bool'};

    m=schema.method(clsH,'isStructSpecEnabled');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};











