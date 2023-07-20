function getResource(this)




    numdelays=this.nDelays;

    for i=1:length(this.outputs)
        sltype=hdlsignalsltype(this.outputs(i));
        [size,~,~]=hdlwordsize(sltype);

        cplx=hdlsignaliscomplex(this.outputs(i));

        resourceLog(size,(1+cplx)*numdelays,'reg');
    end