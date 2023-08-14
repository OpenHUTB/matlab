function modelview(obj)




    cvd=obj.data.getCvd;

    explorer=obj.getExplorer;

    if obj.isActiveRoot
        obj.applyFilter;
    end

    try
        options=cvi.CvhtmlSettings(explorer.topModelName);
        options.modelDisplay=1;
        options.explorerGeneratedHighlight=true;
        if~isempty(explorer.filterExplorer)
            options.setFilterCtxId(explorer.uuid,'cvmodelview');
        end

        cvmodelview(cvd,options);

        explorer.highlightChange(obj,true);
    catch
        warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:HighlightErrorDueToModelChange')),...
        getString(message('Slvnv:simcoverage:cvresultsexplorer:Highlight')),'modal');
    end