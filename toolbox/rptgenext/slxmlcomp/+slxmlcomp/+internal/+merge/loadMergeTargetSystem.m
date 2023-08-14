function loadMergeTargetSystem(jMergeActionData)




    import slxmlcomp.internal.highlight.window.BDInfo
    targetBDInfo=BDInfo.fromMergeActionDataTarget(jMergeActionData);
    targetBDInfo.ensureLoaded();
end
