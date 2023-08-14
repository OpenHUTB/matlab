function schema








    package=findpackage('hdllinkddg');
    this=schema.class(package,'AutoTimescaleDialog');







    m=schema.method(this,'getDialogSchema');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(this,'ShowHideBtnCb');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};







    schema.prop(this,'productName','string');
    schema.prop(this,'dialogTag','string');
    schema.prop(this,'msgType','string');
    schema.prop(this,'msg','string');
    schema.prop(this,'dmsg','string');
    schema.prop(this,'showShowBtn','bool');
    schema.prop(this,'dmsgTag','string');
    schema.prop(this,'showBtnTag','string');
    schema.prop(this,'hideBtnTag','string');
