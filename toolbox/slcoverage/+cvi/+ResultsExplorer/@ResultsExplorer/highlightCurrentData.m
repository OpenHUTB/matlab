function highlightCurrentData(obj)




    curCovRootNode=obj.root.activeTree.root;
    if~isempty(curCovRootNode.aggregate())
        curCovRootNode.modelview();
    end


    SlCov.CoverageAPI.setActiveDataNeedsRegen(obj.topModelName);
