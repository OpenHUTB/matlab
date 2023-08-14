function schema






    pkg=findpackage('RptgenML');

    h=schema.class(pkg,...
    'StylesheetElementID',...
    pkg.findclass('StylesheetElement'));

    p=rptgen.prop(h,'ID','string');
    p.Description=getString(message('rptgen:RptgenML_StylesheetElementID:attributeLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@ut_getID;
    p.setFunction=@ut_setID;

    m=schema.method(h,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};
