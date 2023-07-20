function cgirComp=getGotoComp(hN,hInSignals,tagName,tagScope,compName,desc,slHandle)









    if(nargin<4)
        tagScope='ntwk_global';
    end

    if(nargin<5)
        compName=[tagName,'_goto'];
    end

    if(nargin<6)
        desc='';
    end

    if(nargin<7)
        slHandle=-1;
    end


    gotoSigInst=hN.addSignal2(...
    'name',tagName,...
    'type',hInSignals.type,...
    'isglobal',true,...
    'signalscope',tagScope,...
    'simulinkrate',hInSignals.SimulinkRate);

    cgirComp=pirelab.getWireComp(hN,hInSignals,gotoSigInst,compName,desc,slHandle);

end

