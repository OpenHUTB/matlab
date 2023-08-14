function muxComp=getMuxComp(hN,hInSignals,hOutSignal,compName)



    if nargin<4
        compName=sprintf('%s_mux',hOutSignal(1).Name);
    end

    numIns=length(hInSignals);
    numScalarIns=0;
    for ii=1:numIns
        [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(ii));
        numScalarIns=numScalarIns+dimlen;
    end

    if numScalarIns==1
        muxComp=pirelab.getWireComp(hN,hInSignals,hOutSignal,compName);
    else
        hScalarIns=hdlhandles(numScalarIns,1);
        currIndex=1;
        for ii=1:numIns
            [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(ii));
            if dimlen>1
                hScalarIns(currIndex:(currIndex+dimlen-1))=pirelab.demuxSignal(hN,hInSignals(ii));
            else
                hScalarIns(currIndex)=hInSignals(ii);
            end
            currIndex=currIndex+dimlen;
        end

        muxComp=hN.addComponent2(...
        'kind','concat',...
        'name',compName,...
        'InputSignals',hScalarIns,...
        'OutputSignals',hOutSignal);


        if targetmapping.isValidDataType(hInSignals(1).Type)
            muxComp.setSupportTargetCodGenWithoutMapping(true);
        end
    end
