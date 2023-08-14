function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'StylesheetRoot',pkgRG.findclass('DAObject'));

    p=schema.prop(h,'StylesheetLibrary','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(h,'CategoryNEW','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'NEW',getString(message('rptgen:RptgenML_StylesheetRoot:newStylesheetLabel')),true};

    htmlDsssl=com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat('html-dsssl');
    if~isempty(htmlDsssl)
        isVisHtmlDsssl=getVisible(htmlDsssl);
    else
        isVisHtmlDsssl=false;
    end

    latex=com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat('latex');
    if~isempty(latex)
        isVisLatex=getVisible(latex);
    else
        isVisLatex=false;
    end

    tTypes={
    'HTML',getString(message('rptgen:RptgenML_StylesheetRoot:HTMLLabel')),true
    'FO',getString(message('rptgen:RptgenML_StylesheetRoot:FOLabel')),true
    'DSSSL',getString(message('rptgen:RptgenML_StylesheetRoot:dssslRTFLabel')),true
    'DSSSLHTML',getString(message('rptgen:RptgenML_StylesheetRoot:dssslHTMLLabel')),isVisHtmlDsssl
    'LATEX',getString(message('rptgen:RptgenML_StylesheetRoot:LATEXLabel')),isVisLatex
    };

    for i=1:size(tTypes,1)
        p=schema.prop(h,['Params',tTypes{i,1}],'handle');
        p.AccessFlags.PublicSet='off';
        p.AccessFlags.Reset='off';
        p.AccessFlags.Serialize='off';
        p.Visible='off';

        p=schema.prop(h,['Category',tTypes{i,1}],'handle');
        p.AccessFlags.PublicSet='off';
        p.AccessFlags.Reset='off';
        p.AccessFlags.Serialize='off';
        p.AccessFlags.AbortSet='off';
        p.Visible='off';
        p.GetFunction=[{@getCategory},tTypes(i,:)];
    end

    p=schema.prop(h,'CategoryEmpty','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.AbortSet='off';
    p.Visible='off';
    p.GetFunction={@getCategory,'Empty','',false};


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

    m=schema.method(h,'getStylesheet');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={'handle'};










