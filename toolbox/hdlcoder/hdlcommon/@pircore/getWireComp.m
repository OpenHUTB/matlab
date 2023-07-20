function wireComp=getWireComp(hN,hInSignal,hOutSignal,compName,desc,slHandle)




    rate1=hInSignal.SimulinkRate;
    rate2=hOutSignal.SimulinkRate;
    if~isinf(rate1)&&~isinf(rate2)&&...
        rate1>0.0&&rate2>0.0&&rate1~=rate2
        wireComp=pircore.getRepeatComp(hN,hInSignal,hOutSignal,int32(rate1/rate2),compName);
    else

        wireComp=hN.addComponent2(...
        'kind','buffer',...
        'InputSignals',hInSignal,...
        'OutputSignals',hOutSignal,...
        'Name',compName);
    end

    if targetmapping.isValidDataType(hInSignal.Type)
        wireComp.setSupportTargetCodGenWithoutMapping(true);
    end

    if nargin>=5
        wireComp.addComment(desc);
    end

    if nargin>=6
        wireComp.SimulinkHandle=slHandle;
    end
end
