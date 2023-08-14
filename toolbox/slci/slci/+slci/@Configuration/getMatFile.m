function out=getMatFile(aObj)




    aObj.createReportFolder();
    out=fullfile(...
    aObj.getReportFolder,...
    [aObj.getModelName(),'_verification_results.mat']);




    out=slci.internal.ReportUtil.convertRelativeToAbsolute(out);
end

