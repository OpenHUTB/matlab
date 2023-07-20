function coverageInfo=manageCoverageInfoForCheckIssues(mode,~,varargin)



    mode=validatestring(mode,{'postrun','restore'});
    coverageInfo=[];

    switch mode
    case 'postrun'
        mexName=varargin{1};
        mexFile=which(mexName);
        if~isempty(mexFile)
            project=coder.internal.Project();
            props=project.getMexFcnProperties(mexFile);
            coverageInfo=props.CoverageInfo;
            coverageInfo=coder.internal.patchCoverageInfo(coverageInfo);
            clear(mexName);
        end
    case 'restore'
        dataManager=coder.internal.CoderGuiDataManager.getInstance();
        coverageInfo=dataManager.retrieveFromCache(...
        com.mathworks.toolbox.coder.app.CoderBuildType.CHECK_FOR_ISSUES,...
        dataManager.FIELD_COVERAGE);
    end
end