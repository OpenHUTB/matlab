function dockedReports=getDockedReportsForActiveStudio()




    dockedReports=[];
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(studios)
        activeStudio=studios(1);
        infrmObj=cvi.Informer.findInformer(activeStudio.App.blockDiagramHandle);
        if~isempty(infrmObj)
            dockedReports=infrmObj.getDockedReportsForStudio(activeStudio);
        end
    end
end