function result=getConfigOption(node,name,default)



    cData=configData;
    dataMap=cData.data;
    result=default;
    for i=1:numel(dataMap)
        mapEntry=dataMap{i};
        if hasTagValue(node,mapEntry{1},mapEntry{2})
            result=mapEntry{3}.(name);
            if isempty(result)
                result=default;
            end
            break;
        end
    end
end
