function wireComp=getNFPReinterpretCastComp(hN,hInSignal,hOutSignal,compName,desc,slHandle)



    wireComp=hN.addComponent2(...
    'kind','nfpreinterpretcast',...
    'InputSignals',hInSignal,...
    'OutputSignals',hOutSignal,...
    'Name',compName);

    if nargin>=5
        wireComp.addComment(desc);
    end

    if nargin>=6
        wireComp.SimulinkHandle=slHandle;
    end
end
