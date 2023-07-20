function[hdl_arch,lastproductedsum]=emit_linear_mac(this,hdl_arch,preaddlist,fdregsig)






    tapsumall=hdlgetallfromsltype(this.tapsumSLtype);
    tapsumvtype=tapsumall.vtype;
    tapsumsltype=tapsumall.sltype;

    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    rmode=this.Roundmode;
    [productrounding,sumrounding,...
    tapsumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation,...
    tapsumsaturation]=deal(omode);

    [uname,tapsumsig]=hdlnewsignal('tapsum',...
    'filter',-1,0,0,tapsumvtype,tapsumsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tapsumsig)];
    [uname,prodsig]=hdlnewsignal('product',...
    'filter',-1,0,0,productvtype,productsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(prodsig)];
    [uname,lastproductedsum]=hdlnewsignal('sum',...
    'filter',-1,0,0,sumvtype,sumsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(lastproductedsum)];


    [subbody,subsignals]=hdlsub(preaddlist(2),preaddlist(1),tapsumsig,...
    tapsumrounding,tapsumsaturation);


    [fdpdctbody,fdpdtsignals]=hdlmultiply(fdregsig,tapsumsig,prodsig,...
    productrounding,productsaturation);


    [sumbody,sumsignals]=hdladd(preaddlist(1),prodsig,lastproductedsum,...
    sumrounding,sumsaturation);
    hdl_arch.signals=[hdl_arch.signals,subsignals,fdpdtsignals,sumsignals];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,subbody,fdpdctbody,sumbody];




