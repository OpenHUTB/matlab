function schema





    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('hdllinkddg');
    this=schema.class(package,'CoSimBlockDialogXSI',parent);







    m=schema.method(this,'getDialogSchema');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(this,'PreApply');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};
    m.Signature.OutputTypes={'bool','string'};










    m=schema.method(this,'MaskParamsToSources');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};

    m=schema.method(this,'SourcesToMaskParams');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};




    m=schema.method(this,'Autofill');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};




    m=schema.method(this,'AutotimescaleCb');
    m.Signature.varargin='on';
    m.Signature.InputTypes={'handle','handle'};

    m=schema.method(this,'Autotimescale');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','bool'};








    schema.prop(this,'Block','mxArray');
    schema.prop(this,'CurrentTab','int');
    schema.prop(this,'DisableList','bool');
    schema.prop(this,'Root','mxArray');

    schema.prop(this,'ProductName','string');





    schema.prop(this,'AllowDirectFeedthrough','bool');
    schema.prop(this,'PortExtendedTableSource','mxArray');


    schema.prop(this,'idxCellArray','string');


    schema.prop(this,'CommSource','mxArray');
    schema.prop(this,'CommLocalHostName','string');


    schema.prop(this,'ClockResetTableSource','mxArray');




    schema.prop(this,'UserData','mxArray');
    schema.prop(this,'PreRunTime','string');
    schema.prop(this,'PreRunTimeUnit','PreRunTimeUnitEnum');


    schema.prop(this,'TimingScaleFactor','string');
    schema.prop(this,'TimingMode','CoSimTimingModeEnum');
    schema.prop(this,'RunAutoTimescale','bool');



