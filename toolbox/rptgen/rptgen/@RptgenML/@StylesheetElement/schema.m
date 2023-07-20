function schema





    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,...
    'StylesheetElement',...
    pkgRG.findclass('DAObject'));

    p=rptgen.prop(h,'JavaHandle','MATLAB array');
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';
    p.setFunction=@setJavaHandle;

    p=rptgen.prop(h,'Value','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetElement:valueLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@ut_getValue;
    p.setFunction=@ut_setValue;

    p=rptgen.prop(h,'ValueInvalid','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=rptgen.prop(h,'DescriptionShort','java.lang.String');
    p.Visible='off';

    p=rptgen.prop(h,'DescriptionLong','java.lang.String');
    p.Visible='off';

    p=rptgen.prop(h,'DataType','java.lang.String');
    p.Visible='off';

    p=rptgen.prop(h,'Casted','bool',false);
    p.Visible='off';


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









