function processLibs(rMgr)




    try
        processLibsImpl(rMgr);
    catch ex
        Simulink.variant.reducer.utils.logException(ex);
        rMgr.Error=ex;
    end
end





function processLibsImpl(rMgr)
    if isempty(rMgr.LibsToCopy)||isempty(rMgr.AllLibInfo)
        return;
    end
    createLibInfoStructVec(rMgr);
    processCompiledBlocks(rMgr);
    setBlksSVCEMap(rMgr);
    closeAndReopenReducedBDs(rMgr);
    cacheLibRefBlockInfoForRewiring(rMgr);
end

function processCompiledBlocks(rMgr)



    compiledBlocks={rMgr.ProcessedModelInfoStructsVec(1).ConfigInfos.CompiledBlocks};
    compiledVarBlocks={rMgr.ProcessedModelInfoStructsVec(1).ConfigInfos.CompiledVarBlkChoiceInfo};
    compiledSpecialBlocks={rMgr.ProcessedModelInfoStructsVec(1).ConfigInfos.CompiledSpecialBlockInfo};
    for configIter=1:numel(compiledBlocks)
        currActiveBlocks=compiledBlocks{configIter};
        currVarBlockInfo=compiledVarBlocks{configIter};
        currSpecialBlockInfo=compiledSpecialBlocks{configIter};
        for libIter=1:numel(rMgr.LibInfoStructsVec)



            tmpBlkCell={};
            blksInCurrLibMap=rMgr.LibInfoStructsVec(libIter).BlksSVCEMap;
            blksAttribsInCurrLibMap=rMgr.LibInfoStructsVec(libIter).BlksAttribsMap;
            varBlkChoiceInfoStructsVec=rMgr.LibInfoStructsVec(libIter).VarBlkChoiceInfoStructsVec;
            specialBlockInfoStructsVec=rMgr.LibInfoStructsVec(libIter).CompiledSpecialBlockInfo;
            tmpBlkName='';
            tmpLibBlkName='';
            definitionBlk='';
            blkLinkStatus='';
            isMultiInstance=false;
            processCurrentActiveBlks();
            setLibInfoStructsVec();
        end
    end

    function processCurrentActiveBlks()


        for ii=1:length(currActiveBlocks)
            tmpBlkName=currActiveBlocks{ii};
            if~isKey(rMgr.AllLibBlksMap,tmpBlkName)
                continue;
            end
            tmpLibBlkNameCell=i_replaceCarriageReturnWithSpace(rMgr.AllLibBlksMap(tmpBlkName));

            if iscell(tmpLibBlkNameCell)
                Simulink.variant.reducer.utils.assert(numel(tmpLibBlkNameCell)==2);
                allRefsBlk=tmpLibBlkNameCell;
                newRefsBlk=allRefsBlk;




























                while~isempty(newRefsBlk)
                    [newRefsBlk,allRefsBlk]=accumulateRefsForBlkIteratively(rMgr,newRefsBlk,allRefsBlk);
                end



                definitionBlk=allRefsBlk{end};

                allRefsBlk(cellfun(@(x)~isKey(blksInCurrLibMap,x),allRefsBlk))=[];
                if isempty(allRefsBlk)
                    continue;
                else
                    tmpLibBlkNameCell=allRefsBlk;
                end
            else
                if~isKey(blksInCurrLibMap,tmpLibBlkNameCell),continue;end
                tmpLibBlkNameCell={tmpLibBlkNameCell};
                definitionBlk=tmpLibBlkNameCell;
            end




            for tmpI=1:numel(tmpLibBlkNameCell)
                tmpLibBlkName=tmpLibBlkNameCell{tmpI};



                idx=i_searchNameInCell(tmpLibBlkName,tmpBlkCell);




                isMultiInstance=~isempty(idx);


                blkLinkStatus=get_param(tmpLibBlkName,'StaticLinkStatus');

                setVarBlkChoiceInfo();
                setSpecialBlockInfo();

                if isMultiInstance
                    continue;
                end

                setBlksInCurrLib();
                tmpBlkCell{end+1}=tmpLibBlkName;%#ok<AGROW> % visited as part of MLINT cleanup
            end
        end
    end

    function setBlksInCurrLib()
        blksInCurrLibMap(tmpLibBlkName)=blksInCurrLibMap(tmpLibBlkName)+1;
        if rMgr.getOptions().ValidateSignals


            Simulink.variant.reducer.utils.assert(isKey(rMgr.CompiledPortAttributesMap,tmpBlkName));
            blksAttribsInCurrLibMap(tmpLibBlkName)=rMgr.CompiledPortAttributesMap(tmpBlkName);
        end
    end

    function setSpecialBlockInfo()

        splBlkIdx=i_searchNameInCell(tmpBlkName,{currSpecialBlockInfo.BlockPath});
        if isempty(splBlkIdx)
            return;
        end

        if strcmp(tmpLibBlkName,definitionBlk)||strcmpi('resolved',blkLinkStatus)


            specialBlockInfoStructsVec=Simulink.variant.reducer.ReductionManager.i_checkAndPopulateSpecialBlockInfo(...
            tmpBlkName,specialBlockInfoStructsVec,currSpecialBlockInfo(splBlkIdx),tmpLibBlkName);
        end
    end

    function setVarBlkChoiceInfo()

        varIdx=i_searchNameInCell(tmpBlkName,{currVarBlockInfo.VariantBlock});
        if isempty(varIdx)
            return;
        end


        if strcmp(tmpLibBlkName,definitionBlk)||isResolvedIVBlock()







            varBlkChoiceInfoStructsVec=...
            Simulink.variant.reducer.ReductionManager.i_checkAndPopulateVarBlkChoiceInfo(...
            tmpBlkName,varBlkChoiceInfoStructsVec,currVarBlockInfo(varIdx),...
            tmpLibBlkName,isMultiInstance);

            if rMgr.InactiveAZVCOffIVBlockToActivePortMap.isKey(tmpBlkName)
                activePorts=rMgr.InactiveAZVCOffIVBlockToActivePortMap(tmpBlkName);
                rMgr.InactiveAZVCOffIVBlockToActivePortMap.remove(tmpBlkName);
                rMgr.InactiveAZVCOffIVBlockToActivePortMap(tmpLibBlkName)=activePorts;
            end
        end
    end

    function status=isResolvedIVBlock()
        status=any(strcmpi(get_param(tmpLibBlkName,'BlockType'),{'VariantSource','VariantSink'}))...
        &&strcmpi('resolved',blkLinkStatus);
    end

    function setLibInfoStructsVec()
        if~isempty(tmpBlkCell)




            rMgr.LibInfoStructsVec(libIter).NumberOfConfigsActive=rMgr.LibInfoStructsVec(libIter).NumberOfConfigsActive+1;
        end

        rMgr.LibInfoStructsVec(libIter).BlksSVCEMap=blksInCurrLibMap;
        if rMgr.getOptions().ValidateSignals
            rMgr.LibInfoStructsVec(libIter).BlksAttribsMap=blksAttribsInCurrLibMap;
        end
        rMgr.LibInfoStructsVec(libIter).VarBlkChoiceInfoStructsVec=varBlkChoiceInfoStructsVec;
        rMgr.LibInfoStructsVec(libIter).CompiledSpecialBlockInfo=specialBlockInfoStructsVec;
    end
end

function createLibInfoStructVec(rMgr)
    for libIter=numel(rMgr.LibsToCopy):-1:1
        libInfoStruct=rMgr.LibInfoStructsVec(libIter);
        libInfoStruct.NumberOfConfigsActive=0;
        libName=rMgr.LibsToCopy{libIter};
        libInfoStruct.OrigName=libName;
        redLibName=rMgr.BDNameRedBDNameMap(libName);
        libInfoStruct.Name=redLibName;
        blocksInCurrLib=i_findSystem(redLibName);

        blocksInCurrLib=blocksInCurrLib(2:end);





        libInfoStruct.BlksSVCEMap=containers.Map(...
        i_replaceCarriageReturnWithSpace(blocksInCurrLib),...
        zeros(1,numel(blocksInCurrLib)));
        if rMgr.getOptions().ValidateSignals
            libInfoStruct.BlksAttribsMap=containers.Map(...
            i_replaceCarriageReturnWithSpace(blocksInCurrLib),...
            cell(1,numel(blocksInCurrLib)));
        end
        rMgr.LibInfoStructsVec(libIter)=libInfoStruct;
    end
end

function setBlksSVCEMap(rMgr)



    resLibInfo=rMgr.ResolvedLibBlockInfo;
    for libBlkIter=1:numel(resLibInfo)
        currLibInfo=resLibInfo(libBlkIter);
        libName=currLibInfo.Library;

        libIdx=i_searchNameInCell(libName,{rMgr.LibInfoStructsVec.Name});
        if isempty(libIdx),continue;end

        refBlk=currLibInfo.ReferenceBlock;
        hierBlks=i_getAllParentBlksExcludingRoot(refBlk);
        if isempty(hierBlks),continue;end

        blksInCurrLibMap=rMgr.LibInfoStructsVec(libIdx).BlksSVCEMap;
        for ii=1:numel(hierBlks)
            if blksInCurrLibMap(hierBlks{ii})>0,continue;end
            blksInCurrLibMap(hierBlks{ii})=rMgr.LibInfoStructsVec(libIdx).NumberOfConfigsActive;




            rMgr.LibInfoStructsVec(libIdx).HierBlksNotUsed=[rMgr.LibInfoStructsVec(libIdx).HierBlksNotUsed,hierBlks(ii)];
        end
        rMgr.LibInfoStructsVec(libIdx).BlksSVCEMap=blksInCurrLibMap;
    end
end



function closeAndReopenReducedBDs(rMgr)





    nModels=numel(rMgr.ModelRefModelInfoStructsVec);
    nLibs=numel(rMgr.LibInfoStructsVec);

    for iter=1:(nModels+nLibs)
        if iter>nModels

            redBD=rMgr.LibInfoStructsVec(iter-nModels).Name;
            redBDPath=rMgr.LibInfoStructsVec(iter-nModels).FullPath;
        else

            redBD=rMgr.ModelRefModelInfoStructsVec(iter).Name;
            redBDPath=rMgr.ModelRefModelInfoStructsVec(iter).FullPath;
        end


        ddName=get_param(redBD,'DataDictionary');
        if~isempty(ddName)
            saveChanges(Simulink.data.dictionary.open(ddName));
        end





        try
            bdObj=get_param(redBD,'Object');
            bdObj.refreshModelBlocks;
        catch ex %#ok<NASGU> % visited as part of MLINT cleanup
        end
        i_saveSystem(redBD,redBDPath,'SaveDirtyReferencedModels',true);
    end

    skipCloseFcnCallback=true;
    for iter=1:(nModels+nLibs)
        if iter>nModels

            redBD=rMgr.LibInfoStructsVec(iter-nModels).Name;
        else

            redBD=rMgr.ModelRefModelInfoStructsVec(iter).Name;
        end
        Simulink.variant.reducer.utils.i_closeModel(redBD,skipCloseFcnCallback);
    end

    withCallBacks=false;
    for iter=1:(nModels+nLibs)
        if iter>nModels

            redBD=rMgr.LibInfoStructsVec(iter-nModels).Name;
            redBDPath=rMgr.LibInfoStructsVec(iter-nModels).FullPath;
        else

            redBD=rMgr.ModelRefModelInfoStructsVec(iter).Name;
            redBDPath=rMgr.ModelRefModelInfoStructsVec(iter).FullPath;
        end

        Simulink.variant.reducer.utils.loadSystem(redBDPath,withCallBacks);

        if iter>nModels
            set_param(redBD,'Lock','off');
        end
    end
end





function cacheLibRefBlockInfoForRewiring(rMgr)
    resLibInfo=rMgr.ResolvedLibBlockInfo;
    modelRefModelInfoStructsVec=rMgr.ModelRefModelInfoStructsVec;
    rMgr.LibInfoStructsVec=rMgr.LibInfoStructsVec;


    refBlkPortsToIgnoreMap=containers.Map('keyType','char','valueType','any');





    for libBlkIter=1:numel(resLibInfo)
        currLibInfo=resLibInfo(libBlkIter);
        currLib=currLibInfo.Library;
        blk=currLibInfo.Block;





        if strcmp(get_param(blk,'BlockType'),'ModelReference'),continue;end

        immediateRefBlk=currLibInfo.ReferenceBlock;
        refBlks=rMgr.AllLibBlksMap(blk);
        callingBlk=refBlks{1};
        Simulink.variant.reducer.utils.assert(strcmp(immediateRefBlk,refBlks{2}));

        refPortH=get_param(immediateRefBlk,'PortHandles');
        blkPorts=cell2mat(struct2cell(refPortH).');
        if~isempty(blkPorts)
            idx=i_searchNameInCell(currLib,{rMgr.LibInfoStructsVec.Name});
            Simulink.variant.reducer.utils.assert(~isempty(idx));
            rMgr.LibInfoStructsVec(idx).PortsToIgnoreTerm=[rMgr.LibInfoStructsVec(idx).PortsToIgnoreTerm,blkPorts];
        end

        ultimateRefBlk=i_getUltimateRefBlk(rMgr,immediateRefBlk);

        if~isKey(refBlkPortsToIgnoreMap,ultimateRefBlk)
            resBlksIgnorePortsStruct=Simulink.variant.reducer.types.VRedResBlksPorts;
            inBlksH=i_getInportBlockHandles(ultimateRefBlk);
            outBlksH=i_getOutportBlockHandles(ultimateRefBlk);
            resBlksIgnorePortsStruct.InportBlocksH=inBlksH;
            resBlksIgnorePortsStruct.OutportBlocksH=outBlksH;
            refBlkPortsToIgnoreMap(ultimateRefBlk)=resBlksIgnorePortsStruct;
        else
            resBlksIgnorePortsStruct=refBlkPortsToIgnoreMap(ultimateRefBlk);
            inBlksH=resBlksIgnorePortsStruct.InportBlocksH;
            outBlksH=resBlksIgnorePortsStruct.OutportBlocksH;
        end


        libRefsDataStruct=Simulink.variant.reducer.types.VRedLibRefsData;

        libRefsDataStruct.Name=ultimateRefBlk;
        libRefsDataStruct.RootPathPrefix=callingBlk;
        libRefsDataStruct.RefInports=inBlksH;
        libRefsDataStruct.RefOutports=outBlksH;

        idx1=i_searchNameInCell(i_getRootBDNameFromPath(callingBlk),{modelRefModelInfoStructsVec.Name});
        idx2=i_searchNameInCell(i_getRootBDNameFromPath(callingBlk),{rMgr.LibInfoStructsVec.Name});




        Simulink.variant.reducer.utils.assert((~isempty(idx1)||~isempty(idx2)),...
        'Reference block at this stage has to be part of a active library/model.');

        if~isempty(idx1)
            modelRefModelInfoStructsVec(idx1).LibRefsDataStructsVec(end+1)=libRefsDataStruct;
        elseif~isempty(idx2)
            rMgr.LibInfoStructsVec(idx2).LibRefsDataStructsVec(end+1)=libRefsDataStruct;
        end
    end
    rMgr.ModelRefModelInfoStructsVec=modelRefModelInfoStructsVec;
    rMgr.LibInfoStructsVec=rMgr.LibInfoStructsVec;

    function refBlk=i_getUltimateRefBlk(rMgr,refBlk)
        while(isKey(rMgr.AllLibBlksMap,refBlk))
            refBlk=rMgr.AllLibBlksMap(refBlk);
            Simulink.variant.reducer.utils.assert(numel(refBlk)==2)
            refBlk=refBlk{2};
        end
    end
end



