function schema





    pkg=findpackage('RptgenML');

    h=schema.class(pkg,...
    'StylesheetHeaderCell',...
    pkg.findclass('StylesheetElement'));

    p=rptgen.prop(h,'Test','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetHeaderCell:conditionLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getTest;
    p.setFunction=@setTest;

    schema.method(h,'listTestSpecial','static');
    schema.method(h,'dlgValueSpecial','static');
    schema.method(h,'setValueSpecial','static');

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

    m=schema.method(h,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

