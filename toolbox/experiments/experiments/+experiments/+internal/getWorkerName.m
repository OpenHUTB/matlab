function workerName=getWorkerName()

    workerName='';

    worker=getCurrentWorker;
    switch class(worker)
    case 'parallel.cluster.MJSWorker'
        workerName=worker.Name;
    case 'parallel.cluster.CJSWorker'
        workerName=[worker.Host,':',num2str(worker.ProcessId)];
    end

end

