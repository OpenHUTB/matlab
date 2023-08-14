function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'AbstractHDLFilter');
    c=schema.class(pk,'usrp2',parent);
    schema.prop(c,'RxChain','hdlfilter.AbstractHDLFilter');
    schema.prop(c,'TxChain','hdlfilter.AbstractHDLFilter');

    schema.prop(c,'Implementation','hdlimplementations');


