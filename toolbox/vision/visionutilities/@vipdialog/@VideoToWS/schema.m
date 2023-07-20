function schema





    parentpackage=findpackage('dvdialog');
    parent=findclass(parentpackage,'DSPDDG');
    vipPackage=findpackage('vipdialog');
    hThisClass=schema.class(vipPackage,'VideoToWS',parent);


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    schema.prop(hThisClass,'VariableName','ustring');
    schema.prop(hThisClass,'NumInputs','ustring');
    schema.prop(hThisClass,'DataLimit','ustring');
    schema.prop(hThisClass,'DecimationFactor','ustring');
    schema.prop(hThisClass,'LogFi','bool');
    schema.prop(hThisClass,'InPortLabels','ustring');

