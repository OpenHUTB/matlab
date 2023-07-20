function status=setCovFilter(obj)




    status=true;

    try
        if obj.mFilterExistingCov&&...
            ~strcmp(obj.mTestComp.activeSettings.Mode,'PropertyProving')&&...
            strcmpi(obj.mTestComp.activeSettings.CovFilter,'on')&&...
            ~isempty(obj.mTestComp.activeSettings.CovFilterFileName)
            [status,filters,err]=sldvprivate('readFilterFiles',...
            obj.mTestComp.analysisInfo.designModelH,...
            obj.mTestComp.activeSettings.CovFilterFileName);

            if~status
                sldvshareprivate('avtcgirunsupcollect','push',obj.mTestComp.analysisInfo.designModelH,...
                'sldv',getString(err),err.Identifier);
                obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mTestComp.analysisInfo.designModelH);
                obj.logAll(sprintf('\n%s.\n',getString(err)));
                obj.errorHalt(true);
                return;
            end


            obj.mTestComp.analysisInfo.covFilter=Sldv.Filter.mergeInMemory(filters);
        end
    catch MEx
        status=0;
        obj.mErrorMsg=getString(message('Sldv:Setup:FailedLoadCoverageFilter',...
        obj.mTestComp.activeSettings.CovFilterFileName,MEx.message));
        obj.logAll(sprintf('\n%s.\n',obj.mErrorMsg));
        obj.errorHalt(true);
        return;
    end
end
