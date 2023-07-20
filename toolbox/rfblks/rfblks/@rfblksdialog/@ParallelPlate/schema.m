function schema







    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'basetline');
    this=schema.class(rfPackage,'ParallelPlate',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};





    schema.prop(this,'Width','string');
    schema.prop(this,'Separation','string');
    schema.prop(this,'MuR','string');
    schema.prop(this,'EpsilonR','string');
    schema.prop(this,'LossTangent','string');
    schema.prop(this,'SigmaCond','string');


