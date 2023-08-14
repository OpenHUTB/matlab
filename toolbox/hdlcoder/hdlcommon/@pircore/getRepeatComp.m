function rateChangeComp=getRepeatComp(hN,hInSignal,hOutSignal,repetitionCount,compName,desc,slHandle)



    rateChangeComp=hN.addComponent2(...
    'kind','ratechange',...
    'InputSignals',hInSignal,...
    'OutputSignals',hOutSignal,...
    'RepetitionCount',repetitionCount,...
    'Name',compName);

    if nargin>=6
        rateChangeComp.addComment(desc);
    end

    if nargin>=7
        rateChangeComp.SimulinkHandle=slHandle;
    end

end
