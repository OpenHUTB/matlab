function minmaxComp=getMinMaxComp(hN,hInSignals,hOutSignals,...
    compName,opName,isDSPBlk,outputMode,isOneBased,desc,slbh,nfpOptions)











    if nargin<9
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end
    if nargin<10
        slbh=-1;
    end

    if nargin<9
        desc='';
    end

    if(nargin<8)
        isOneBased=true;
    end

    if(nargin<7)
        outputMode='Value';
    end

    if(nargin<6)
        isDSPBlk=false;
    end

    if(nargin<5)
        opName='min';
    end

    if(nargin<4)
        compName='minmax';
    end

    minmaxComp=hN.addComponent2(...
    'kind','minmax_comp',...
    'SimulinkHandle',slbh,...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OpName',opName,...
    'isDSPBlk',isDSPBlk,...
    'OutputMode',outputMode,...
    'isOneBased',isOneBased,...
    'BlockComment',desc,...
    'NFPLatency',nfpOptions.Latency);

end
