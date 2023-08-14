classdef StudioAppSLDDListener<handle





    methods(Access=public,Static)
        function observeChanges(dictImpl,changesReport)
            ddFilePath=dictImpl.getDictionaryFilePath();
            studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(ddFilePath);


            changesReportObj=sl.interface.dictionaryApp.observer.SLDDChangesReport(changesReport);
            studioApp.refreshList(changesReportObj);
        end
    end
end


