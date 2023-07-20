function status=setInputCovData(obj)




    status=true;
    if obj.mFilterExistingCov&&...
        strcmp(obj.mTestComp.activeSettings.Mode,'TestGeneration')

        if isempty(obj.mStartCov)&&...
            strcmp(obj.mTestComp.activeSettings.IgnoreCovSatisfied,'on')
            covFileName=obj.mTestComp.activeSettings.CoverageDataFile;
            obj.logNewLines(getString(message('Sldv:Setup:ReadingCoverageFile',covFileName)));
            [status,obj.mStartCov,err]=Sldv.CvApi.getCumulativeCovData(covFileName);
            if~status
                sldvshareprivate('avtcgirunsupcollect','push',obj.mTestComp.analysisInfo.designModelH,...
                'sldv',getString(err),err.Identifier);
                obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mTestComp.analysisInfo.designModelH);
                obj.logAll(sprintf('\n%s.\n',getString(err)));
                obj.errorHalt(true);
                return;
            end
        end

        if~isempty(obj.mStartCov)

            obj.mStartCov=Sldv.CvApi.sumCvData(obj.mStartCov);
            obj.mTestComp.startCovData=obj.mStartCov;
        end
    end
end
