function schema





    parentpkg=findpackage('slhdlcoder');
    parent=findclass(parentpkg,'HDLTestbench');

    pkg=findpackage('emlhdlcoder');
    this=schema.class(pkg,'HDLTestbench',parent);

    schema.prop(this,'mCEasDataValid','bool');

    m=schema.method(this,'isCEasDataValid');
    s=m.Signature;
    s.varargin='off';
    s.OutputTypes={'bool'};