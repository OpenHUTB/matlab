



function[values,labels]=GetUserDefinedEnumValueLabelPairs(enumClassName)
    values=[];
    labels={};

    metaclass=eval(sprintf('?%s',enumClassName));
    if isempty(metaclass)
        return;
    end

    enumList=metaclass.EnumerationMemberList;

    len=length(enumList);

    values=int32(zeros(len,1));
    labels=cell(len,1);

    for idx=1:length(enumList)
        label=enumList(idx).Name;
        values(idx,1)=...
        int32(eval(sprintf('%s.(label)',enumClassName)));
        labels{idx,1}=label;
    end
end
