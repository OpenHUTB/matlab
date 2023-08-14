function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'DB2DOMTemplateBrowser',pkgRG.findclass('DAObject'));

    p=schema.prop(h,'TemplateLibrary','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(h,'CategoryDOCX','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'DOCX',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:DOCXLabel')),true};

    p=schema.prop(h,'CategoryHTMX','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'HTMX',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:HTMXLabel')),true};

    p=schema.prop(h,'CategoryHTMLFile','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'HTMLFile',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:HTMLFileLabel')),true};

    p=schema.prop(h,'CategoryPDF','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'PDF',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:PDFLabel')),true};


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

    m=schema.method(h,'getTemplate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={'handle'};

    m=schema.method(h,'addTemplateToLibrary');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
