function schema





    pkg=findpackage('RptgenML');

    h=schema.class(pkg,...
    'StylesheetHeader',...
    pkg.findclass('StylesheetElementID'));

    p=rptgen.prop(h,'OtherwiseValue','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetHeader:otherConditionsLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getOtherwiseValue;
    p.setFunction=@setOtherwiseValue;

    p=rptgen.prop(h,'OtherwiseValueInvalid','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';




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

    m=schema.method(h,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};
