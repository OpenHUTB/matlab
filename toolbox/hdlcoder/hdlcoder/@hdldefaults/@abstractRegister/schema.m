function schema






    mlock;


    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'HDLDirectCodeGen');

    package=findpackage('hdldefaults');
    this=schema.class(package,'abstractRegister',parent);
    set(this,'Description','abstract');

    schema.method(this,'findSingleRateSignal','static');