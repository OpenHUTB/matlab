function status=fullCoverageAcheived(obj)




    status=false;
    if~isempty(obj.mStartCov)&&strcmp(obj.mTestComp.activeSettings.Mode,'TestGeneration')

        mdlName={getfullname(obj.mTestComp.analysisInfo.designModelH)};

        refMdls=sldvprivate('deriveInlinedModelBlocks',obj.mTestComp);
        if Sldv.CvApi.isFullCvData(obj.mStartCov,[mdlName,refMdls],...
            obj.mTestComp.analysisInfo.analyzedSubsystemH)
            status=true;
            obj.mfullCovAlreadyAcheived=true;
            obj.logAll(newline);
            obj.logAll(message('Sldv:GENCOV:AlreadyFullCoverage').getString);
            warning(message('Sldv:GENCOV:AlreadyFullCoverage'));
            obj.warnHalt(true);
            return;
        end
    end
end
