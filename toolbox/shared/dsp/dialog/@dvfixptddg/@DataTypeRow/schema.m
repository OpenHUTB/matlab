function schema





    package=findpackage('dvfixptddg');
    dspdialogPackage=findpackage('dvdialog');
    findclass(dspdialogPackage,'DSPDDG');

    this=schema.class(package,'DataTypeRow');


    schema.prop(this,'Block','mxArray');
    schema.prop(this,'Name','ustring');
    schema.prop(this,'Entries','string vector');
    schema.prop(this,'Prefix','ustring');
    schema.prop(this,'Row','int');
    p=schema.prop(this,'Visible','bool');
    p.FactoryValue=1;
    schema.prop(this,'SupportsUnsigned','int');

    schema.prop(this,'Controller','dvdialog.DSPDDG');


    schema.prop(this,'Mode','int');
    p=schema.prop(this,'WordLength','ustring');


    p.SetFunction=@setWordLength;
    schema.prop(this,'FracLength','ustring');

    m=schema.method(this,'updateFracLengthFromSlope');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};

    m=schema.method(this,'hasPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(this,'getPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string','ustring'};
    m.signature.OutputTypes={'mxArray'};
