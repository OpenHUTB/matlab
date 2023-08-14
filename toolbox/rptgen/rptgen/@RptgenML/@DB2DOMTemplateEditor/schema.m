function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'DB2DOMTemplateEditor',pkgRG.findclass('DAObject'));

    p=rptgen.prop(h,'TemplatePath','string','',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:templatePathLabel')));
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='on';

    p=rptgen.prop(h,'CoreProps','MATLAB array');
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='on';
    p.Visible='off';

    p=rptgen.prop(h,'ID','string','',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:IDLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='on';
    p.getFunction=@getID;
    p.setFunction=@setID;

    propMap=containers.Map(...
    {'DisplayName','Description','Creator'},...
    {'Title','Description','Creator'});
    p=rptgen.prop(h,'CorePropMap','MATLAB array',propMap);
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';

    p=rptgen.prop(h,'DisplayName','string','',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:displayNameLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getCoreProp,p.Name};
    p.setFunction={@setCoreProp,p.Name};

    p=rptgen.prop(h,'Description','string','',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:descriptionLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getCoreProp,p.Name};
    p.setFunction={@setCoreProp,p.Name};

    p=rptgen.prop(h,'Creator','string','',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:creatorLabel')));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction={@getCoreProp,p.Name};
    p.setFunction={@setCoreProp,p.Name};


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

    m=schema.method(h,'getInfoSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(h,'deleteTemplate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
