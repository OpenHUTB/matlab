function[allowedBlkTypes,prohibitedBlkTypes]=getBlockTypeListFromLibrary(libName,subLibraryNames)






    allowedBlkTypes={};

    alreadyLoaded=bdIsLoaded(libName);
    load_system(libName);
    allBlocks=Advisor.Utils.Simulink.block.getAllBlocks(libName);


    if nargin>1
        subLibrariesAlreadyLoaded=bdIsLoaded(subLibraryNames);
        load_system(subLibraryNames);
        subBlocks=Advisor.Utils.Simulink.block.getAllBlocks(subLibraryNames);
        allBlocks=[allBlocks;subBlocks];
    end

    allblkTypes={};
    for i=1:length(allBlocks)
        blktype=get_param(allBlocks{i},'BlockType');
        masktype=get_param(allBlocks{i},'MaskType');
        allblkTypes{end+1,1}=blktype;
        allblkTypes{end,2}=masktype;
    end
    allblkTypes=Advisor.Utils.Simulink.block.convertBlkTypeList_into_cell(allblkTypes);

    [~,ResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_QuestionableBlocksV2(['NoMAMode:',libName],'supportNotes_productionCodeDeploymentDefault','ModelAdvisor:engine:');
    BlkTable=ResultDescription{1}.TableInfo;
    for i=1:size(BlkTable,1)
        if~isempty(strfind(BlkTable{i,4},'No'))
            blktype=get_param(BlkTable{i,1},'BlockType');%#ok<*AGROW>
            masktype=get_param(BlkTable{i,1},'MaskType');
            if~(strcmp(blktype,'SubSystem')&&isempty(masktype))
                allowedBlkTypes{end+1,1}=blktype;
                allowedBlkTypes{end,2}=masktype;
            end
        end
    end

    prohibitedBlkTypes=Advisor.Utils.Simulink.block.convertBlkTypeList_into_cell(allowedBlkTypes);
    allowedBlkTypes=setdiff(allblkTypes,prohibitedBlkTypes);

    if~alreadyLoaded
        close_system(libName);
    end

    if nargin>1
        libsToBeClosed=subLibraryNames(~subLibrariesAlreadyLoaded);
        close_system(libsToBeClosed);
    end

end