function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'StylesheetEditor',pkgRG.findclass('DAObject'));

    p=rptgen.prop(h,'JavaHandle','MATLAB array');
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='off';
    p.Visible='on';

    p=rptgen.prop(h,'Registry','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:parentRegistryFileLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getFileProp,p.Name};
    p.setFunction={@setFileProp,p.Name};

    p=rptgen.prop(h,'ID','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:uniqueIDLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getStringProp,p.Name};
    p.setFunction={@setStringProp,p.Name};

    p=rptgen.prop(h,'DisplayName','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:displayNameLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getStringProp,p.Name};
    p.setFunction={@setStringProp,p.Name};

    p=rptgen.prop(h,'TransformType','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:transformTypeLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getStringProp,p.Name};
    p.setFunction={@setStringProp,p.Name};

    p=rptgen.prop(h,'Filename','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:stylesheetFile')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getStringProp,p.Name};
    p.setFunction={@setStringProp,p.Name};

    p=rptgen.prop(h,'Description','ustring','',...
    getString(message('rptgen:RptgenML_StylesheetEditor:descriptionLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getStringProp,p.Name};
    p.setFunction={@setStringProp,p.Name};



    m=schema.method(h,'clearStylesheet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    schema.method(h,'createLibrary','static');


    m=schema.method(h,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(h,'areChildrenOrdered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'isBuiltin');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(h,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(h,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(h,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(h,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(h,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(h,'canAcceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};









