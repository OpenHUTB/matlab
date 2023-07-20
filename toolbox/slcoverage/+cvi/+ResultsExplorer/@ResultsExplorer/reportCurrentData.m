function reportCurrentData(obj)






    curCovRootNode=obj.root.activeTree.root;
    if~isempty(curCovRootNode.aggregate())
        curCovRootNode.createReport;
    end