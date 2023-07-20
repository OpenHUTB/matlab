function schema






    pkg=findpackage('RptgenML');

    h=schema.class(pkg,...
    'StylesheetVarpair',...
    pkg.findclass('StylesheetElementID'));

    p=rptgen.prop(h,'Varname','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetVarpair:variableLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getVarname;
    p.setFunction=@setVarname;
    p.Visible='off';

    p=rptgen.prop(h,'Varvalue','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetVarpair:valueLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getVarvalue;
    p.setFunction=@setVarvalue;

    m=schema.method(h,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};
