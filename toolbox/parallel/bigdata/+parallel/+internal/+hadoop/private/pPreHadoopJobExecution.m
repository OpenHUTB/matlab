




function pPreHadoopJobExecution(job)

    initData=job.Info.InitData;
    parallel.internal.apishared.JobInitData.setData(job,initData);