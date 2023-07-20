function nilComp=getNilComp(hN,hInSignal,hOutSignal,compName,desc,slHandle)



    nilComp=hN.addComponent2(...
    'kind','annotation',...
    'InputSignals',hInSignal,...
    'OutputSignals',hOutSignal,...
    'Name',compName);

    if nargin>=5
        nilComp.addComment(desc);
    end

    if nargin>=6
        nilComp.SimulinkHandle=slHandle;
        if ishandle(slHandle)
            if strcmp(get_param(slHandle,'BlockType'),'Terminator')


                nilComp.setIsTerminator(true);
            end
            nilComp.setHasMask(strcmp(get_param(slHandle,'Mask'),'on'));
        end
    end
end


