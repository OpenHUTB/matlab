function schema





    pkg=findpackage('RptgenML');
    pkgXML=findpackage('rpt_xml');

    clsH=schema.class(pkg,...
    'FileConverter',...
    pkgXML.findclass('db_output'));

    p=rptgen.prop(clsH,'View','bool',true,...
    getString(message('rptgen:RptgenML_FileConverter:viewWhenDone')));

    p=rptgen.prop(clsH,'RuntimeConverting','bool',false,...
    '',2);

    p=rptgen.prop(clsH,'DirectoryListener','MATLAB array',[],...
    '',2);
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';



    m=schema.method(clsH,'listFiles','static');


    m=schema.method(clsH,'canAcceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};


    m=schema.method(clsH,'cbkConvert');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'cbkSelectFile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(clsH,'areChildrenOrdered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

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

    m=schema.method(clsH,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};























