function errorHandler(h,hookPoint,modelName,rtwroot,tmf,buildOpts,...
    buildArgs,buildInfo)




    if(~isempty(h.ProjectMgr))
        h.ProjectMgr.error([],[],[],[],[],[]);
    end
