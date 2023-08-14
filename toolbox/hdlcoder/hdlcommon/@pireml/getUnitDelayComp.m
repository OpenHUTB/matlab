function delayComp=getUnitDelayComp(hN,hInSignals,hOutSignals,compName,initVal,resetnone,desc,slHandle)









    if(nargin<8)
        slHandle=-1;
    end

    if(nargin<7)
        desc='';
    end

    if(nargin<6)||isempty(resetnone)
        resetnone=false;
    end

    if(nargin<5)
        initVal='';
    end

    if(nargin<4)
        compName='reg';
    end

    [outdimlen,~]=pirelab.getVectorTypeInfo(hOutSignals(1));
    [indimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));

    if(outdimlen>1&&indimlen==1)

        hMuxOut=pirelab.scalarExpand(hN,hInSignals(1),outdimlen);
        hInSignals=hMuxOut;
    end

    if(isempty(initVal))
        initVal=pirelab.getTypeInfoAsFi(hInSignals.Type);
    else
        [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
        if(length(initVal)==1)
            initVal=repmat(initVal,1,dimlen);
        end
        initVal=reshape(initVal,1,dimlen);
        initVal=pirelab.getTypeInfoAsFi(hInSignals(1).Type,'Floor','Wrap',initVal);
    end


    delayComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'SimulinkHandle',slHandle,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_delay',...
    'EMLParams',{initVal},...
    'EMLFlag_RunLoopUnrolling',false,...
    'BlockComment',desc);


    delayComp.resetNone(resetnone);


    if targetmapping.isValidDataType(hInSignals(1).Type)
        delayComp.setSupportTargetCodGenWithoutMapping(true);
    end

end
