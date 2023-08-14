function propInpSigSpec(modelName)
    syssizes=[];
    try
        syssizes=feval(modelName,[],[],[],'compile');
    catch ME


    end
    if~isempty(syssizes)
        feval(modelName,[],[],[],'term');
    end
end
