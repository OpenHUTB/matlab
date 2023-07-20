function cgirComp=getFromComp(hN,hOutSignals,tagName,tagScope,compName,desc,slHandle)









    if(nargin<4)
        tagScope='ntwk_global';
    end

    if(nargin<5)
        compName=[tagName,'_from'];
    end

    if(nargin<6)
        desc='';
    end

    if(nargin<7)
        slHandle=-1;
    end


    fromSigInst=hN.addSignal2(...
    'name',tagName,...
    'type',hOutSignals.type,...
    'isglobal',true,...
    'signalscope',tagScope,...
    'simulinkrate',hOutSignals.SimulinkRate);

    cgirComp=pirelab.getWireComp(hN,fromSigInst,hOutSignals,compName,desc,slHandle);

end
