function schema






    pkg=findpackage('RptgenML');

    h=schema.class(pkg,...
    'StylesheetAttributeSet',...
    pkg.findclass('StylesheetElementID'));

    p=rptgen.prop(h,'UseAttributeSets','string vector');
    p.Description=getString(message('rptgen:RptgenML_StylesheetAttributeSet:inheritAttributeSetsLabel'));
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getUseAttributeSets;
    p.setFunction=@setUseAttributeSets;



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

