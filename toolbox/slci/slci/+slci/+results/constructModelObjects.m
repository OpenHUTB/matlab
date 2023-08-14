



function keyToHandle=constructModelObjects(Config,reader,mfModel)
    assert(nargin==1||nargin==3);


    isResultsMF=(nargin==3);

    mdl=Config.getModelName();
    mdlHdl=get_param(mdl,'Handle');


    sortedBlks=slci.internal.getFullBlockList(mdlHdl);
    if slcifeature('BEPSupport')==1
        rootInports=slci.internal.getCompRootInportList(mdlHdl);
    else
        rootInports=slci.internal.getRootInportList(mdlHdl);
    end
    sortedBlks=union(sortedBlks,rootInports);


    graphicalBlks=slci.results.find_blocks_all(mdlHdl);
    virtualBlks=setdiff(graphicalBlks,sortedBlks);
    allBlks=union(sortedBlks,virtualBlks);




    sfBlocks=find_system(mdlHdl,'AllBlocks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'SFBlockType','Chart');
    allBlks=setdiff(allBlks,sfBlocks);


    synthesizedBlks=slci.internal.getSynthesizedBlocks(sortedBlks);
    allBlks=setdiff(allBlks,synthesizedBlks);

    keyToHandle=containers.Map;

    blockKeys={};
    sfKeys={};
    synthBlockKeys={};

    if isResultsMF

        if~isempty(allBlks)
            [blockKeys,keyToHandle]=slci.results.constructSortedBlocks(...
            allBlks,rootInports,virtualBlks,...
            keyToHandle,reader,mfModel);
        end


        if~isempty(sfBlocks)
            [sfKeys,keyToHandle]=slci.results.prepareStateflowObjects(reader,...
            sfBlocks,keyToHandle,mfModel);
        end


        if~isempty(synthesizedBlks)
            [synthBlockKeys,keyToHandle]=slci.results.constructSynthesizedBlocks(...
            synthesizedBlks,reader,keyToHandle,mfModel);
        end
    else
        datamgr=Config.getDataManager(mdl);


        if~isempty(allBlks)
            [blockKeys,keyToHandle]=slci.results.constructSortedBlocks(...
            allBlks,rootInports,virtualBlks,...
            keyToHandle,datamgr);
        end


        if~isempty(sfBlocks)
            [sfKeys,keyToHandle]=slci.results.prepareStateflowObjects(Config,...
            sfBlocks,keyToHandle);
        end


        if~isempty(synthesizedBlks)
            [synthBlockKeys,keyToHandle]=slci.results.constructSynthesizedBlocks(...
            synthesizedBlks,datamgr,keyToHandle);
        end
    end

    blockKeys=[blockKeys;synthBlockKeys;sfKeys];





    if isResultsMF
        desc=slci_results_mf.MetaData(mfModel,struct('key','OrderedKeyList'));
        for k=1:numel(blockKeys)
            desc.data.add(blockKeys{k});
        end
        reader.insertDescription(desc);
    else
        blockReader=datamgr.getBlockReader();
        blockReader.insertDescription('OrderedKeyList',blockKeys);
    end
end
