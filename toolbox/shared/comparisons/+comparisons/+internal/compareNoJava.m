function wasHandled=compareNoJava(jComparisonDefinition)




    wasHandled=false;
    adapter=comparisons.internal.util.JComparisonDefinitionAdapter(jComparisonDefinition);

    warningCleanup=disableWarningBacktrace();

    if(adapter.isTwoWayDiff()||adapter.isTwoWayMerge())
        wasHandled=handleNoJavaDiff(adapter);
    elseif(adapter.isThreeWayMerge())
        wasHandled=handleNoJavaMerge3(adapter);
    end

end

function cleanup=disableWarningBacktrace()
    backtraceStartState=warning('backtrace','off');
    cleanup=onCleanup(@()warning(backtraceStartState));
end

function handled=handleNoJavaDiff(adapter)
    handled=handleTwoWay(...
    adapter,...
    "DiffGUIProviders",...
    comparisons.internal.makeJavaOptions(adapter)...
    );
end

function handled=handleTwoWay(adapter,providerList,options)
    try
        handled=handleTwoWayImpl(adapter,providerList,options);
    catch ME
        throwAsCaller(ME);
    end
end

function handled=handleTwoWayImpl(adapter,providerList,options)
    [leftSource,rightSource,twoWayOpts]=makeTwoWayArgs(adapter);
    options.twoWayOptions=twoWayOpts;

    args={leftSource,rightSource,options};
    app=comparisons.internal.dispatchToProvider(providerList,args);

    handled=~isempty(app);
    if handled
        comparisons.internal.appstore.register(app);
    end
end

function[leftSource,rightSource,twoWayOpts]=makeTwoWayArgs(adapter)
    if isCompareToAncestorOrRevisionWorkflow(adapter)
        [leftSource,rightSource,twoWayOpts]=...
        makeArgsForCompareToAncestorOrRevisionWorkflows(adapter);
    elseif isTwoWayViewConflictsWorkflow(adapter)
        [leftSource,rightSource,twoWayOpts]=...
        makeArgsForTwoWayViewConflictsWorkflow(adapter);
    else
        [leftSource,rightSource,twoWayOpts]=...
        makeArgsForNonSCMRelatedWorkflows(adapter);
    end
end

function bool=isCompareToAncestorOrRevisionWorkflow(adapter)
    bool=adapter.hasSCMDiffData();
end

function bool=isTwoWayViewConflictsWorkflow(adapter)
    bool=adapter.hasSCMMergeData()&&adapter.isTwoWayMerge();
end

function[leftSource,rightSource,options]=makeArgsForCompareToAncestorOrRevisionWorkflows(adapter)
    import comparisons.internal.util.makeFileSourceFromJFileInformation
    jSCMDiffData=adapter.getSCMDiffData();
    jLeftFileInfo=jSCMDiffData.getLeftRevisionFileInformation();
    leftSource=makeFileSourceFromJFileInformation(jLeftFileInfo);
    jRightFileInfo=jSCMDiffData.getRightRevisionFileInformation();
    rightSource=makeFileSourceFromJFileInformation(jRightFileInfo);

    if(mergingDisabled(adapter))
        mergeConfig=comparisons.internal.merge.DisableMerge();
    else
        mergeConfig=comparisons.internal.merge.MergeIntoRight();
    end

    options=comparisons.internal.makeTwoWayOptions(...
    EnableSwapSides=mergingDisabled(adapter),...
    Type=adapter.getType(),...
    MergeConfig=mergeConfig...
    );
end

function bool=mergingDisabled(adapter)
    bool=adapter.hasAllowMerge()&&~adapter.getAllowMerge();
end

function[leftSource,rightSource,options]=makeArgsForTwoWayViewConflictsWorkflow(adapter)
    import comparisons.internal.util.makeFileSourceFromJFileInformation
    jSCMMergeData=adapter.getSCMMergeData();
    jMineFileInfo=jSCMMergeData.getMineFileInformation();
    rightSource=makeFileSourceFromJFileInformation(jMineFileInfo);
    jTheirsFileInfo=jSCMMergeData.getTheirsFileInformation();
    leftSource=makeFileSourceFromJFileInformation(jTheirsFileInfo);

    options=makeTwoWayOptionsForTwoWayViewConflictsWorkflow(adapter);
end

function options=makeTwoWayOptionsForTwoWayViewConflictsWorkflow(adapter)
    options=comparisons.internal.makeTwoWayOptions(...
    EnableSwapSides=false,...
    MergeConfig=makeSCMMergeConfigFromJSCMMergeData(adapter.getSCMMergeData()),...
    Type=adapter.getType()...
    );
end

function scmMergeConfig=makeSCMMergeConfigFromJSCMMergeData(jSCMMergeData)
    import comparisons.internal.util.makeFileSourceFromJFileInformation
    jTargetFileInfo=jSCMMergeData.getTargetFileInformation();
    targetSource=makeFileSourceFromJFileInformation(jTargetFileInfo);
    callback=extractJavaMarkConflictsResolvedCallback(jSCMMergeData);
    scmMergeConfig=comparisons.internal.merge.SCMConflicts(targetSource.Path,callback);
end

function callback=extractJavaMarkConflictsResolvedCallback(jSCMMergeData)
    jCallback=jSCMMergeData.getPostMergeAction();
    jProgController=com.mathworks.toolbox.shared.computils.progress.NullProgressController();
    jNull=[];
    jNullProgTask=jProgController.startTask(jNull);

    callback=@()jCallback.execute(jNullProgTask);
end

function[leftSource,rightSource,options]=makeArgsForNonSCMRelatedWorkflows(adapter)
    leftSource=comparisons.internal.makeFileSource(adapter.getLeftPath());
    rightSource=comparisons.internal.makeFileSource(adapter.getRightPath());

    if(mergingDisabled(adapter))
        mergeConfig=comparisons.internal.merge.DisableMerge();
    else
        mergeConfig=comparisons.internal.merge.ShowDialog();
    end

    options=comparisons.internal.makeTwoWayOptions(...
    EnableSwapSides=true,...
    MergeConfig=mergeConfig,...
    Type=adapter.getType()...
    );
end

function handled=handleNoJavaMerge3(adapter)
    try
        handled=handleThreeWayMergeImpl(adapter);
    catch ME
        throwAsCaller(ME);
    end
end

function handled=handleThreeWayMergeImpl(adapter)
    [theirsSource,baseSource,mineSource,threeWayOpts]=makeArgsForThreeWayViewConflictsWorkflow(adapter);
    options=comparisons.internal.makeJavaOptions(adapter);
    options.threeWayOptions=threeWayOpts;

    argsThree={theirsSource,baseSource,mineSource,options};
    app=comparisons.internal.dispatchToProvider("Merge3GUIProviders",argsThree);

    handled=~isempty(app);
    if handled
        comparisons.internal.appstore.register(app);
        return;
    end

    options.twoWayOptions=makeTwoWayOptionsForTwoWayViewConflictsWorkflow(adapter);
    argsTwo={theirsSource,mineSource,options};
    app=comparisons.internal.dispatchToProvider("DiffGUIProviders",argsTwo);

    handled=~isempty(app);
    if handled
        comparisons.internal.appstore.register(app);
    end
end

function[theirsSource,baseSource,mineSource,options]=makeArgsForThreeWayViewConflictsWorkflow(adapter)
    import comparisons.internal.util.makeFileSourceFromJFileInformation
    jSCMMergeData=adapter.getSCMMergeData();
    jBaseFileInfo=jSCMMergeData.getBaseFileInformation();
    baseSource=makeFileSourceFromJFileInformation(jBaseFileInfo);
    jMineFileInfo=jSCMMergeData.getMineFileInformation();
    mineSource=makeFileSourceFromJFileInformation(jMineFileInfo);
    jTheirsFileInfo=jSCMMergeData.getTheirsFileInformation();
    theirsSource=makeFileSourceFromJFileInformation(jTheirsFileInfo);

    options=comparisons.internal.makeThreeWayOptions(...
    MergeConfig=makeSCMMergeConfigFromJSCMMergeData(jSCMMergeData),...
    Type=adapter.getType()...
    );
end