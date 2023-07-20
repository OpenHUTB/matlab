function out=getAllParameterStorageClasses(sourceDD)










    import coder.internal.CoderDataStaticAPI.*;
    paramCats=Utils.getParameterCategories();
    map=containers.Map;
    for i=1:length(paramCats)
        allowedSCs=coder.internal.CoderDataStaticAPI.getAllowableStorageClassesForElement(sourceDD,paramCats{i});
        for j=1:length(allowedSCs)
            map(allowedSCs(j).Name)=allowedSCs(j);
        end
    end
    cellOut=values(map);
    out=[cellOut{:}];
end
