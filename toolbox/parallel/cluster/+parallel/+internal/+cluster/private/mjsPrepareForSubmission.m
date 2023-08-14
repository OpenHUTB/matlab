function mjsPrepareForSubmission(job,jobAccess,jobUUID)




    initdata=parallel.internal.apishared.JobInitData.getData(job);
    jobAccess.setProductList(jobUUID,initdata);
end
