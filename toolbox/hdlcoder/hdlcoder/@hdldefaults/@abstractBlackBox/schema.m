function schema






    mlock;


    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'HDLDirectCodeGen');

    package=findpackage('hdldefaults');
    this=schema.class(package,'abstractBlackBox',parent);
    set(this,'Description','abstract');
