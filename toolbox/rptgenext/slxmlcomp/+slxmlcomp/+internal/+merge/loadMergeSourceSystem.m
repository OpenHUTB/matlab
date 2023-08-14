function loadMergeSourceSystem(jMergeActionData)




    import slxmlcomp.internal.highlight.window.BDInfo
    targetBDInfo=BDInfo.fromMergeActionDataSource(jMergeActionData);
    targetBDInfo.ensureLoaded();
end
