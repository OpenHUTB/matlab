function cjsPrepareForSubmission(job,jobSupport,jobSId)




    initdata=parallel.internal.apishared.JobInitData.getData(job);
    submitdatetime=datetime('now','TimeZone','local');
    state=parallel.internal.types.States.Queued;
    jobSupport.setJobProperties(jobSId,job.Variant,...
    {'ProductKeys','StateEnum','SubmitDateTime'},...
    {initdata,state,submitdatetime});
end
