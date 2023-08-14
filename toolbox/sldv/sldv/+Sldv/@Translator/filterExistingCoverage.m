function status=filterExistingCoverage(obj)




    status=true;
    obj.mTestComp.analysisInfo.covFilter=[];


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
            mdlName={getfullname(obj.mTestComp.analysisInfo.designModelH)};

            refMdls=sldvprivate('deriveInlinedModelBlocks',obj.mTestComp);
            if Sldv.CvApi.isFullCvData(obj.mStartCov,[mdlName,refMdls],...
                obj.mTestComp.analysisInfo.analyzedSubsystemH)
                status=false;
                obj.mfullCovAlreadyAcheived=true;
                obj.logAll(newline);
                obj.logAll(message('Sldv:GENCOV:AlreadyFullCoverage').getString);
                warning(message('Sldv:GENCOV:AlreadyFullCoverage'));
                obj.warnHalt(true);
                return;
            end
            obj.mTestComp.startCovData=obj.mStartCov;
        end
    end

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
