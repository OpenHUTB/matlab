function ret=hasMoreThanSpecifiedInputs(sumBlock,numInputs)


    ret=false;
    if isempty(sumBlock)
        return;
    end

    lineInports=sumBlock.LineHandles.Inport;
    if isempty(lineInports)
        return;
    end

    if length(lineInports)>numInputs
        ret=true;

    end
end