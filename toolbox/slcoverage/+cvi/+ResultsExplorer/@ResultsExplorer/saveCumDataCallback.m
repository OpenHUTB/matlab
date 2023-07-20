function saveCumDataCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)
        obj=node.parentTree.resultsExplorer;
        fileFilter={'*.cvt',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageDataFiles'));...
        '*.*',getString(message('Slvnv:simcoverage:cvresultsexplorer:AllFiles'))};
        title=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveCumData'));
        fullFileName=cvi.ResultsExplorer.ResultsExplorer.uiPutFile(fileFilter,title);
        cvd=node.data.getCvd;
        if~isempty(fullFileName)

            node.applyFilter;
            cvsave(fullFileName,cvd);
            data=obj.addCvData(cvd,fullFileName);
            obj.addToPassiveRoot(data);
            node.data.needSave=false;
            obj.ed.broadcastEvent('HierarchyChangedEvent',node.interface);
        end
    end
end