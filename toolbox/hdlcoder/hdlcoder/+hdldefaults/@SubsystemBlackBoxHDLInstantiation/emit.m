function hdlcode=emit(this,hC)





    reporterrors(this,hC);

    isDefaultName=setEntityName(this,hC);

    fixPorts(this,hC);

    hdlcode=finishEmit(this,hC);



    if isDefaultName
        this.removeImplParam('EntityName');
    end



