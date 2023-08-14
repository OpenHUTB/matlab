function getResource(this)




    numdelays=1;

    for i=1:length(this.outputs)
        sltype=hdlsignalsltype(this.outputs(i));
        [size,~,~]=hdlwordsize(sltype);

        vec=hdlsignalvector(this.outputs(i));
        vecsize=max(max(vec(:)),1);

        cplx=hdlsignaliscomplex(this.outputs(i));

        resourceLog(size,(1+cplx)*vecsize*numdelays,'reg');
    end