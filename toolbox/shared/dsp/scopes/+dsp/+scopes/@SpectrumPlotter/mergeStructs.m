function mergedStruct=mergeStructs(defaultStruct,newStruct)



    mergedStruct=defaultStruct;
    if~isempty(newStruct)
        fNames=fieldnames(newStruct);
        for fInd=1:length(fNames)
            fName=fNames{fInd};
            mergedStruct.(fName)=newStruct.(fName);
        end
    end
end
