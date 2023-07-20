function schema








    mlock;


    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'HDLDirectCodeGen');

    package=findpackage('hdlbuiltinimpl');
    this=schema.class(package,'EmlImplBase',parent);

    schema.method(this,'validateRegisterRates','static');
    schema.method(this,'getTunableParameter','static');
    schema.method(this,'addTunablePortsFromParams','static');
    schema.method(this,'getTunableParameterInfoforEml','static');

    m=schema.method(this,'getHelpInfo');
