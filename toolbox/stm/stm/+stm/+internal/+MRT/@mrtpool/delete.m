function delete(obj)




    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));
    workers=obj.getWorkers();
    for k=1:length(workers)
        obj.deleteWorker(workers(k).id);
    end
    try
        delete(fullfile(obj.poolRoot,'*.started'));
        delete(fullfile(obj.poolRoot,'*.running'));
    catch
    end
end
