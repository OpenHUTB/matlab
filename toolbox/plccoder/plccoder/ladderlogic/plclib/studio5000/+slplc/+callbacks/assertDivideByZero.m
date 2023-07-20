function assertDivideByZero(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end

    parentPOUBlock=slplc.utils.getParentPOU(block);
    fprintf('Divide by zero detected : %s',...
    parentPOUBlock);
end
