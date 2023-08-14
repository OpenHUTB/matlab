function mjsPrepareForSubmission2(job,access,jobSID)




    initdata=parallel.internal.apishared.JobInitData.getData(job);
    access.setJobProperties(jobSID,'ProductKeys',initdata);
end
