function out=getAllParameterMemorySections(sourceDD)










    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    paramCats=Utils.getParameterCategories();
    map=containers.Map;
    for i=1:length(paramCats)
        allowedMSs=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForElement(sourceDD,paramCats{i},'MemorySection');
        for j=1:length(allowedMSs)
            map(allowedMSs(j).Name)=allowedMSs(j);
        end
    end
    cellOut=values(map);
    out=[cellOut{:}];
end
