function[conjbody,conjsignals,ncoouttoprod]=emit_ncoconjugateout(this,ncocastsig)



    conjbody='';
    conjsignals='';

    nco=this.NCO;
    ncoout_sltype=hdlsignalsltype(ncocastsig);

    ncocastrounding='floor';
    ncocastsaturation=0;

    ncoall=hdlgetallfromsltype(ncoout_sltype);
    if nco.isOutputPortComplex

        [~,ncoconjsig]=hdlnewsignal('nco_out_conj','filter',-1,nco.isOutputPortComplex,0,ncoall.vtype,ncoall.sltype);
        conjsignals=[conjsignals,makehdlsignaldecl(ncoconjsig)];


        ncorealconjbody=hdldatatypeassignment(ncocastsig,ncoconjsig,ncocastrounding,ncocastsaturation,'','real');
        [ncouminusbody,ncousignals]=hdlunaryminus(hdlsignalimag(ncocastsig),hdlsignalimag(ncoconjsig),'floor',0);
        conjbody=[conjbody,ncorealconjbody,ncouminusbody];
        conjsignals=[conjsignals,ncousignals];
        ncoouttoprod=ncoconjsig;
    else
        ncoouttoprod=ncocastsig;
    end

