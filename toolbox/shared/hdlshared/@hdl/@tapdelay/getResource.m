function getResource(this)




    numdelays=this.nDelays;

    sltype=hdlsignalsltype(this.outputs);
    [size,~,~]=hdlwordsize(sltype);

    cplx=hdlsignaliscomplex(this.outputs);

    resourceLog(size,(1+cplx)*numdelays,'reg');
