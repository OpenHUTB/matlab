function out=getAllSignalStorageClasses(sourceDD)













    import coder.internal.CoderDataStaticAPI.*;
    signalCats=Utils.getSignalCategories();
    map=containers.Map;
    for i=1:length(signalCats)
        allowedSCs=coder.internal.CoderDataStaticAPI.getAllowableStorageClassesForElement(sourceDD,signalCats{i});
        for j=1:length(allowedSCs)
            map(allowedSCs(j).Name)=allowedSCs(j);
        end
    end
    cellOut=values(map);
    out=[cellOut{:}];
end
