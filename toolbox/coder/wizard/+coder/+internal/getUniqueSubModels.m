function[modelList,varargout]=getUniqueSubModels(modelName)












    assert(bdIsLoaded(modelName));

    normalMode=get_param(modelName,'ModelRefsNormal');


    mdlRefsAccel=get_param(modelName,'ModelRefsAccel');
    if~isempty(mdlRefsAccel)
        allAccelRefs=[mdlRefsAccel.unprotected';mdlRefsAccel.protected'];
    else
        allAccelRefs=[];
    end
    modelList=unique([normalMode;allAccelRefs]);

    if nargout==2

        if isempty(mdlRefsAccel)
            varargout{1}=[];
        else
            varargout{1}=mdlRefsAccel.protected;
        end
    end
end