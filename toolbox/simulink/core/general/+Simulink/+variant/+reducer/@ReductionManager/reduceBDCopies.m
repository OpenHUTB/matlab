function err=reduceBDCopies(optArgs)







    if optArgs.getOptions().ValidateSignals


        renameMapkeysForRefBlocks(optArgs);


        updatePortAttribsForRefBlks(optArgs);
    end



    err=i_processLibBlkMap(optArgs);
    if~isempty(err)
        return;
    end




    populateAreaAnnotOriginalModel(optArgs);


    try
        deleteAllInactiveBlocksAndLines(optArgs);
    catch err
        return;
    end



    err=reduceLibCopies(optArgs);
    if~isempty(err)
        return;
    end


    err=reduceModelCopies(optArgs);
    if~isempty(err)
        return;
    end

end







function renameMapkeysForRefBlocks(optArgs)
    bdNameRedBDNameMap=optArgs.BDNameRedBDNameMap;
    blks=optArgs.CompiledPortAttributesMap.keys;
    for blkId=1:numel(blks)
        blk=blks{blkId};
        [parentBD,blkRemPath]=strtok(blk,'/');


        if~bdNameRedBDNameMap.isKey(parentBD)
            continue;
        end

        newBlkName=[bdNameRedBDNameMap(parentBD),blkRemPath];
        optArgs.CompiledPortAttributesMap(newBlkName)=optArgs.CompiledPortAttributesMap(blk);
        optArgs.CompiledPortAttributesMap.remove(blk);
    end
end



function updatePortAttribsForRefBlks(optArgs)


    i_modifyStalePortHandlesinBlkAttribMap(optArgs.ModelRefModelInfoStructsVec);


    i_modifyStalePortHandlesinBlkAttribMap(optArgs.LibInfoStructsVec);



    i_modifyCompPortAttribMap(optArgs);



    function i_modifyStalePortHandlesinBlkAttribMap(bdStructsVec)
        for bdIter=1:numel(bdStructsVec)



            blks=i_pruneOutInvalidBlks(bdStructsVec(bdIter).BlksAttribsMap.keys);

            for blkId=1:numel(blks)
                portHandles=get_param(blks{blkId},'PortHandles');
                portsInOut=[portHandles.Inport,portHandles.Outport];

                if isempty(portsInOut)
                    continue;
                end

                attribStructVec=bdStructsVec(bdIter).BlksAttribsMap(blks{blkId});

                if isempty(attribStructVec)
                    continue;
                end



                if numel(attribStructVec)~=numel(portsInOut)

                    attribStructVec(1:end)=[];
                end

                for strId=1:numel(attribStructVec)
                    attribStructVec(strId).Handle=portsInOut(strId);
                end
                bdStructsVec(bdIter).BlksAttribsMap(blks{blkId})=attribStructVec;
            end
        end
    end

    function i_modifyCompPortAttribMap(optArgs)



        blks=i_pruneOutInvalidBlks(optArgs.CompiledPortAttributesMap.keys);

        for blkId=1:numel(blks)
            portHandles=get_param(blks{blkId},'PortHandles');
            portsInOut=[portHandles.Inport,portHandles.Outport];
            if isempty(portsInOut)
                continue;
            end

            attribStructVec=optArgs.CompiledPortAttributesMap(blks{blkId});

            if isempty(attribStructVec)
                continue;
            end

            for strId=1:numel(attribStructVec)
                attribStructVec(strId).Handle=portsInOut(strId);
            end
            optArgs.CompiledPortAttributesMap(blks{blkId})=attribStructVec;
        end
    end


end



function err=i_processLibBlkMap(optArgs)
    err=[];

    libBlkMap=optArgs.AllLibBlksMap;
    libBlks=libBlkMap.keys;

    bdNameRedBDNameMap=optArgs.BDNameRedBDNameMap;

    for libBlkId=1:numel(libBlks)
        libBlkKey=libBlks{libBlkId};

        libBlkVals=libBlkMap(libBlkKey);
        if~iscell(libBlkVals)
            libBlkVals={libBlkVals};
        end

        libBlkVals=cellfun(@(x)i_getModifiedBlockPath(x,bdNameRedBDNameMap),libBlkVals,'UniformOutput',false);

        libBlkMap.remove(libBlkKey);

        libBlkMap(i_getModifiedBlockPath(libBlkKey,bdNameRedBDNameMap))=libBlkVals;
    end




    invertedLibBlkMap=Simulink.variant.utils.i_invertMap(libBlkMap);

    optArgs.LibBlkToModelInstanceMap=invertedLibBlkMap;
end


function populateAreaAnnotOriginalModel(optArgs)
    optArgs.OrigMdlAnnotationAreas=optArgs.i_getAreaAnnotMargins();
end



function deleteAllInactiveBlocksAndLines(optArgs)

    isLib=false;
    deleteInactiveBlocks(optArgs,isLib);

    isLib=true;
    deleteInactiveBlocks(optArgs,isLib);


    isLib=false;
    i_rewireAllRefBlocks(optArgs,isLib);


    isLib=true;
    i_rewireAllRefBlocks(optArgs,isLib);

    isLib=false;
    i_deleteInactiveLines(optArgs,isLib);

    isLib=true;
    i_deleteInactiveLines(optArgs,isLib);
end




function err=reduceLibCopies(optArgs)

    err=[];
    libInfoStructsVec=optArgs.LibInfoStructsVec;

    for libIdx=1:numel(libInfoStructsVec)
        libInfoStruct=libInfoStructsVec(libIdx);
        libName=libInfoStruct.Name;






        hierBlks=libInfoStructsVec(libIdx).HierBlksNotUsed;
        for iter=1:numel(hierBlks)
            blk=hierBlks{iter};
            Simulink.variant.reducer.utils.assert(strcmp(get_param(blk,'BlockType'),'SubSystem'));
            if slInternal('isVariantSubsystem',get_param(blk,'Handle'))
                slInternal('disableVariant',blk);
            end
        end


        varBlkChoiceInfoStructsVec=libInfoStruct.VarBlkChoiceInfoStructsVec;
        isVarBlkInLib=true;
        for varBlkIter=1:numel(varBlkChoiceInfoStructsVec)
            varBlockStruct=varBlkChoiceInfoStructsVec(varBlkIter);
            try
                portsToIgnoreTerm=i_modifyVarBlkConnections(optArgs,varBlockStruct,libIdx,isVarBlkInLib);
                libInfoStruct.PortsToIgnoreTerm=[libInfoStruct.PortsToIgnoreTerm(:)',portsToIgnoreTerm(:)'];
            catch err
                return;
            end

        end


        i_modifySpecialBlockConnections(optArgs,libIdx,isVarBlkInLib);


        try
            isLibForTerm=true;
            i_addTermGnd(optArgs,libIdx,isLibForTerm);
        catch err




            if any(strcmp(err.identifier,{'Simulink:VariantReducer:DiffBusHierToLibBlk';'Simulink:VariantReducer:DiffBusAttribsToLibBlk'}))


                return;
            end
        end

        try
            i_retainOrRemoveCommentedBlks(optArgs,libName);
        catch me

        end
    end

end




function err=reduceModelCopies(optArgs)

    err=[];

    modelInfoStructsVec=optArgs.ProcessedModelInfoStructsVec;
    modelRefModelInfoStructsVec=optArgs.ModelRefModelInfoStructsVec;
    absOutDirPath=optArgs.getOptions().AbsOutDirPath;

    numModels=length(modelInfoStructsVec);





























    for modelInfoIdx=numModels:-1:1
        modelInfoStruct=modelInfoStructsVec(modelInfoIdx);
        modelName=modelInfoStruct.Name;
        origModelName=modelInfoStruct.OrigName;


        isProtected=modelInfoStruct.IsProtected;
        fullModelPath=modelInfoStruct.FullPath;
        [~,~,ext]=fileparts(fullModelPath);

        if isProtected

            modelSavePath=[absOutDirPath,filesep,modelName,ext];

            Simulink.variant.reducer.utils.assert(~strcmp(modelSavePath,fullModelPath),...
            ['Protected model ',modelName,' has same source & destination directories.'])

            try
                copyfile(fullModelPath,modelSavePath,'f');
            catch err
            end

            if~isempty(err),return;end

            continue;
        end




        allModelRefs=arrayfun(@(x)x.OrigName,modelRefModelInfoStructsVec,'UniformOutput',false);
        modelRefIdx=Simulink.variant.reducer.utils.searchNameInCell(origModelName,allModelRefs);
        Simulink.variant.reducer.utils.assert(~isempty(modelRefIdx));








        err=i_deleteChoicesAndConvertVariants(optArgs,modelRefIdx);
        if~isempty(err)

            msgid='Simulink:VariantReducer:AACOffForMultipleChoiceActiveBlocksLate';
            if strcmp(err.identifier,msgid)


                return;
            end
            errid='Simulink:VariantReducer:InternalErrInDeletingChoices';
            errmsg=message(errid,origModelName);
            tmpErr=MException(errmsg);
            err=Simulink.variant.utils.addValidationCausesToDiagnostic(tmpErr,err);
            return;
        end

    end

end



function err=i_deleteChoicesAndConvertVariants(optArgs,modelRefIdx)

    err=[];

    modelRefModelInfoStruct=optArgs.ModelRefModelInfoStructsVec(modelRefIdx);
    modelName=modelRefModelInfoStruct.Name;

    try

        varBlkChoiceInfoStructsVec=modelRefModelInfoStruct.VarBlkChoiceInfoStructsVec;
        isVarBlkInLib=false;
        for varBlkIter=1:numel(varBlkChoiceInfoStructsVec)
            varBlockStruct=varBlkChoiceInfoStructsVec(varBlkIter);



            try
                portsToIgnoreTerm=i_modifyVarBlkConnections(optArgs,varBlockStruct,modelRefIdx,isVarBlkInLib);
                modelRefModelInfoStruct.PortsToIgnoreTerm=[modelRefModelInfoStruct.PortsToIgnoreTerm(:)',portsToIgnoreTerm(:)'];
            catch err
                return;
            end
        end


        i_modifySpecialBlockConnections(optArgs,modelRefIdx,isVarBlkInLib);


        try
            isLibForTerm=false;
            i_addTermGnd(optArgs,modelRefIdx,isLibForTerm);
        catch me

        end

        try
            i_retainOrRemoveCommentedBlks(optArgs,modelName);
        catch me

        end

    catch err
    end
end


function portsToIgnoreTerm=i_modifyVarBlkConnections(optArgs,varBlockStruct,bdRefIdx,isVarBlkInLib)
    portsToIgnoreTerm=[];
    isVarBlockModified=false;
    if isVarBlkInLib
        bdRefModelInfoStruct=optArgs.LibInfoStructsVec(bdRefIdx);
    else
        bdRefModelInfoStruct=optArgs.ModelRefModelInfoStructsVec(bdRefIdx);
    end

    nConfigsSpecified=numel(optArgs.ProcessedModelInfoStructsVec(1).ConfigInfos);

    blksAttribsMap=bdRefModelInfoStruct.BlksAttribsMap;

    bdNameRedBDNameMap=optArgs.BDNameRedBDNameMap;
    varBlockPath=varBlockStruct.BlockPath;
    modelName=i_getRootBDNameFromPath(varBlockPath);
    varBlockType=varBlockStruct.BlockType;

    if~isempty(optArgs.FullRangeAnalysisInfo)
        fullRangeConditionsMapWithOrigRefModelNames=optArgs.FullRangeAnalysisInfo.FullRangeConditionsMap;
        blocksWithFullRangeConditions=fullRangeConditionsMapWithOrigRefModelNames.keys;
    else
        blocksWithFullRangeConditions={};
    end



    fullRangeConditionsMap=containers.Map;
    for i=1:numel(blocksWithFullRangeConditions)
        blockWithFullRangeConditions=blocksWithFullRangeConditions{i};
        conditionMap=fullRangeConditionsMapWithOrigRefModelNames(blockWithFullRangeConditions);
        refModelBlockPathParts=Simulink.variant.utils.splitPathInHierarchy(blockWithFullRangeConditions);
        if optArgs.BDNameRedBDNameMap.isKey(refModelBlockPathParts{1})
            blockWithFullRangeConditions=[optArgs.BDNameRedBDNameMap(refModelBlockPathParts{1}),'/',strjoin(refModelBlockPathParts(2:end),'/')];
        end
        fullRangeConditionsMap(blockWithFullRangeConditions)=conditionMap;
    end
    if~isempty(optArgs.FullRangeAnalysisInfo)
        optArgs.FullRangeAnalysisInfo.FullRangeConditionsMap=fullRangeConditionsMap;
    end




    calledFromReducer=true;

    if varBlockType.isVariantSubsystem()





        allVSSChoices=varBlockStruct.AllChoiceNames;
        choicesToDelete=setdiff(allVSSChoices,varBlockStruct.ActiveChoiceNames);
        numNonEmptyChoices=numel(allVSSChoices);
        numVarChoicesToDelete=numel(choicesToDelete);

    elseif varBlockType.isModelVariant||varBlockType.isVariantSource||varBlockType.isVariantSink
        if varBlockType.isModelVariant
            variants=[];
            try
                variants=get_param(varBlockPath,'Variants');
            catch ex
            end
        end
        numNonEmptyChoices=varBlockStruct.NumberOfChoices;
        idxRetain=varBlockStruct.ActiveChoiceNumbers';
        idxDelete=setdiff(1:numNonEmptyChoices,idxRetain);
        numVarChoicesToDelete=numNonEmptyChoices-numel(varBlockStruct.ActiveChoiceNumbers);

    elseif varBlockType.isVariantSimulinkFunction||varBlockType.isVariantIRTSubsystem
        numNonEmptyChoices=1;
        numVarChoicesToDelete=0;
    end


    isSingleChoiceToBeRetained=((numNonEmptyChoices-numVarChoicesToDelete)==1);





    numConfigsVarBlockIsActive=varBlockStruct.NumberOfConfigsActive;

    shouldVariantsBeDisabled=false;
    if isSingleChoiceToBeRetained
        if varBlockType.isVariantSource||varBlockType.isVariantSink||...
            varBlockType.isVariantSimulinkFunction||varBlockType.isVariantIRTSubsystem














            shouldVariantsBeDisabled=(numConfigsVarBlockIsActive==nConfigsSpecified)...
            ||Simulink.variant.utils.isManualIVBlock(varBlockPath);
        elseif varBlockType.isVariantSubsystem











            if varBlockStruct.isAZVCActivated
                shouldVariantsBeDisabled=false;
            else
                shouldVariantsBeDisabled=true;
            end
        elseif varBlockType.isModelVariant



            shouldVariantsBeDisabled=true;
        end





        shouldVariantsBeDisabled=shouldVariantsBeDisabled...
        ||Simulink.variant.utils.isSimCodegenBlock(varBlockPath);
    end

    if varBlockType.isVariantSubsystem&&(numNonEmptyChoices-numVarChoicesToDelete)==0
        shouldVariantsBeDisabled=true;
    end

    hasMoreThanOneActiveChoice=(numNonEmptyChoices-numVarChoicesToDelete)>1;

    if hasMoreThanOneActiveChoice
        err=i_verifyAACONForThisBlock(varBlockPath,bdNameRedBDNameMap,modelName);
        if~isempty(err)
            throwAsCaller(err);
        end
    end



    if optArgs.getOptions().ValidateSignals
        if varBlockType.isVariantSource||varBlockType.isVariantSink
            if shouldVariantsBeDisabled
                if~isVarBlkInLib&&isKey(blksAttribsMap,varBlockPath)
                    ii_getPortsToAddSigSpecOnVarBlks(optArgs,varBlockStruct,blksAttribsMap(varBlockPath),idxRetain);
                end
            else
                if~isVarBlkInLib&&isKey(blksAttribsMap,varBlockPath)
                    ii_getPortsToAddSigSpecOnVarBlks(optArgs,varBlockStruct,blksAttribsMap(varBlockPath),-1);
                end
            end
        elseif varBlockType.isVariantSubsystem
            if~isVarBlkInLib&&isKey(blksAttribsMap,varBlockPath)
                ii_getPortsToAddSigSpecOnVarBlks(optArgs,varBlockStruct,blksAttribsMap(varBlockPath),-1);
            end
        end
    end

    varBlockIsLinked=~strcmp('none',get_param(varBlockPath,'StaticLinkStatus'));

    if varBlockType.isVariantSource||varBlockType.isVariantSink

        if shouldVariantsBeDisabled

            optArgs.SysHandlesToLayout(end+1,1)=...
            get_param(get_param(varBlockPath,'Parent'),'Handle');


            if isVarBlkInLib
                optArgs.LibInfoStructsVec(bdRefIdx).BlksSVCEMap(varBlockPath)=0;
            else
                optArgs.ModelRefModelInfoStructsVec(bdRefIdx).BlksSVCEMap(varBlockPath)=0;
            end








            i_deleteIVBlock(optArgs,varBlockPath,idxRetain,idxDelete,isVarBlkInLib);

        else








            if~isempty(idxDelete)
                optArgs.SysHandlesToLayout(end+1,1)=...
                get_param(get_param(varBlockPath,'Parent'),'Handle');




















                if optArgs.InactiveAZVCOffIVBlockToActivePortMap.isKey(varBlockPath)&&~varBlockIsLinked
                    actPorts=optArgs.InactiveAZVCOffIVBlockToActivePortMap(varBlockPath);
                    if~isempty(intersect(actPorts,idxDelete))
                        set_param(varBlockPath,'AllowZeroVariantControls','on');
                    end
                end

                try
                    origVariantControls=get_param(varBlockPath,'VariantControls');
                    if varBlockType.isVariantSource
                        portsToIgnoreTerm=Simulink.variant.utils.rewireVariantSource(varBlockPath,idxDelete,calledFromReducer);
                    elseif varBlockType.isVariantSink
                        portsToIgnoreTerm=Simulink.variant.utils.rewireVariantSink(varBlockPath,idxDelete,calledFromReducer);
                    end

                    if~varBlockIsLinked&&all(strcmp({'(default)'},get_param(varBlockPath,'VariantControls')))
                        if~isempty(optArgs.FullRangeAnalysisInfo)&&optArgs.FullRangeAnalysisInfo.FullRangeConditionsMap.isKey(varBlockPath)



                            condModMapForBlock=optArgs.FullRangeAnalysisInfo.FullRangeConditionsMap(varBlockPath);
                            variantControls={condModMapForBlock('(default)')};
                        else



                            variantControls=get_param(varBlockPath,'VariantControls');
                            origVariantControlsMod=Simulink.variant.reducer.utils.i_handleSpecialCasesInVCForaBlock(origVariantControls);
                            variantControls=origVariantControlsMod(strcmp(origVariantControls,variantControls));
                        end
                        set_param(varBlockPath,'VariantControls',variantControls);
                    end
                catch err
                    throwAsCaller(err);
                end

            end


            isVarBlockModified=true;
        end

    elseif varBlockType.isVariantSubsystem

        if shouldVariantsBeDisabled








            portsToAddConstants=i_getPortsToAddConstants(varBlockPath);



            slInternal('disableVariant',varBlockPath);
            wireUpDisabledVSS(optArgs,varBlockPath,portsToAddConstants);

            optArgs.SysHandlesToLayout(end+1,1)=...
            get_param(get_param(varBlockPath,'Parent'),'Handle');
            i_removeAnnotationInVSS(varBlockPath);

            isVarBlockModified=true;
        end

    elseif varBlockType.isModelVariant
        for ci=numVarChoicesToDelete:-1:1
            try
                variants(idxDelete(ci))=[];
            catch ex
            end
        end
        if numVarChoicesToDelete>0
            set_param(varBlockPath,'Variants',variants);
        end
        if shouldVariantsBeDisabled




            slInternal('disableVariant',varBlockPath);
            set_param(varBlockPath,'Variants',[]);
            set_param(varBlockPath,'ModelNameDialog',variants.ModelName);



            set_param(varBlockPath,...
            'ParameterArgumentValues',variants.ParameterArgumentValues);
            set_param(varBlockPath,'SimulationMode',variants.SimulationMode);

            isVarBlockModified=true;
        end

    elseif varBlockType.isVariantSimulinkFunction||varBlockType.isVariantIRTSubsystem






        i_handleVarCondnOfSingleChoiceVariantInfoBlockInReducedModel(...
        optArgs,varBlockPath,shouldVariantsBeDisabled,varBlockType);


        isVarBlockModified=true;
    else
        warnid='Simulink:Variants:VariantReducerUnsupportedBlk';
        warnmsg=message(warnid,varBlockPath);
        warnObj=MException(warnmsg);
        optArgs.Warnings{end+1}=warnObj;
    end

    if~varBlockIsLinked...
        &&~shouldVariantsBeDisabled...
        &&~varBlockType.isVariantSimulinkFunction...
        &&~varBlockType.isVariantIRTSubsystem









        isVarCondModified=optArgs.i_modifyVarCondExpr(varBlockPath,varBlockType);
        isVarBlockModified=isVarBlockModified||isVarCondModified;
    end


    if isVarBlockModified
        optArgs.ReportDataObj.addModifiedBlock(varBlockPath,modelName,isVarBlkInLib);
    end
end



function i_modifySpecialBlockConnections(optArgs,bdIdx,isLibForSplBlks)

    if~isLibForSplBlks
        bdStruct=optArgs.ModelRefModelInfoStructsVec(bdIdx);
    else
        bdStruct=optArgs.LibInfoStructsVec(bdIdx);
    end

    specialBlockInfoStructsVec=bdStruct.CompiledSpecialBlockInfo;
    for splBlkIter=1:numel(specialBlockInfoStructsVec)
        splBlkStruct=specialBlockInfoStructsVec(splBlkIter);
        splBlkPortH=get_param(splBlkStruct.BlockPath,'PortHandles');
        splBlkInputPorts=splBlkPortH.Inport;
        splBlkOutputPort=splBlkPortH.Outport;



        if max(splBlkStruct.ActiveOutputPortNumbers)>numel(splBlkOutputPort)...
            ||max(splBlkStruct.ActiveInputPortNumbers)>numel(splBlkInputPorts)

            continue;
        end


        activeInports=splBlkInputPorts(splBlkStruct.ActiveInputPortNumbers);

        activeOutports=splBlkOutputPort(splBlkStruct.ActiveOutputPortNumbers);

        parent=get_param(splBlkStruct.BlockPath,'Parent');

        if strcmp(splBlkStruct.Operation,'replace')



            if strcmp(get_param(splBlkStruct.BlockPath,'BlockType'),'Merge')
                initOutput=strtrim(get_param(splBlkStruct.BlockPath,'InitialOutput'));
                if~(strcmp(initOutput,'0')||strcmp(initOutput,'[]'))

                    warnmsg=message('Simulink:VariantReducer:MergeBlockIC',splBlkStruct.BlockPath);
                    warnObj=MException(warnmsg);
                    optArgs.Warnings{end+1}=warnObj;
                end
            end


            srcLine=get(activeInports,'Line');
            srcLine=srcLine(srcLine~=-1);
            dstLine=get(activeOutports,'Line');
            dstLine=dstLine(dstLine~=-1);
            srcPort=-1;
            dstPort=-1;
            if~isempty(srcLine)
                srcPort=get(srcLine,'SrcPortHandle');
                delete_line(srcLine);
            end
            if~isempty(dstLine)
                dstPort=get(dstLine,'DstPortHandle');
                delete_line(dstLine);
            end



            if strcmp(splBlkStruct.ReplacedBlock,'SignalSpecification')
                blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION;
                blkToAdd.BlkPath=[splBlkStruct.BlockPath,'_SignalSpecification'];
            end
            blkToAdd.SrcPort=srcPort;
            blkToAdd.DstPort=dstPort;
            blkToAdd.System=parent;

            blkH=i_addBlock(optArgs,blkToAdd);
            if blkH~=-1
                blkMask=Simulink.Mask.create(blkH);
                blkMask.Display='disp([''s''])';
                portHaddedSS=get(blkH,'PortHandles');


                slInternal('ClonePortProperties',portHaddedSS.Outport,activeOutports);
            end


            delete_block(splBlkStruct.BlockPath);

            if blkH~=-1

                Simulink.variant.reducer.utils.addLine(parent,srcPort,portHaddedSS.Inport,'autorouting','smart');
                Simulink.variant.reducer.utils.addLine(parent,portHaddedSS.Outport,dstPort,'autorouting','smart');
            end


            bdStruct.BlksSVCEMap(splBlkStruct.BlockPath)=0;

        elseif strcmp(splBlkStruct.Operation,'prune')




            srcLines=Simulink.variant.utils.i_cell2mat(get(activeInports,'Line'));
            srcLines=srcLines(srcLines~=-1);
            srcPortH=-1;
            if~isempty(srcLines)
                srcPortH=Simulink.variant.utils.i_cell2mat(get(srcLines,'SrcPortHandle'));
                delete_line(srcLines);
            end

            dstLines=Simulink.variant.utils.i_cell2mat(get(activeOutports,'Line'));
            dstLines=dstLines(dstLines~=-1);
            dstPortHs=-1;
            if~isempty(dstLines)
                dstPortHs=Simulink.variant.utils.i_cell2mat(get(dstLines,'DstPortHandle'));
                delete_line(dstLines);
            end


            if strcmp(get_param(splBlkStruct.BlockPath,'BlockType'),'Merge')
                set_param(splBlkStruct.BlockPath,'Inputs',num2str(numel(activeInports)));
            elseif strcmp(get_param(splBlkStruct.BlockPath,'BlockType'),'FunctionCallSplit')
                set_param(splBlkStruct.BlockPath,'NumOutputPorts',num2str(numel(activeOutports)));
            end


            splBlkPortH=get_param(splBlkStruct.BlockPath,'PortHandles');
            splBlkInputs=splBlkPortH.Inport;
            splBlkOutputs=splBlkPortH.Outport;


            if srcPortH~=-1
                Simulink.variant.reducer.utils.addLine(parent,srcPortH,splBlkInputs,'autorouting','smart');
            end
            if dstPortHs~=-1
                Simulink.variant.reducer.utils.addLine(parent,splBlkOutputs,dstPortHs,'autorouting','smart');
            end


            optArgs.ReportDataObj.addModifiedBlock(splBlkStruct.BlockPath,parent,isLibForSplBlks);
        end
    end
end






function ii_getPortsToAddSigSpecOnVarBlks(optArgs,varBlockStruct,compPortAttrStructsVec,idxRetain)


    if~optArgs.getOptions().ValidateSignals,return;end


    if isempty(compPortAttrStructsVec),return;end

    varBlockPath=varBlockStruct.BlockPath;
    ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;

    if Simulink.variant.reducer.utils.isLabelMode(varBlockPath)


        return;
    end






    if slInternal('isVariantSubsystem',get_param(get_param(varBlockPath,'Parent'),'Handle')),return;end

    varBlockType=varBlockStruct.BlockType;

    if varBlockType.isVariantSource


        if numel(varBlockStruct.ActiveChoiceNumbers)==varBlockStruct.NumberOfChoices,return;end
        blkPortH=get_param(varBlockPath,'PortHandles');
        outputline=get(blkPortH.Outport,'Line');



        if outputline==-1
            dstPorts=-1;
        else

            dstPorts=get(outputline,'DstPortHandle');
        end


        if idxRetain==-1



            ssPortInfo.SrcPortHandle=blkPortH.Outport;
            srcBlkPath=varBlockPath;
        else

            activeInPort=blkPortH.Inport(idxRetain);
            inputActiveLine=get(activeInPort,'Line');
            if inputActiveLine==-1


                ssPortInfo.SrcPortHandle=-1;


                srcBlkPath=i_replaceCarriageReturnWithSpace(varBlockPath);
            else

                srcPort=get(inputActiveLine,'SrcPortHandle');
                ssPortInfo.SrcPortHandle=srcPort;
                srcBlkPath=i_replaceCarriageReturnWithSpace(get(srcPort,'Parent'));
            end
        end


        ssPortInfo.DstPortHandle=dstPorts;



        ssPortInfo.PortAttributes=compPortAttrStructsVec(end);


        ssPortBlockInfo.ssPortInfo=ssPortInfo;
        ssPortBlockInfo.portParent=srcBlkPath;
        optArgs.setPortsToAddSigSpec(ssPortBlockInfo.portParent,ssPortBlockInfo.ssPortInfo);

    elseif varBlockType.isVariantSink


        if numel(varBlockStruct.ActiveChoiceNumbers)==varBlockStruct.NumberOfChoices,return;end
        blkPortH=get_param(varBlockPath,'PortHandles');

        inputline=get(blkPortH.Inport,'Line');



        if inputline==-1
            srcPort=-1;


            srcBlkPath=i_replaceCarriageReturnWithSpace(varBlockPath);
        else
            srcPort=get(inputline,'SrcPortHandle');
            srcBlkPath=i_replaceCarriageReturnWithSpace(get(srcPort,'Parent'));
        end


        if idxRetain==-1

            ssPortInfo.DstPortHandle=blkPortH.Inport;
        else


            activeOutPort=blkPortH.Outport(idxRetain);
            activeOutputLine=get(activeOutPort,'Line');
            if activeOutputLine==-1


                ssPortInfo.DstPortHandle=-1;
            else
                dstPorts=get(activeOutputLine,'DstPortHandle');
                ssPortInfo.DstPortHandle=dstPorts;
            end
        end


        ssPortInfo.SrcPortHandle=srcPort;



        ssPortInfo.PortAttributes=compPortAttrStructsVec(1);


        ssPortBlockInfo.ssPortInfo=ssPortInfo;
        ssPortBlockInfo.portParent=srcBlkPath;
        optArgs.setPortsToAddSigSpec(ssPortBlockInfo.portParent,ssPortBlockInfo.ssPortInfo);

    elseif varBlockType.isVariantSubsystem






        if isempty(setdiff(varBlockStruct.AllChoiceNames,varBlockStruct.ActiveChoiceNames)),return;end
        blkPortH=get_param(varBlockPath,'PortHandles');



        inportBlks=get_param(find_system(varBlockPath,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'SearchDepth',1,...
        'regexp','on',...
        'BlockType','Inport'),'Name');
        numInportBlks=numel(inportBlks);
        outportBlks=get_param(find_system(varBlockPath,...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.allVariants,...
        'SearchDepth',1,...
        'regexp','on',...
        'BlockType','Outport'),'Name');
        numOutportBlks=numel(outportBlks);


        for iter=1:(numInportBlks+numOutportBlks)
            ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;
            if iter<=numInportBlks
                blk=inportBlks{iter};



                ssPortInfo.DstPortHandle=blkPortH.Inport(iter);

                inputline=get(blkPortH.Inport(iter),'Line');


                if inputline==-1
                    ssPortInfo.SrcPortHandle=-1;


                    srcBlkPath=i_replaceCarriageReturnWithSpace(varBlockPath);
                else
                    ssPortInfo.SrcPortHandle=get(inputline,'SrcPortHandle');
                    srcBlkPath=i_replaceCarriageReturnWithSpace(get(ssPortInfo.SrcPortHandle,'Parent'));
                end
            else
                blk=outportBlks{iter-numInportBlks};



                ssPortInfo.SrcPortHandle=blkPortH.Outport(iter-numInportBlks);
                srcBlkPath=i_replaceCarriageReturnWithSpace(get(ssPortInfo.SrcPortHandle,'Parent'));

                outputline=get(blkPortH.Outport(iter-numInportBlks),'Line');


                if outputline==-1
                    ssPortInfo.DstPortHandle=-1;
                else
                    ssPortInfo.DstPortHandle=get(outputline,'DstPortHandle');
                end
            end
            idx=Simulink.variant.reducer.utils.searchNameInCell(blk,{compPortAttrStructsVec.PortBlockName});
            Simulink.variant.reducer.utils.assert(~isempty(idx));
            ssPortInfo.PortAttributes=compPortAttrStructsVec(idx);

            ssPortBlockInfo.ssPortInfo=ssPortInfo;
            ssPortBlockInfo.portParent=srcBlkPath;
            optArgs.setPortsToAddSigSpec(ssPortBlockInfo.portParent,ssPortBlockInfo.ssPortInfo);
        end
    end
end




function portsToAddConstants=i_getPortsToAddConstants(varBlockPath)

    portsToAddConstId=0;
    portsToAddConstants.Handles=[];
    portsToAddConstants.Value=[];
    portsToAddConstants.VectorParams1D=[];




    portsToAddConstants.DataTypeStr='';

    portsToAddConstants(end)=[];

    outportsInVSS=i_findSystem(varBlockPath,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'regexp','on',...
    'BlockType','Outport');

    for outportId=1:numel(outportsInVSS)
        if strcmp(get_param(outportsInVSS{outportId},'OutputWhenUnconnected'),'on')
            portsToAddConstId=portsToAddConstId+1;
            portHandles=get_param(outportsInVSS{outportId},'PortHandles');
            portsToAddConstants(portsToAddConstId).Handles=portHandles.Inport;
            portsToAddConstants(portsToAddConstId).Value=get_param(outportsInVSS{outportId},'OutputWhenUnconnectedValue');
            portsToAddConstants(portsToAddConstId).DataTypeStr=get_param(outportsInVSS{outportId},'OutDataTypeStr');
            portsToAddConstants(portsToAddConstId).VectorParams1D=get_param(outportsInVSS{outportId},'VectorParamsAs1DForOutWhenUnconnected');
        end
    end
end





function deleteInactiveBlocks(optArgs,isLib)
    if isLib
        bdStructsVec=optArgs.LibInfoStructsVec;
    else
        bdStructsVec=optArgs.ModelRefModelInfoStructsVec;
    end

    for bdIter=1:length(bdStructsVec)
        bdName=bdStructsVec(bdIter).Name;

        totalBlocksToDel=getInactiveBlocks();
        if isempty(totalBlocksToDel)
            continue;
        end

        inPortTable=[];ignoreExtInput=false;
        outPortTable=[];ignoreSaveName=false;
        cacheRootIOConfigParam();


        cacheForLayout();

        blksIdxFailedToDelete=[];
        deleteBlocks();

        updateBlksSVCEMapForFailedBlocks();

        resetRootIOConfigParam();
    end

    function totalBlocksToDel=getInactiveBlocks()
        blksSVCEMap=bdStructsVec(bdIter).BlksSVCEMap;
        totalBlocksToDel=blksSVCEMap.keys;


        totalBlocksToDel=(totalBlocksToDel(~Simulink.variant.utils.i_cell2mat(blksSVCEMap.values)))';
    end

    function cacheRootIOConfigParam()
        if isLib
            return;
        end











        configParam=1;
        try
            [inPortTable,ignoreExtInput]=...
            i_rootIONameConfigPrm(bdName,configParam);
        catch
            ignoreExtInput=true;
        end


        configParam=2;
        try
            [outPortTable,ignoreSaveName]=...
            i_rootIONameConfigPrm(bdName,configParam);
        catch
            ignoreSaveName=true;
        end









    end

    function cacheForLayout()
        parentHandles=Simulink.variant.utils.i_cell2mat(...
        get_param(get_param(totalBlocksToDel,'Parent'),'Handle'));

        deletedBlocks=Simulink.variant.utils.i_cell2mat(...
        get_param(totalBlocksToDel,'Handle'));


        sysHandles=setdiff(parentHandles,deletedBlocks);
        if~isempty(sysHandles)
            optArgs.SysHandlesToLayout=cat(1,optArgs.SysHandlesToLayout,...
            sysHandles);
        end
    end

    function deleteBlocks()







        totalBlocksToDel=sortrows(totalBlocksToDel,-1);
        for blkIdxToDelete=1:numel(totalBlocksToDel)
            try
                delete_block(totalBlocksToDel(blkIdxToDelete));
            catch ex


                blksIdxFailedToDelete(end+1)=blkIdxToDelete;%#ok<AGROW>
            end
        end
    end

    function updateBlksSVCEMapForFailedBlocks()



        blksFailedToDelete=totalBlocksToDel(blksIdxFailedToDelete);



        blksFailedH=getSimulinkBlockHandle(blksFailedToDelete);
        blksFailedToDelete=blksFailedToDelete(blksFailedH~=-1);

        for blkIdx=1:numel(blksFailedToDelete)
            blk=blksFailedToDelete{blkIdx};



            blockType=get_param(blk,'BlockType');

            Simulink.variant.utils.assert(strcmp('TriggerPort',blockType)||strcmp('ActionPort',blockType))



            bdStructsVec(bdIter).BlksSVCEMap(blk)=1;
        end

    end

    function resetRootIOConfigParam()
        if isLib
            return;
        end


        configParam=1;
        if~ignoreExtInput
            inPortHandlesReduced=find_system(bdName,...
            'LookUnderMasks','on',...
            'SearchDepth','1',...
            'BlockType','Inport');
            externalInputPrmReduced=i_rootIONameConfigPrmReduced(inPortTable,...
            inPortHandlesReduced,configParam);
            set_param(bdName,'ExternalInput',externalInputPrmReduced);
        end


        configParam=2;
        if~ignoreSaveName
            outPortHandlesReduced=find_system(bdName,...
            'LookUnderMasks','on',...
            'SearchDepth','1',...
            'BlockType','Outport');
            outPortSaveNamePrmReduced=i_rootIONameConfigPrmReduced(outPortTable,...
            outPortHandlesReduced,configParam);
            set_param(bdName,'OutputSaveName',outPortSaveNamePrmReduced);
        end










    end
end




function i_deleteInactiveLines(optArgs,isLib)

    if isLib
        bdStructsVec=optArgs.LibInfoStructsVec;
    else
        bdStructsVec=optArgs.ModelRefModelInfoStructsVec;
    end

    for bdIter=1:length(bdStructsVec)
        bdName=bdStructsVec(bdIter).Name;
        blksAttribsMap=bdStructsVec(bdIter).BlksAttribsMap;

        lineHandle=i_findSystem(bdName,...
        'FindAll','on',...
        'type','line',...
        'Connected','off');

        if optArgs.getOptions().ValidateSignals
            portH=arrayfun(@(x)[get(x,'SrcPortHandle')',get(x,'DstPortHandle')'],lineHandle,'UniformOutput',false);
            portH=setdiff(Simulink.variant.utils.i_cell2mat(portH(:)'),-1);
        end

        delete_line(lineHandle);

        if~isLib&&optArgs.getOptions().ValidateSignals
            i_getPortsToAddSigSpecOnActiveInactiveJcn(optArgs,blksAttribsMap,portH);
        end
    end
end

function i_rewireAllRefBlocks(optArgs,isBdLib)



    if isBdLib
        bdStructsVec=optArgs.LibInfoStructsVec;
    else
        bdStructsVec=optArgs.ModelRefModelInfoStructsVec;
        modelInfoStructsVec=optArgs.ProcessedModelInfoStructsVec;





        allModelRefs=arrayfun(@(x)x.OrigName,modelInfoStructsVec,'UniformOutput',false);
    end


    for iter=1:numel(bdStructsVec)

        bdStruct=bdStructsVec(iter);


        blkAttribsMap=bdStruct.BlksAttribsMap;
        if isBdLib
            modelRefsDataStructsVec=bdStruct.ModelRefsDataStructsVec;
        else


            origModelName=bdStruct.OrigName;
            modelRefIdx=Simulink.variant.reducer.utils.searchNameInCell(origModelName,allModelRefs);
            Simulink.variant.reducer.utils.assert(~isempty(modelRefIdx))
            modelInfoStruct=modelInfoStructsVec(modelRefIdx);
            modelRefsDataStructsVec=modelInfoStruct.ModelRefsDataStructsVec;
        end


        libRefsDataStructsVec=bdStruct.LibRefsDataStructsVec;


        if~isempty(libRefsDataStructsVec)



            isLibForLibRewiring=true;
            libRefPortsNotToBeTerminated=i_rewireRefBlocks(optArgs,libRefsDataStructsVec,blkAttribsMap,isLibForLibRewiring,isBdLib);
        else
            libRefPortsNotToBeTerminated=[];
        end




        if~isempty(modelRefsDataStructsVec)



            isLibForModelRewiring=false;
            mdlRefPortsNotToBeTerminated=i_rewireRefBlocks(optArgs,modelRefsDataStructsVec,blkAttribsMap,isLibForModelRewiring,isBdLib);
        else
            mdlRefPortsNotToBeTerminated=[];
        end
        bdStructsVec(iter).PortsToIgnoreTerm=[bdStruct.PortsToIgnoreTerm,mdlRefPortsNotToBeTerminated,libRefPortsNotToBeTerminated];
    end

end







function i_deleteIVBlock(optArgs,ivBlock,idxR,idxD,isLib)
    portH=get_param(ivBlock,'PortHandles');
    parentPath=get_param(ivBlock,'Parent');
    firstPortH=[];
    secondPortH=[];
    lineH2Del=[];

    if optArgs.getOptions().ValidateSignals&&~isLib

        Simulink.variant.reducer.utils.assert(isKey(optArgs.CompiledPortAttributesMap,ivBlock));
        ivBlkAttr=optArgs.CompiledPortAttributesMap(ivBlock);
    end





    isVariantSourceBlock=strcmp(get_param(ivBlock,'BlockType'),'VariantSource');
    if isVariantSourceBlock

        firstPortH=portH.Inport(idxR);
        secondPortH=portH.Outport;
        lineH2Del=get(portH.Inport(idxD),'Line');
        if optArgs.getOptions().ValidateSignals&&~isLib

















            ivBlkAttr(idxD)=[];
        end
    elseif strcmp(get_param(ivBlock,'BlockType'),'VariantSink')

        firstPortH=portH.Inport;
        secondPortH=portH.Outport(idxR);
        lineH2Del=get(portH.Outport(idxD),'Line');
        if optArgs.getOptions().ValidateSignals&&~isLib


















            ivBlkAttr(idxD+1)=[];
        end
    end

    if numel(lineH2Del)>1
        lineH2Del=Simulink.variant.utils.i_cell2mat(lineH2Del);
    end
    delete_line(setdiff(lineH2Del,-1));

    ii_deleteUnconnectedLines(parentPath);

    srcLineH=get(firstPortH,'Line');
    destLineH=get(secondPortH,'Line');
    inPortH=[];
    outPortH=[];%#ok<*NASGU>
    if srcLineH~=-1
        inPortH=get(srcLineH,'SrcPortHandle');
        delete_line(srcLineH);
    else


        [~,inPortHTemp]=slvariants.internal.utils.getSourceBlockInfo(ivBlock,firstPortH);
        if inPortHTemp>0
            inPortH=inPortHTemp;
        end
    end

    if destLineH~=-1
        outPortH=get(destLineH,'DstPortHandle');
        delete_line(destLineH);
    else


        [~,outPortHTemp]=slvariants.internal.utils.getSourceBlockInfo(ivBlock,secondPortH);
        if outPortHTemp>0
            outPortH=outPortHTemp;
        end
    end

    if isempty(inPortH)&&~isempty(outPortH)


        gndBlkH=i_addBlockToUnconnectedPort(optArgs,outPortH(1),isLib);
        gndBlkPortH=get(gndBlkH,'PortHandles');
        inPortH=gndBlkPortH.Outport;


        tmpNOut=numel(outPortH);
        if tmpNOut>1


            add_line(parentPath,repmat(inPortH,tmpNOut-1,1),outPortH(2:end));
        end
    elseif isempty(outPortH)&&~isempty(inPortH)
        termBlkH=i_addBlockToUnconnectedPort(optArgs,inPortH,isLib);
        termBlkPortH=get(termBlkH,'PortHandles');
        outPortH=termBlkPortH.Inport;
    elseif~isempty(inPortH)&&~isempty(outPortH)


        tmpInPortH=repmat(inPortH,numel(outPortH),1);



        add_line(parentPath,tmpInPortH,outPortH,'autorouting','on');
    end



    isLabelModeSISOVarSrcNeeded=false;
    if~isempty(inPortH)
        isLabelModeSISOVarSrcNeeded=~ii_areSignalsSame(secondPortH,inPortH);
        if~isLabelModeSISOVarSrcNeeded







            isLabelModeSISOVarSrcNeeded=ii_isSigObjResolvedSignal(secondPortH);
        end
    end

    if~isLabelModeSISOVarSrcNeeded



        try
            slInternal('ClonePortProperties',inPortH,secondPortH);
        catch ex
        end
    else
        if~isempty(inPortH)&&~isempty(outPortH)
            for iii=1:numel(outPortH)
                delete_line(parentPath,inPortH,outPortH(iii));
            end
        end

        blkToAdd=Simulink.variant.reducer.types.VRedBlockToAdd;
        blkToAdd.System=parentPath;
        blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE;
        blkToAdd.BlkPath=[ivBlock,'_VS'];
        blkToAdd.SrcPort=inPortH;
        blkToAdd.DstPort=outPortH;

        try



            hBlk=i_addBlock(optArgs,blkToAdd);
            if isVariantSourceBlock


                set_param(hBlk,'OutputFunctionCall',...
                get_param(ivBlock,'OutputFunctionCall'));
            end

            hBlkPortH=get(hBlk,'PortHandles');

            if~isempty(inPortH)
                add_line(parentPath,inPortH,hBlkPortH.Inport,'autorouting','on');
            end
            if~isempty(outPortH)
                tempInPortH=repmat(hBlkPortH.Outport,numel(outPortH),1);
                add_line(parentPath,tempInPortH,outPortH,'autorouting','on');
            end





            slInternal('ClonePortProperties',hBlkPortH.Outport,secondPortH);

            if optArgs.getOptions().ValidateSignals&&~isLib

                Simulink.variant.reducer.utils.assert(numel(ivBlkAttr)==2)
                ivBlkAttr(1).Handle=hBlkPortH.Inport;
                ivBlkAttr(2).Handle=hBlkPortH.Outport;
                optArgs.CompiledPortAttributesMap(i_replaceCarriageReturnWithSpace(getfullname(hBlk)))=ivBlkAttr;
                optArgs.CompiledPortAttributesMap.remove(ivBlock);


                tmpBlk=ivBlock;
                if~isempty(inPortH)
                    tmpBlk=i_replaceCarriageReturnWithSpace(get(inPortH,'Parent'));
                end
                if isKey(optArgs.PortsToAddSigSpec,tmpBlk)
                    portStruct=optArgs.PortsToAddSigSpec(tmpBlk);
                    portStruct(end).DstPortHandle=hBlkPortH.Inport;
                    portStruct(end).PortAttributes.Handle=hBlkPortH.Inport;
                    optArgs.setPortsToAddSigSpec(tmpBlk,portStruct);
                end
            end
        catch ex
        end
    end


    delete_block(ivBlock);
    ii_deleteUnconnectedLines(parentPath);

    function ii_deleteUnconnectedLines(parentPath)

        uLineH=find_system(parentPath,...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'FindAll','on',...
        'type','line',...
        'Connected','off');
        delete_line(uLineH);
    end

    function same=ii_areSignalsSame(portH1,portH2)

        same=false;
        try
            same=strcmp(ii_getPortName(portH1),ii_getPortName(portH2));
        catch me

        end
    end

    function name=ii_getPortName(pH)
        name=get(pH,'Name');
        if isempty(name)




            name=get(pH,'PropagatedSignals');
        end
    end





    function flag=ii_isSigObjResolvedSignal(outPortH)
        flag=~isempty(get(outPortH,'SignalNameFromLabel'))...
        &&strcmp('on',get(outPortH,'MustResolveToSignalObject'));
    end





end



function ignorePortsModelRef=i_rewireRefBlocks(optArgs,refBlocksDataStructsVec,blkAttribsMap,isBlockLib,isBdLib)

























    ignorePortsModelRef=[];

    if optArgs.getOptions().ValidateSignals
        allBlkAttributesMap=blkAttribsMap;
    end
    for ii=1:numel(refBlocksDataStructsVec)
        try
            refBlockData=refBlocksDataStructsVec(ii);
            refMdl=refBlockData.Name;


            refBlk=refBlockData.RootPathPrefix;







            if refBlockData.IsProtected||Simulink.variant.reducer.utils.isBlockFromShippingLibrary(i_mat2cell(refBlk))





                continue;
            end







            if strcmp('ModelReference',get_param(refBlk,'BlockType'))
                eventPortInfo=get_param(refBlk,'ModelEventPorts');
                if~isempty(eventPortInfo)
                    ignorePortsModelRef=[ignorePortsModelRef,[eventPortInfo.EventPortHandle]];%#ok<AGROW>
                end
            end



            origBlkInH=refBlockData.RefInports;
            origBlkOutH=refBlockData.RefOutports;



            actualBlkInH=i_getInportBlockHandles(refMdl);
            actualBlkOutH=i_getOutportBlockHandles(refMdl);



            if isequal(origBlkInH,actualBlkInH)&&isequal(origBlkOutH,actualBlkOutH)
                continue;
            end









































































            nOrigBlkInH=numel(origBlkInH);
            inPortsToRetain=false(1,nOrigBlkInH);
            actualInIter=1;
            for inIter=1:nOrigBlkInH

                if actualInIter>numel(actualBlkInH)
                    break;
                end



                if isempty(setdiff(actualBlkInH{actualInIter},origBlkInH{inIter}))


                    inPortsToRetain(inIter)=true;
                    actualInIter=actualInIter+1;
                end
            end
            inportsOnModelBlock=1:nOrigBlkInH;
            inPortsToDelete=inportsOnModelBlock(~inPortsToRetain);
            inPortsToRetain=inportsOnModelBlock(inPortsToRetain);

            nOrigBlkOutH=numel(origBlkOutH);
            outPortsToRetain=false(1,nOrigBlkOutH);
            actualOutIter=1;
            for outIter=1:nOrigBlkOutH

                if actualOutIter>numel(actualBlkOutH)
                    break;
                end



                if isempty(setdiff(actualBlkOutH{actualOutIter},origBlkOutH{outIter}))


                    outPortsToRetain(outIter)=true;
                    actualOutIter=actualOutIter+1;
                end
            end
            outportOnModelBlock=1:nOrigBlkOutH;
            outPortsToDelete=outportOnModelBlock(~outPortsToRetain);
            outPortsToRetain=outportOnModelBlock(outPortsToRetain);

            refBlkPorts=get_param(refBlk,'PortHandles');
            refBlkInports=refBlkPorts.Inport;
            refBlkOutports=refBlkPorts.Outport;

            refBlkSrcLines=Simulink.variant.utils.i_cell2mat(...
            get_param(refBlkInports(inPortsToRetain),'Line'));
            refBlkSrcLines=setdiff(refBlkSrcLines,-1,'stable');

            refBlkDstLines=Simulink.variant.utils.i_cell2mat(...
            get_param(refBlkOutports(outPortsToRetain),'Line'));
            refBlkDstLines=setdiff(refBlkDstLines,-1,'stable');









            if isBlockLib&&optArgs.getOptions().ValidateSignals&&~isBdLib
                refBlk=i_replaceCarriageReturnWithSpace(refBlk);
                Simulink.variant.reducer.utils.assert(isKey(allBlkAttributesMap,refBlk));
                blkPortAttributeStructVec=allBlkAttributesMap(refBlk);


                ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;

                for inputIdx=1:numel(inPortsToRetain)

                    lineHandle=get(refBlkInports(inPortsToRetain(inputIdx)),'Line');



                    if lineHandle==-1,continue;end
                    ssPortInfo(inputIdx).DstPortHandle=...
                    refBlkInports(inPortsToRetain(inputIdx));


                    srcPortH=get(lineHandle,'SrcPortHandle');
                    ssPortInfo(inputIdx).SrcPortHandle=srcPortH;

                    ssPortInfo(inputIdx).PortAttributes=blkPortAttributeStructVec(inPortsToRetain(inputIdx));
                end


                for outputIdx=1:numel(outPortsToRetain)

                    lineHandle=get(refBlkOutports(outPortsToRetain(outputIdx)),'Line');



                    if lineHandle==-1,continue;end
                    ssPortInfo(numel(inPortsToRetain)+outputIdx).SrcPortHandle=...
                    refBlkOutports(outPortsToRetain(outputIdx));

                    dstPortHs=get(lineHandle,'DstPortHandle');
                    ssPortInfo(numel(inPortsToRetain)+outputIdx).DstPortHandle=...
                    dstPortHs;


                    ssPortInfo(numel(inPortsToRetain)+outputIdx).PortAttributes=...
                    blkPortAttributeStructVec(numel(origBlkInH)+outPortsToRetain(outputIdx));
                end
                ssPortBlockInfo.portParent=refBlk;
                ssPortBlockInfo.ssPortInfo=ssPortInfo;
                optArgs.setPortsToAddSigSpec(ssPortBlockInfo.portParent,ssPortBlockInfo.ssPortInfo);
            end




            refBlkSrcLinesToDel=Simulink.variant.utils.i_cell2mat(...
            get_param(refBlkInports(inPortsToDelete),'Line'));
            refBlkSrcLinesToDel=setdiff(refBlkSrcLinesToDel,-1,'stable');

            refBlkDstLinesToDel=Simulink.variant.utils.i_cell2mat(...
            get_param(refBlkOutports(outPortsToDelete),'Line'));
            refBlkDstLinesToDel=setdiff(refBlkDstLinesToDel,-1,'stable');


























            if optArgs.getOptions().ValidateSignals&&~isBdLib
                for lineToDelId=1:numel(refBlkSrcLinesToDel)

                    srcPortInactiveLine=get(refBlkSrcLinesToDel(lineToDelId),'SrcPortHandle');
                    if srcPortInactiveLine==-1
                        continue;
                    end

                    srcBlk=i_replaceCarriageReturnWithSpace(get(srcPortInactiveLine,'Parent'));
                    Simulink.variant.reducer.utils.assert(isKey(allBlkAttributesMap,srcBlk));
                    attributeStructVec=allBlkAttributesMap(srcBlk);
                    optArgs.populatePortsToAddBusHierSSOrSigSpec(srcPortInactiveLine,0,attributeStructVec,0);
                end
            end


            delete_line([refBlkSrcLinesToDel(:)',refBlkDstLinesToDel(:)']);



            portNamesToRetain=get_param(refBlkOutports(outPortsToRetain),'Name');
            portNamesToRetain=i_mat2cell(portNamesToRetain);









            inPortsIdxToBeIgnored=(numel(inPortsToRetain)+1):numel(origBlkInH);
            outPortsIdxToBeIgnored=(numel(outPortsToRetain)+1):numel(origBlkOutH);
            ignorePortsModelRef=unique([ignorePortsModelRef,refBlkInports(inPortsIdxToBeIgnored),refBlkOutports(outPortsIdxToBeIgnored)]);


            refBlkPath=get_param(refBlk,'Parent');

            for ij=1:numel(refBlkSrcLines)
                refBlkSrclineCurr=refBlkSrcLines(ij);

                refBlkInPortSideSrcPort=get(refBlkSrclineCurr,'SrcPortHandle');
                delete_line(refBlkSrclineCurr);




                if refBlkInPortSideSrcPort~=-1
                    add_line(refBlkPath,refBlkInPortSideSrcPort,refBlkInports(ij),'autorouting','on');
                end

            end

            for ij=1:numel(refBlkDstLines)
                refBlkDstlineCurr=refBlkDstLines(ij);

                refBlkOutPortSideDstPorts=get(refBlkDstlineCurr,'DstPortHandle');
                delete_line(refBlkDstlineCurr);


                refBlkOutPortSideDstPorts=refBlkOutPortSideDstPorts(refBlkOutPortSideDstPorts~=-1);

                if~isempty(refBlkOutPortSideDstPorts)

                    add_line(refBlkPath,repmat(refBlkOutports(ij),numel(refBlkOutPortSideDstPorts),1),refBlkOutPortSideDstPorts,'autorouting','on');
                end

            end





            for ik=1:numel(portNamesToRetain)
                set_param(refBlkOutports(ik),'Name',portNamesToRetain{ik});
            end

        catch me


            errid='Simulink:VariantReducer:InternalErrRewireRef';
            errmsg=message(errid,refBlk);
            throwAsCaller(MException(errmsg));
        end
    end
end








function i_getPortsToAddSigSpecOnActiveInactiveJcn(optArgs,blksAttribsMap,portH)


















    if~optArgs.getOptions().ValidateSignals
        return;
    end

    for iter=1:numel(portH)
        pH=portH(iter);
        blk=i_replaceCarriageReturnWithSpace(get(pH,'Parent'));





        if~strcmp(get_param(blk,'Commented'),'off')
            continue;
        end





        if slInternal('isVariantSubsystem',get_param(get_param(blk,'Parent'),'Handle'))
            return;
        end

        Simulink.variant.reducer.utils.assert(isKey(blksAttribsMap,blk));

        compPortAttrStructsVec=blksAttribsMap(blk);
        if isempty(compPortAttrStructsVec)
            return;
        end



        blkType=get_param(blk,'BlockType');
        if slInternal('isVariantSubsystem',get_param(blk,'Handle'))...
            ||strcmp(blkType,'VariantSource')...
            ||strcmp(blkType,'VariantSink')
            continue;
        end

        portType=get(pH,'PortType');

        switch portType
        case 'inport'
            optArgs.populatePortsToAddBusHierSSOrSigSpec(0,pH,compPortAttrStructsVec,1);
        case 'outport'
            optArgs.populatePortsToAddBusHierSSOrSigSpec(pH,0,compPortAttrStructsVec,0);
        end
    end
end


function blkUniqH=i_addBlockToUnconnectedPort(optArgs,port,isLib)
    blkUniqH=[];
    origBlkPath=i_replaceCarriageReturnWithSpace(get_param(port,'Parent'));
    blkToAdd=Simulink.variant.reducer.types.VRedBlockToAdd;
    blkToAdd.System=get_param(origBlkPath,'Parent');




    blkAttribsVec=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct();
    origBlkCell={};
    if optArgs.CompiledPortAttributesMap.isKey(origBlkPath)
        blkAttribsVec=optArgs.CompiledPortAttributesMap(origBlkPath);
    elseif any(strcmp(get_param(port,'PortType'),{'inport','trigger','enable','reset'}))
        try
            portNumber=get(port,'PortNumber');
            [blkAttribsVec,origBlkCell]=getCompiledPortAttributesForLibBlk(optArgs,origBlkPath,portNumber);
        catch me
            throwAsCaller(me);
        end
    end

    switch lower(get_param(port,'PortType'))
    case{'outport','state'}

        blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.TERMINATOR;
        blkToAdd.BlkPath=[origBlkPath,'_Term'];
        blkToAdd.SrcPort=port;
        blkToAdd.DstPort=-1;



        try
            blkUniqH=i_addBlock(optArgs,blkToAdd);
            terminatorPortH=get(blkUniqH,'PortHandles');
            add_line(get_param(origBlkPath,'Parent'),...
            port,...
            terminatorPortH.Inport,...
            'autorouting','on');

            if optArgs.getOptions().ValidateSignals&&~isLib



                optArgs.populatePortsToAddBusHierSSOrSigSpec(port,terminatorPortH.Inport,blkAttribsVec,0);
            end

        catch ex
            delete_block(blkUniqH);
        end

    case{'inport','trigger','enable','reset'}

        blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.GROUND;
        blkToAdd.BlkPath=[origBlkPath,'_Ground'];
        blkToAdd.SrcPort=-1;
        blkToAdd.DstPort=port;





        try
            blkUniqH=i_addBlock(optArgs,blkToAdd);
            groundPortH=get(blkUniqH,'PortHandles');
            add_line(get_param(origBlkPath,'Parent'),...
            groundPortH.Outport,...
            port,...
            'autorouting','on');




            isBusCase=true;
            optArgs.populatePortsToAddBusHierSSOrSigSpec(groundPortH.Outport,...
            port,blkAttribsVec,1,isLib,isBusCase,origBlkCell);
        catch ex
            delete_block(blkUniqH);
        end

    end

end


function i_addTermGnd(optArgs,bdIdx,isLib)

    if isLib
        bdName=optArgs.LibInfoStructsVec(bdIdx).Name;
        portsToIgnoreTerm=optArgs.LibInfoStructsVec(bdIdx).PortsToIgnoreTerm;
    else
        bdName=optArgs.ModelRefModelInfoStructsVec(bdIdx).Name;
        portsToIgnoreTerm=optArgs.ModelRefModelInfoStructsVec(bdIdx).PortsToIgnoreTerm;
    end

    blkHandles=i_findSystem(bdName);

    if isLib


        blkHandlesToIgnore=i_findSystem(bdName,...
        'AllBlocks','on',...
        'SearchDepth',1);
        blkHandles=setdiff(blkHandles,blkHandlesToIgnore);
    else
        blkHandles=blkHandles(2:end);
    end

    for iter=1:numel(blkHandles)
        blkParent=get_param(blkHandles{iter},'Parent');
        isHidden=get_param(blkHandles{iter},'Hidden');
        if strcmp(isHidden,'on')


            continue;
        end


        hBlk=Simulink.SubsystemType(blkParent);
        if hBlk.isVariantSubsystem()
            continue;
        end

        portHandles=get_param(blkHandles{iter},'PortHandles');





        portIn=[portHandles.Inport,portHandles.Trigger,portHandles.Enable,portHandles.Reset];
        portOut=[portHandles.Outport,portHandles.State];

        portIn=setdiff(portIn,portsToIgnoreTerm);
        portOut=setdiff(portOut,portsToIgnoreTerm);

        for iter1=1:numel(portIn)
            if(get(portIn(iter1),'Line')==-1)


                [~,srcPort]=slvariants.internal.utils.getSourceBlockInfo(blkHandles{iter},portIn(iter1));
                if srcPort>0
                    continue;
                end
                i_addBlockToUnconnectedPort(optArgs,portIn(iter1),isLib);
            end
        end
        for iter2=1:numel(portOut)
            if(get(portOut(iter2),'Line')==-1)
                if isequal(get_param(blkHandles{iter},'IOType'),'siggen')


                    continue;
                end
                i_addBlockToUnconnectedPort(optArgs,portOut(iter2),isLib);
            end
        end
    end

end

function i_retainOrRemoveCommentedBlks(optArgs,bdName)


    commentedBlks=find_system(bdName,...
    'regexp','on',...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on',...
    'Commented','on|through');

    commBlkIter=1;
    while commBlkIter<numel(commentedBlks)
        currBlk=commentedBlks(commBlkIter);



        if strcmp(get_param(currBlk,'BlockType'),'SubSystem')
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                blksInCurrBlk=find_system(currBlk,...
                'regexp','on',...
                'LookUnderMasks','on',...
                'IncludeCommented','on',...
                'Commented','on|through');
            else
                blksInCurrBlk=find_system(currBlk,...
                'regexp','on',...
                'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.allVariants,...
                'IncludeCommented','on',...
                'Commented','on|through');
            end

            blksInCurrBlk=blksInCurrBlk(2:end);

            commentedBlks=setdiff(commentedBlks,blksInCurrBlk);
        end
        commBlkIter=commBlkIter+1;
    end










    for iter=1:numel(commentedBlks)
        try
            currBlk=commentedBlks{iter};
            blksEncountered=get_param(currBlk,'Handle');
            currBlkPorts=get_param(currBlk,'PortHandles');





            linesInputSide=Simulink.variant.utils.i_cell2mat(...
            get([currBlkPorts.Inport,currBlkPorts.Enable...
            ,currBlkPorts.Trigger,currBlkPorts.LConn...
            ,currBlkPorts.Ifaction,currBlkPorts.Reset],'Line'));
            linesOutputSide=Simulink.variant.utils.i_cell2mat(...
            get([currBlkPorts.Outport,currBlkPorts.State...
            ,currBlkPorts.RConn],'Line'));


            linesInputSide=linesInputSide(~(linesInputSide==-1));
            linesOutputSide=linesOutputSide(~(linesOutputSide==-1));





            linesOnEitherSide=[linesInputSide;linesOutputSide];



            isNotCommented=false;
            while~isNotCommented
                if isempty(linesInputSide)&&isempty(linesOutputSide)




                    delete_block(currBlk);
                    try delete_line(linesOnEitherSide);catch,end
                    isNotCommented=true;
                else




                    [isNotCommented,blksEncountered,linesInputSide,linesOutputSide]=i_traverseEitherSidesOfBlk(blksEncountered,linesInputSide,linesOutputSide);
                end
            end
        catch me
            if~isempty(me.cause)&&iscell(me.cause)&&any(strcmp('physmod:pm_sli:RTM:RunTimeModule:error:user:CannotRemoveBlockInRestrictedMode',me.cause{1}.identifier))



                warnid='Simulink:Variants:ReducerCannotRemoveRestrictedCommented';
            else
                warnid='Simulink:Variants:ReducerCannotRemoveCommented';
            end
            warnmsg=message(warnid,currBlk,bdName);
            warnObj=MException(warnmsg);
            optArgs.Warnings{end+1}=warnObj;
        end
    end

end

function[isNotCommented,blksEncountered,linesInputSide,linesOutputSide]=i_traverseEitherSidesOfBlk(blksEncountered,linesInputSide,linesOutputSide)









    blksInputSide=Simulink.variant.utils.i_cell2mat(get(linesInputSide,'SrcBlockHandle'));
    blksOutputSide=Simulink.variant.utils.i_cell2mat(get(linesOutputSide,'DstBlockHandle'));

    blksInputSide=blksInputSide(~(blksInputSide==-1));
    blksOutputSide=blksOutputSide(~(blksOutputSide==-1));


    blksInputSide=setdiff(blksInputSide,blksEncountered);
    blksOutputSide=setdiff(blksOutputSide,blksEncountered);

    blksEncountered=[blksEncountered;blksInputSide;blksOutputSide];


    isNotCommented=false;
    if~isempty([blksInputSide;blksOutputSide])
        isNotCommented=any(strcmp('off',get_param([blksInputSide;blksOutputSide],'Commented')));
    end



    if~isNotCommented

        if~isempty(blksInputSide)




            portsInputSide=Simulink.variant.utils.i_cell2mat(cellfun(@(x)([x.Inport,x.Enable,x.Trigger,x.LConn,x.Ifaction,x.Reset])',...
            i_mat2cell(get_param(blksInputSide,'PortHandles')),'UniformOutput',false));
            linesInputSide=Simulink.variant.utils.i_cell2mat(get(portsInputSide,'Line'));

            linesInputSide=linesInputSide(~(linesInputSide==-1));
        else

            linesInputSide=[];
        end

        if~isempty(blksOutputSide)


            portsOutputSide=Simulink.variant.utils.i_cell2mat(cellfun(@(x)([x.Outport,x.State,x.RConn])',...
            i_mat2cell(get_param(blksOutputSide,'PortHandles')),'UniformOutput',false));
            linesOutputSide=Simulink.variant.utils.i_cell2mat(get(portsOutputSide,'Line'));

            linesOutputSide=linesOutputSide(~(linesOutputSide==-1));
        else

            linesOutputSide=[];
        end

    end
end

function out=i_getConfigSetIOVarNames(str)

















    try

        out=builtin('_parse_top_level_expressions',str);
    catch ex


        out=str;
    end
end

function i_handleVarCondnOfSingleChoiceVariantInfoBlockInReducedModel(optArgs,...
    varBlk,isActiveAcrossAllConfigs,varBlockType)


















    blkCond='';

    Simulink.variant.reducer.utils.assert((varBlockType.isVariantSimulinkFunction||varBlockType.isVariantIRTSubsystem),...
    'This function can be called only for Variant Simulink Function / Variant IRT blocks');

    if varBlockType.isVariantSimulinkFunction


        portBlk=find_system(varBlk,...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'BlockType','TriggerPort');
        portBlk=Simulink.variant.utils.i_cell2mat(portBlk);

        if~isempty(portBlk)
            if strcmp(get_param(portBlk,'Variant'),'on')
                blkCond=get_param(portBlk,'VariantControl');
            end
        end
    elseif varBlockType.isVariantIRTSubsystem
        portBlk=find_system(varBlk,...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'BlockType','EventListener');
        portBlk=Simulink.variant.utils.i_cell2mat(portBlk);
        if~isempty(portBlk)
            if strcmp(get_param(portBlk,'Variant'),'on')
                blkCond=get_param(portBlk,'VariantControl');
            end
        end
    end

    if isempty(blkCond),return;end



    if isActiveAcrossAllConfigs
        set_param(portBlk,'VariantControl','');
        set_param(portBlk,'Variant','off');
    else




        optArgs.i_modifyVarCondExpr(varBlk,varBlockType,portBlk,blkCond);
    end
end


function[portMap,ignoreFlag]=i_rootIONameConfigPrm(modelName,configParam)

    portMap=containers.Map;


    ignoreFlag=false;
    portHandles={};
    switch configParam
    case 1
        portHandles=find_system(modelName,...
        'LookUnderMasks','on',...
        'SearchDepth','1',...
        'BlockType','Inport');
        nameConfigPrm=get_param(modelName,'ExternalInput');
    case 2
        portHandles=find_system(modelName,...
        'LookUnderMasks','on',...
        'SearchDepth','1',...
        'BlockType','Outport');
        nameConfigPrm=get_param(modelName,'OutputSaveName');



    end

    if isempty(portHandles)
        ignoreFlag=true;
        return;
    end








    varName=i_getConfigSetIOVarNames(nameConfigPrm);



    if numel(varName)<=1
        ignoreFlag=true;
    else








        portMap=containers.Map(portHandles,repmat({''},1,length(portHandles)));
        nIter=min(length(varName),length(portHandles));
        for iter=1:nIter
            portMap(portHandles{iter})=varName{iter};
        end
    end
end


function rootIONamePrmReduced=i_rootIONameConfigPrmReduced(...
    portMap,portHandlesReduced,configParam)

    switch configParam
    case 1
        rootIONamePrmReduced='[]';
    case 2
        rootIONamePrmReduced='yout';


    end

    nIter=min(length(portMap),length(portHandlesReduced));
    if nIter==0
        return;
    end

    rootIONamePrmReduced=portMap(portHandlesReduced{1});
    for iter=2:nIter
        outName=portMap(portHandlesReduced{iter});
        if~isempty(outName)
            rootIONamePrmReduced=[rootIONamePrmReduced,',',outName];%#ok<AGROW>
        end
    end

end



function err=i_verifyAACONForThisBlock(varBlockPath,bdNameRedBDNameMap,modelName)
    err=[];
    if Simulink.variant.reducer.utils.isAnalyzeAllChoicesEnabled(varBlockPath)
        return;
    end
    if Simulink.variant.reducer.utils.isLabelMode(varBlockPath)
        return;
    end
    redmodelNameModelNameMap=i_invertMap(bdNameRedBDNameMap);
    varBlockPathOrig=i_convertRedBlockNameToOrig(varBlockPath,redmodelNameModelNameMap);
    msgid='Simulink:VariantReducer:AACOffForMultipleChoiceActiveBlocksLate';
    errmsg=message(msgid,modelName,varBlockPathOrig);
    err=MException(errmsg);
end







