function[libList,ownerBlocksToLibBlock,mapFromLibBlockToRefBlock]=getLoadedLibraries(modelName)






    if ishandle(modelName)
        modelName=getfullname(modelName);
    end


    mapFromLibBlockToRefBlock=containers.Map('KeyType','char','ValueType','any');
    libNames=containers.Map('KeyType','char','ValueType','logical');

    ownerBlocksToLibBlock=containers.Map('KeyType','char','ValueType','char');
    modelPath=get_param(modelName,'Filename');
    filestatus=exist(modelPath,'File');
    if(filestatus~=4&&filestatus~=2)||hasMdlLibLoaded()




        allLibs=libinfo(modelName);

        for index=1:length(allLibs)
            cLib=allLibs(index);
            if~strcmpi(cLib.Library,'simulink')
                libName=cLib.Library;
                if dig.isProductInstalled('Simulink')&&bdIsLoaded(libName)
                    libNames(libName)=true;
                    ownerBlock=cLib.Block;
                    refPath=cLib.ReferenceBlock;
                    ownerBlocksToLibBlock(ownerBlock)=refPath;
                end

            end
        end
    else


        modelInfo=Simulink.MDLInfo(modelPath);

        if~isempty(modelInfo.Interface)
            allExternalFiles=modelInfo.Interface.ExternalFileReference;
            for index=1:length(allExternalFiles)
                cFile=allExternalFiles(index);
                if strcmpi(cFile.Type,'Library_Link')
                    libName=strtok(cFile.Reference,'/');
                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(libName)
                        libNames(libName)=true;
                        ownerBlock=cFile.Path;
                        refPath=cFile.Reference;
                        ownerBlocksToLibBlock(ownerBlock)=refPath;
                    end
                end
            end
        end
    end

    libList=libNames.keys;

    if nargout>2
        allOwnerBlocks=ownerBlocksToLibBlock.keys;
        for index=1:length(allOwnerBlocks)
            cOwnerBlock=allOwnerBlocks{index};

            ownerBlockHandle=getSimulinkBlockHandle(cOwnerBlock);
            if ownerBlockHandle==-1
                continue;
            end
            try
                ownerBlockType=get_param(ownerBlockHandle,'blocktype');
            catch ex %#ok<NASGU>
                continue;
            end

            if strcmpi(ownerBlockType,'subsystem')&&~slprivate('is_stateflow_based_block',ownerBlockHandle)
                findOptions=Simulink.FindOptions('FollowLinks',true,'LoadFullyIfNeeded',false);
                allBlockUnderOwnerBlock=[Simulink.findBlocks(ownerBlockHandle,findOptions);ownerBlockHandle];
            else
                allBlockUnderOwnerBlock=ownerBlockHandle;
            end

            for bIndex=1:length(allBlockUnderOwnerBlock)
                cBlock=allBlockUnderOwnerBlock(bIndex);
                libBlock=get_param(cBlock,'ReferenceBlock');
                if isKey(mapFromLibBlockToRefBlock,libBlock)
                    mapFromLibBlockToRefBlock(libBlock)=[cBlock;mapFromLibBlockToRefBlock(libBlock)];
                else
                    mapFromLibBlockToRefBlock(libBlock)=cBlock;
                end
            end
        end
    end














































end

function out=hasMdlLibLoaded()
    allLibs=Simulink.allBlockDiagrams('library');
    out=false;
    for index=1:length(allLibs)
        cLib=allLibs(index);
        fileName=get_param(cLib,'FileName');
        [~,~,fileext]=fileparts(fileName);
        if strcmpi(fileext,'.mdl')
            out=true;
            return;
        end
    end
end
