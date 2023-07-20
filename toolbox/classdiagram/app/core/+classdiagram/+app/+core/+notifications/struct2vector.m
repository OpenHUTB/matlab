function targets=struct2vector(targetStruct)
    targetNames=fieldnames(targetStruct);
    targets=string.empty;
    for ii=1:numel(targetNames)
        fieldN=targetNames{ii};

        targets(ii)=getfield(targetStruct,fieldN);
    end
end