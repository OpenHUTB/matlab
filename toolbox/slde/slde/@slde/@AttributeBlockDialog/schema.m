function schema




    basePackage=findpackage('Simulink');
    baseClass=findclass(basePackage,'SLDialogSource');
    createInPackage=findpackage('slde');
    this=schema.class(createInPackage,'AttributeBlockDialog',baseClass);



    schema.prop(this,'Impl','mxArray');



    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'doPreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(this,'doCloseCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};


