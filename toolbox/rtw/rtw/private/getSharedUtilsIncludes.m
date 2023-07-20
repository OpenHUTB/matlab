function returnStruct=getSharedUtilsIncludes(suInfo,suChecksum)








    [incList,dirStruct]=coder.internal.modelRefUtil(suInfo.modelName,...
    'getHeadFileList',suInfo);


    [~,idx]=setdiff(incList,{suInfo.IncludeFile});
    incList=incList(sort(idx));




    if isempty(suInfo.excludedHeaderFiles)
        excludedList={};
    else
        excludedList=cellstr(suInfo.excludedHeaderFiles);
    end
    if(exist(suChecksum,'file')==2)
        savedList=load(suChecksum);
        excludedList=RTW.unique({excludedList{:},savedList.suInfo.excludedList{:}});%#ok
    end
    [~,idx]=setdiff(incList,excludedList);
    incList=incList(sort(idx));

    fullList=RTW.unique({incList{:}});%#ok

    returnStruct.incList=incList;
    returnStruct.excludedList=excludedList;

    if(exist(suChecksum,'file')==2)
        returnStruct.savedList=savedList;
    end
    returnStruct.fullList=fullList;
    returnStruct.dirStruct=dirStruct;
end


