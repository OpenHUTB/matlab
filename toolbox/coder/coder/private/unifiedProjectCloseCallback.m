

function xilActive=unifiedProjectCloseCallback(guiState,javaConfig)





    finallyCleanup=onCleanup(@doEssentialCleanup);

    coder.internal.F2FGuiCallbackManager.saveAndCleanup(guiState.getFixedPointState());

    import com.mathworks.toolbox.coder.app.CoderBuildType;
    import com.mathworks.toolbox.coder.app.BulkGuiState;
    import com.mathworks.toolbox.coder.plugin.Utilities;

    manager=coder.internal.CoderGuiDataManager.getInstance();

    if~isempty(guiState.getCheckForIssuesLog())

        buildType=CoderBuildType.CHECK_FOR_ISSUES;
        resultStruct=manager.retrieveFromCache(buildType,manager.FIELD_TEST_OUTPUT);

        if~isempty(resultStruct)
            resultStruct.log=char(guiState.getCheckForIssuesLog());
            manager.setGuiTestOutput(javaConfig,buildType,resultStruct);
        end
    end

    if Utilities.isPilSilBuild(javaConfig)
        wrapperPath=Utilities.getXilWrapperFile(javaConfig);
        [~,mexFiles]=inmem('-completenames');
        xilActive=any(ismember(mexFiles,char(wrapperPath.getAbsolutePath())));
    else
        xilActive=false;
    end

    manager.cacheDataForGui(javaConfig);
end

function doEssentialCleanup()
    coder.internal.CoderGuiDataManager.getInstance().reset();
    coderProjectCloseCallback();
end