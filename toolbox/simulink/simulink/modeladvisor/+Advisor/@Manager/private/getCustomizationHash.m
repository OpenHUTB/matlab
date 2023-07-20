function hash=getCustomizationHash(slCustomizationDataStructure)










    hash=[num2str(slCustomizationDataStructure.CheckIDMap.size(1)),'A',...
    num2str(slCustomizationDataStructure.TaskAdvisorIDMap.size(1)),'B',...
    num2str(size(slCustomizationDataStructure.callbackFuncInfoStruct.CheckInfo,2)),'C',...
    num2str(size(slCustomizationDataStructure.callbackFuncInfoStruct.TaskInfo,2)),'D',...
    num2str(size(slCustomizationDataStructure.callbackFuncInfoStruct.ProcessCallbackInfo,2)),'E',...
    num2str(size(slCustomizationDataStructure.callbackFuncInfoStruct.TaskAdvisorInfo,2)),'F',...
    ];




    hash=[hash,hashKeys(slCustomizationDataStructure.CheckIDMap),'G',...
    hashKeys(slCustomizationDataStructure.TaskAdvisorIDMap)];

end

function hash=hashKeys(map)
    hash='';
    ids=map.keys();
    numHash=uint64(CGXE.Utils.md5([ids{:}]));

    for n=1:4
        hash=[hash,num2str(numHash(n))];%#ok<AGROW>
    end
end