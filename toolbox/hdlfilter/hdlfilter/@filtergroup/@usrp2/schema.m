function schema





    mlock;

    pkg=findpackage('filtergroup');

    this=schema.class(pkg,'usrp2');

    schema.prop(this,'RxChain','mxArray');
    schema.prop(this,'TxChain','mxArray');

    p=schema.prop(this,'FilterStructure','ustring');
    set(p,'AccessFlags.PublicSet','Off');
