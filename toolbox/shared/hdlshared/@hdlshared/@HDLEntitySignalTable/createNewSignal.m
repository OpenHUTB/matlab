function[uname,index]=createNewSignal(...
    this,name,port,isComplex,...
    dims,vType,slType,rate,forward)



























    if nargin<8
        rate=0;
    end

    if nargin<9
        forward=0;
    end

    if length(dims)>1&&all(dims==[0,0])

        dims=0;
    end






    if port==-1
        port=[];
    end


    if(isComplex==1)

        [realSigName,imagSigName]=this.getUniqueComplexSignalName(name);

        uname=[realSigName,imagSigName];

        realSig=hdlshared.HDLEntitySignal(realSigName,'',port,...
        isComplex,dims,vType,slType,...
        rate,forward);

        index=this.addSignal(realSig);

        imagSig=hdlshared.HDLEntitySignal(imagSigName,'',port,...
        0,dims,vType,slType,...
        rate,forward);

        index2=this.addSignal(imagSig);


    else

        uname=this.getUniqueSignalName(name);

        signal=hdlshared.HDLEntitySignal(uname,'',port,...
        isComplex,dims,vType,...
        slType,rate,forward);

        index=this.addSignal(signal);

    end




