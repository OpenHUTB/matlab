function openCoverageDetails(studio)







    if(nargin<1)
        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        studio=allStudios(1);
    end


    activeEditor=studio.App.getActiveEditor;
    activeModel=cvi.DockedReport.getSfLibInstanceParentModel();
    if isempty(activeModel)
        activeModel=get_param(activeEditor.blockDiagramHandle,'name');
    end
    modelH=get_param(activeModel,'handle');
    infrmObj=cvi.Informer.findInformer(modelH);
    if isempty(infrmObj)
        return;
    end

    dockedReports=infrmObj.getDockedReportsForStudio(studio);
    if isempty(dockedReports)

        covModes=infrmObj.reportManager.getCovModes();
        hasMultipleTypes=numel(covModes)>1;
        for i=1:numel(covModes)
            dockedReport=infrmObj.createDockedReport(studio,covModes{i},hasMultipleTypes);
            dockedReport.init();
        end
    else

        for i=1:numel(dockedReports)
            dockedReports(i).refreshContent();
            dockedReports(i).show();
        end
    end

end