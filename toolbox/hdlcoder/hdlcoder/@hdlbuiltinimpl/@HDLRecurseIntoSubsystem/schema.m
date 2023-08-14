function schema



    mlock;

    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'HDLDirectCodeGen');

    this=schema.class(package,'HDLRecurseIntoSubsystem',parent);


    p=schema.prop(this,'SuppressValidation','bool');
    set(p,'FactoryValue',false);

