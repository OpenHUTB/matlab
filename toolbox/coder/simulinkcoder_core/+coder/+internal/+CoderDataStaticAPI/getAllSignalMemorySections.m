
function out=getAllSignalMemorySections(sourceDD)












    import coder.internal.CoderDataStaticAPI.*;
    signalCats=Utils.getSignalCategories();
    map=containers.Map;
    for i=1:length(signalCats)
        allowedMSs=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForElement(sourceDD,signalCats{i},'MemorySection');
        for j=1:length(allowedMSs)
            map(allowedMSs(j).Name)=allowedMSs(j);
        end
    end
    cellOut=values(map);
    out=[cellOut{:}];
end

