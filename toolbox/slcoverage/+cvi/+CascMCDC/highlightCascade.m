function highlightCascade(memberBlocks)





    modelName=Simulink.ID.getModel(memberBlocks{1});
    try
        modelH=get_param(modelName,'Handle');
    catch %#ok<CTCH>
        modelH=[];
    end
    if isempty(modelH)
        try
            open_system(modelName);
        catch %#ok<CTCH>
            error(message('Slvnv:simcoverage:cvdisplay:LoadError',modelName));
        end
    end

    SlCov.CovStyle.selectObject(memberBlocks);
