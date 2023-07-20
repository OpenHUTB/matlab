function inputGroupInfos=getInputGroupInfos(inputGroupIds,id2GroupInfo)







    inputGroupInfos=cell(size(inputGroupIds));
    for i=1:length(inputGroupIds)
        id=inputGroupIds{i};
        inputGroupInfos{i}=id2GroupInfo(id);
    end
end

