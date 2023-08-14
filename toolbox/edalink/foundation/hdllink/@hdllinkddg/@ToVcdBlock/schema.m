function schema






    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('hdllinkddg');
    this=schema.class(package,'ToVcdBlock',parent);






    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};



    m=schema.method(this,'preApply');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};
    m.Signature.OutputTypes={'bool','string'};





    schema.prop(this,'Block','mxArray');
    schema.prop(this,'DisableList','bool');
    schema.prop(this,'Root','mxArray');


    schema.prop(this,'FileName','string');
    schema.prop(this,'NumInport','string');



    schema.prop(this,'TimingScaleFactor','string');
    schema.prop(this,'TimingMode','CoSimTimingModeEnum');
    schema.prop(this,'HdlTickScale','ToVcdHdlScaleEnum');
    schema.prop(this,'HdlTickMode','ToVcdHdlTickModeEnum');





