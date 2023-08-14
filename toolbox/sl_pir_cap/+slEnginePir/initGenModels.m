function[xformed_mdl,loadedModels]=initGenModels(m2m_dir,refBlocksModels,mdlName,linkedblks,prefix,mdls,updatelibrarylink)




    if nargin<7
        updatelibrarylink=false;
    end

    if exist(m2m_dir,'dir')==0
        mkdir(m2m_dir);
    end

    loadedModels={};
    for m=1:length(mdls)
        if~strcmpi(mdls{m},'simulink')
            validBackupModelName=slEnginePir.util.getBackupModelName(prefix,mdls{m});

            close_system(validBackupModelName,0);
            mdlfullname=which(mdls{m});

            if isempty(mdlfullname)
                continue;
            end

            [~,~,ext]=fileparts(mdlfullname);

            if exist([m2m_dir,validBackupModelName,ext],'file')==2
                delete([m2m_dir,validBackupModelName,ext]);
            end

            copyfile(mdlfullname,[m2m_dir,validBackupModelName,ext],'f');
            fileattrib([m2m_dir,validBackupModelName,ext],'+w');
            backupModelPath=[m2m_dir,validBackupModelName];
            if~bdIsLoaded(validBackupModelName)
                load_system(backupModelPath);
                loadedModels=[loadedModels;{validBackupModelName}];
            end

            if~strcmpi(get_param(validBackupModelName,'BlockDiagramType'),'library')
                backupModelTempName=slEnginePir.util.getTemporaryModelName(prefix,mdls{m});
                copyfile(mdlfullname,[m2m_dir,backupModelTempName,ext],'f');
                fileattrib([m2m_dir,backupModelTempName,ext],'+w');
                backupModelTempPath=[m2m_dir,backupModelTempName];
                if~bdIsLoaded(backupModelTempName)
                    load_system(backupModelTempPath);
                    loadedModels=[loadedModels;{backupModelTempName}];
                end
            end
            if strcmpi(get_param(validBackupModelName,'BlockDiagramType'),'library')
                set_param(validBackupModelName,'lock','off');
            end
        end
    end

    reflen=length(refBlocksModels);
    for m=1:reflen


        refBlockValidPath=slEnginePir.util.getValidBlockPath(prefix,refBlocksModels(m).block);
        refModelName=refBlocksModels(m).refmdl{1};
        refModelValidName=slEnginePir.util.getBackupModelName(prefix,refModelName);



        set_param(refBlockValidPath,'ModelName',refModelValidName);

        currentModelName=bdroot(refBlockValidPath);
        if reflen>=m+1
            refBlockValidPathNext=slEnginePir.util.getValidBlockPath(prefix,refBlocksModels(m+1).block);

            nextModelName=bdroot(refBlockValidPathNext);
            if~strcmp(currentModelName,nextModelName)
                save_system(currentModelName);
            end
        end
    end
    if reflen>=1
        save_system(currentModelName);
    end

    xformed_mdl=slEnginePir.util.getBackupModelName(prefix,mdlName);


    if updatelibrarylink
        for ii=1:length(linkedblks)
            linked_blk=linkedblks(ii).block;
            reference_blk=get_param(linked_blk,'ReferenceBlock');




            tlinkdata=get_param(slEnginePir.util.getValidBlockPath(prefix,linked_blk),'LinkData');
            slEnginePir.updateBlock(slEnginePir.util.getValidBlockPath(prefix,linked_blk),...
            slEnginePir.util.getValidBlockPath(prefix,reference_blk));
            if~isempty(tlinkdata)
                set_param(slEnginePir.util.getValidBlockPath(prefix,linked_blk),...
                'LinkData',tlinkdata);
            end
        end
    end
end
