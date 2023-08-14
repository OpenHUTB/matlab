function schema




    basePackage=findpackage('Simulink');
    baseClass=findclass(basePackage,'SLDialogSource');
    createInPackage=findpackage('ssm');
    this=schema.class(createInPackage,'DDGDialog',baseClass);



    schema.prop(this,'Impl','mxArray');



    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


