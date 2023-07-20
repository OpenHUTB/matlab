function[loaded,dirty,harness,running]=findBlockDiagrams()





    dirty=Simulink.ModelManagement.Project.Dependency.getDirtyFiles;
    loaded={};
    harness={};
    running={};

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        if isSimulinkStarted
            bds=Simulink.allBlockDiagrams();
            names=i_getFileNamesOrNames(bds);


            loaded=names(strcmp(get_param(bds,'IsHarness'),'off'));


            harness=names(strcmp(get_param(bds,'IsHarness'),'on'));


            running=names(~strcmp(get_param(bds,'SimulationStatus'),'stopped'));
        end


        dictionaries=Simulink.ModelManagement.Project.FileHandler.updateDataDictionaryLoadedFileList;
        loaded=[loaded;dictionaries(:,2)];
        dirty=[dirty;dictionaries([dictionaries{:,3}],2)];
    end

end

function names=i_getFileNamesOrNames(bds)

    names=cellstr(get_param(bds,'FileName'));
    emptyIdx=cellfun(@isempty,names);
    names(emptyIdx)=cellstr(get_param(bds(emptyIdx),'Name'));
end
