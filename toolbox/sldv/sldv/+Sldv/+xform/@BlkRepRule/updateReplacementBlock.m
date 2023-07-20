function updateReplacementBlock(obj,blockInfo)




    inlineOnlyMode=obj.InlineOnlyMode;

    if obj.UseOriginalBlockAsReplacement
        return;
    end

    blkReplacer=Sldv.xform.BlkReplacer.getInstance();

    if strcmp(obj.BlockType,'ModelReference')&&...
        (~isempty(strfind(obj.ReplacementPath,'simulink'))||...
        ~isempty(strfind(obj.ReplacementPath,'built-in')))

        obj.ReplacementBlockUpdatedOnInstance=true;

        BlockH=blockInfo.ReplacementInfo.BlockToReplaceH;

        obj.ReplacementLib=blockInfo.ReplacementInfo.LibForModelRefCopy;

        origBlkPos=get_param(BlockH,'Position');
        widthBlk=origBlkPos(3)-origBlkPos(1);
        heightBlk=origBlkPos(4)-origBlkPos(2);

        if blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk
            targetBlock=['sldvBlockReplacementSubsysCopyMasked_',blockInfo.RefMdlName];
        elseif blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
            blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk
            targetBlock=['sldvBlockReplacementSubsysCopySignalSpecReq_',blockInfo.RefMdlName];
        else
            targetBlock=['sldvBlockReplacementSubsysCopy_',blockInfo.RefMdlName];
        end


        repSubsystem=find_system(obj.ReplacementLib,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','Name',targetBlock);
        if~isempty(repSubsystem)&&...
            isAlreadyGenerated(blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk,...
            (blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk),...
            repSubsystem{1})
            obj.ReplacementBlk=['./',get_param(repSubsystem{1},'Name')];
        else
            spacing=50;
            [xPos,yPos]=Sldv.xform.BlkRepRule.findLocation(obj.ReplacementLib,spacing,widthBlk);
            susbystemPathOnLib=[obj.ReplacementLib,'/',targetBlock];
            position=[xPos,yPos,xPos+widthBlk,yPos+heightBlk];
            orientations=get_param(BlockH,'Orientation');
            namePlacement=get_param(BlockH,'NamePlacement');

            isExportFcnMdl=strcmp(get_param(blockInfo.RefMdlName,'IsExportFunctionModel'),'on');
            if isExportFcnMdl
                atomicVal='off';
            else
                atomicVal='on';
            end

            try



                refMdlH=get_param(blockInfo.RefMdlName,'Handle');
                obsMdlNames=Simulink.observer.internal.getObserverModelNamesInBD(refMdlH);
                if~isempty(obsMdlNames)&&isequal(slfeature('ObserverSLDV'),1)



                    tmpLibFullPath=blkReplacer.getLibForMdlWithObs;
                    newSubsystemSrc=copyMdlRefContents(refMdlH,tmpLibFullPath);
                    blkReplacer.addBlock(newSubsystemSrc,susbystemPathOnLib,...
                    'Position',position,...
                    'Orientation',orientations,...
                    'NamePlacement',namePlacement,...
                    'TreatAsAtomicUnit',atomicVal);

                    Sldv.close_system(tmpLibFullPath,0);
                    delete(tmpLibFullPath);
                else
                    blkReplacer.addBlock(obj.ReplacementPath,susbystemPathOnLib,...
                    'Position',position,...
                    'Orientation',orientations,...
                    'NamePlacement',namePlacement,...
                    'TreatAsAtomicUnit',atomicVal);
                    Simulink.BlockDiagram.copyContentsToSubSystem(blockInfo.RefMdlName,susbystemPathOnLib);
                end
            catch Mex
                newExc=MException('Sldv:xform:BlkReplacer:BlkReplacer:ErrorCopyingModel',...
                getString(message('Sldv:xform:BlkReplacer:BlkReplacer:ErrorCopyingModel',...
                blockInfo.RefMdlName)));


                Mex=getMExObjectWithoutHandles(Mex);
                newExc=newExc.addCause(Mex);
                throw(newExc);
            end



            modelWs=get_param(blockInfo.RefMdlName,'modelworkspace');
            InlinedWithNewSubsys=~isempty(modelWs.whos);

            if InlinedWithNewSubsys||~inlineOnlyMode
                if blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk||...
                    blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
                    blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk


                    opts={'SearchDepth',1,'FollowLinks','on',...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'BlockType','SubSystem'};

                    currentSubsystems=find_system(obj.ReplacementLib,opts{:});
                    blockToConvertH=get_param(susbystemPathOnLib,'Handle');
                    obj.addToOpenedModelsList(obj.ReplacementLib);
                    Sldv.load_system(obj.ReplacementLib);
                    Simulink.BlockDiagram.createSubSystem(blockToConvertH);
                    newSubsystems=find_system(obj.ReplacementLib,opts{:});
                    newSubsystem=setdiff(newSubsystems,currentSubsystems);
                    newSSBlock=newSubsystem{1};
                    fixPortNamesForMdlkBlkVariantChoice(newSSBlock,BlockH,blockToConvertH)
                    set_param(newSSBlock,...
                    'Name',targetBlock,...
                    'Position',position,...
                    'Orientation',orientations,...
                    'NamePlacement',namePlacement);
                    obj.InlinedWithNewSubsys=true;
                end
            end


            activeDTOSettings=get_param(blockInfo.RefMdlName,'DataTypeOverride');
            set_param(susbystemPathOnLib,'DataTypeOverride',activeDTOSettings);
            obj.ReplacementBlk=['./',targetBlock];
        end
    else
        obj.ReplacementLib=bdroot(obj.ReplacementPath);
        index=find(obj.ReplacementPath=='/');
        obj.ReplacementBlk=['.',obj.ReplacementPath(index(1):end)];
    end
end

function out=isAlreadyGenerated(isMaskConstructedMdlBlk,isSignalSpecReqTriggeredOrEnabledMdlBlk,subsystem)
    subsystemName=get_param(subsystem,'Name');
    if isMaskConstructedMdlBlk
        out=contains(subsystemName,'sldvBlockReplacementSubsysCopyMasked_');
    elseif isSignalSpecReqTriggeredOrEnabledMdlBlk
        out=contains(subsystemName,'sldvBlockReplacementSubsysCopySignalSpecReq_');
    else
        out=true;
    end
end


function fixPortNamesForMdlkBlkVariantChoice(outerSubsys,origBlkH,innerSubSys)




    parentSubsysType=Simulink.SubsystemType(get_param(origBlkH,'Parent'));
    isVariantChoice=parentSubsysType.isVariantSubsystem;
    if isVariantChoice
        outerSubsysH=get_param(outerSubsys,'handle');
        innerSubSysH=get_param(innerSubSys,'handle');
        [innerInBlkHs,innerOutBlkHs,innerTriggerBlkH,innerEnableBlkH]=...
        Sldv.utils.getBlockHandlesForPortsInSubsys(innerSubSysH);

        innerSubSysPh=get_param(innerSubSysH,'PortHandles');

        [outerInBlkHs,outerOutBlkHs]=...
        Sldv.utils.getBlockHandlesForPortsInSubsys(outerSubsysH);


        arrayfun(@(h)set_param(h,'Name',[get_param(h,'name'),'_tempSldv']),...
        [outerInBlkHs;outerOutBlkHs]);


        for idx=1:length(outerOutBlkHs)
            set_param(outerOutBlkHs(idx),'Name',...
            get_param(innerOutBlkHs(idx),'Name'));
        end




        for idx=1:length(outerInBlkHs)
            inBlkH=outerInBlkHs(idx);
            ph=get_param(inBlkH,'porthandles');
            outLine=get_param(ph.Outport,'line');
            dstH=get_param(outLine,'DstPortHandle');

            if ismember(dstH,innerSubSysPh.Enable)

                newName=get_param(innerEnableBlkH,'Name');
            elseif ismember(dstH,innerSubSysPh.Trigger)

                newName=get_param(innerTriggerBlkH,'Name');
            else

                portNum=get_param(dstH,'PortNumber');
                actBlkH=innerInBlkHs(portNum);
                newName=get_param(actBlkH,'Name');
            end
            set_param(inBlkH,'Name',newName);
        end
    end
end

function newMex=getMExObjectWithoutHandles(Mex)
    newMex=MException(Mex.identifier,Mex.message);
    for idx=1:length(Mex.cause)
        newMex=newMex.addCause(getMExObjectWithoutHandles(Mex.cause{idx}));
    end
end

function newSubsystemPath=copyMdlRefContents(refMdlH,libFullPath)






    [~,libName,ext]=fileparts(libFullPath);
    slInternal(['snapshot_',ext(2:end)],get_param(refMdlH,'Name'),libFullPath);
    Sldv.load_system_no_callbacks(libFullPath);
    libH=get_param(libName,'Handle');






    blkFilter=Simulink.FindOptions('MatchFilter',@Sldv.utils.findObsBlks,'SearchDepth',1);
    blks=Simulink.findBlocks(libH,blkFilter);
    Simulink.BlockDiagram.createSubsystem(blks);



    newSubsystem=find_system(libH,'SearchDepth',1,'BlockType','SubSystem');
    newSubsystemPath=[libName,'/',get_param(newSubsystem,'Name')];
end
