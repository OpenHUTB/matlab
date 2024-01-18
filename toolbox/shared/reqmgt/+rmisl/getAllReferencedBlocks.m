function out=getAllReferencedBlocks(modelNames,libName,libSID)

    if isempty(modelNames)
        modelNames=getfullname(Simulink.allBlockDiagrams('model'));
        if~iscell(modelNames)
            modelNames={modelNames};
        end
    end
    out=[];
    libBlock=getfullname([libName,libSID]);
    for index=1:length(modelNames)
        cModelName=modelNames{index};

        [~,~,mapFromLibBlockToRefBlock]=rmisl.getLoadedLibraries(cModelName);
        if isKey(mapFromLibBlockToRefBlock,libBlock)
            out=[out;mapFromLibBlockToRefBlock(libBlock)];%#ok<AGROW>
        end
        break;
    end
end