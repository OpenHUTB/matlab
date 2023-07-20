function importParallelRunResults(obj)
    if exist(obj.mdladvObj.Database.FileLocation,'file')
        obj.mdladvObj.Database.loadMASessionData('Check');
        obj.mdladvObj.Database.loadMASessionData('TaskAdvisor');

        obj.mdladvObj.Database.overwriteLatestData('ParallelInfo','index',int32(0),...
        'orderedTaskIndex',int32(0),'cancel',int32(0),...
        'status',{''});
    end
