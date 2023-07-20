function getResource(this)




    avec=hdlsignalvector(this.inputs(1));
    avecsize=max(max(avec(:)),1);
    asltype=hdlsignalsltype(this.inputs(1));
    [asize,~,~]=hdlwordsize(asltype);
    acplx=hdlsignaliscomplex(this.inputs(1));

    bvec=hdlsignalvector(this.inputs(2));
    bvecsize=max(max(bvec(:)),1);
    bsltype=hdlsignalsltype(this.inputs(2));
    [bsize,~,~]=hdlwordsize(bsltype);
    bcplx=hdlsignaliscomplex(this.inputs(2));

    mvec=hdlsignalvector(this.outputs(1));
    mvecsize=max(max(mvec(:)),1);
    mcplx=hdlsignaliscomplex(this.outputs(1));
    [~,~,~,~,msltype]=hdl.muldt(this.inputs(1),this.inputs(2));
    [msize,~,~]=hdlwordsize(msltype);

    indelay=this.inputpipelevels;
    outdelay=this.outputpipelevels;


    if indelay>0
        resourceLog(asize,(1+acplx)*avecsize*indelay,'reg');
        resourceLog(bsize,(1+bcplx)*bvecsize*indelay,'reg');
    end


    if outdelay>0
        resourceLog(msize,(1+mcplx)*mvecsize*outdelay,'reg');
    end


    for i=1:2^(acplx+bcplx)
        resourceLog(min(asize,bsize),max(asize,bsize),'mul');
    end