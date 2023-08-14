function indexPortEntries=getIndexPortEntries(blockH,param)
    IndexOptionArray=get_param(blockH,'IndexOptionArray');

    indexPortEntries=false(1,length(IndexOptionArray));
    for i=1:length(IndexOptionArray)
        if strcmp(IndexOptionArray{i},'Index vector (port)')
            indexPortEntries(i)=true;
        end
    end
end
