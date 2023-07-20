function vssHandle=convertToVariant(blockH)




































    narginchk(1,1);


    if ischar(blockH)
        blockH=get_param(blockH,'Handle');
    end





    if~isscalar(blockH)
        DAStudio.error('Simulink:Variants:InputToConvertToVariantMustBeScalar');
    end

    try


        if ishandle(blockH)


            if strcmp(get_param(blockH,'Type'),'block_diagram')
                DAStudio.error('Simulink:Variants:convertToVariantForBlockDiagram');
            end



            if(strcmp(get_param(blockH,'BlockType'),'SubSystem')&&~isempty(get_param(blockH,DAStudio.message('Simulink:VariantBlockPrompts:ChoiceSelectorParamName'))))
                DAStudio.error('Simulink:Variants:convertToVariantForVAS',get_param(blockH,'Name'));
            end


            if slfeature('CSSToVSSInplace')==1&&...
                (strcmp(get_param(blockH,'BlockType'),'SubSystem')&&...
                ~strcmp(get_param(blockH,'TemplateBlock'),''))
                parent_block=get_param(blockH,'TemplateBlock');





                if(~strcmpi(parent_block,'self'))
                    parts=regexp(parent_block,'/','split');
                    try
                        parent_library=parts{1};
                        open_system(parent_library);


                        hilite_system(parent_block,'find');
                    catch
                    end
                    DAStudio.error('Simulink:Variants:convertToVariantForCSSReference',get_param(blockH,'Name'),parent_block);
                end

                if strcmp(get_param(bdroot(blockH),'Lock'),'on')
                    set_param(bdroot(blockH),'Lock','off');
                end








                vssHandle=slInternal('ConvertToVariantSubsystem',blockH,1,'',true);

                return;
            end


            miMap=containers.Map();


            if strcmpi(get_param(bdroot(blockH),'BlockDiagramType'),'library')&&strcmp(get_param(bdroot(blockH),'Lock'),'on')
                DAStudio.error('Simulink:Variants:ConvertingLockedLibraryBlockToVSSFail',get_param(blockH,'Name'));
            end

            isMdlRef=strcmp(get_param(blockH,'BlockType'),'ModelReference');
            isSubsys=strcmp(get_param(blockH,'BlockType'),'SubSystem');
            isVarMdlRef=isMdlRef&&strcmp(get_param(blockH,'Variant'),'on');
            isArchModel=Simulink.internal.isArchitectureModel(bdroot(blockH));





            if~(isSubsys||isMdlRef)
                DAStudio.error('Simulink:blocks:NotValidSubsystemToConvertToVariant',get_param(blockH,'Name'));
            end


            if isSubsys&&sltp.BlockAccess(blockH).isBlockCreatingPartitions
                DAStudio.error('Simulink:blocks:PartitionedSubsystemConvertToVariantInvalid',get_param(blockH,'Name'));
            end

















            if isArchModel
                allowedBlockH=get_param(bdroot(blockH),'AllowedBlockHandlesForConvertToVariant');
                canConvertComp=~isempty(allowedBlockH(allowedBlockH==blockH));
                if~canConvertComp
                    DAStudio.error('Simulink:blocks:ConvertToVariantUnsupportedInArchitectureModel');
                end
            end










            if isMdlRef&&...
                ~slInternal('getReferencedModelFileInformation',get_param(blockH,'ModelFile'))&&...
                ~isvarname(get_param(blockH,'ModelName'))&&...
                ~isVarMdlRef
                DAStudio.error('Simulink:Variants:ConvertToVariantWithInvalidNameNotSupported',get_param(blockH,'Name'),get_param(blockH,'ModelName'));
            end

            if isMdlRef&&~isVarMdlRef





                if isempty(get_param(blockH,'ModelFile'))
                    DAStudio.error('Simulink:Variants:ConvertToVariantForModelBlockWithNoReferredModelNotSupported',get_param(blockH,'ModelName'),get_param(blockH,'Name'));
                end




                mi=Simulink.internal.vmgr.VMUtils.getModelInterface(get_param(blockH,'ModelFile'),miMap);
                if isempty(mi)
                    DAStudio.error('Simulink:Variants:ConvertToVariantwithOldModelDefForMdl',getfullname(blockH));
                end
            end




            if isequal(get_param(blockH,'LinkStatus'),'implicit')
                DAStudio.error('Simulink:Variants:ConvertToVariantForImplicitLibraryNotAllowed',get_param(blockH,'Name'));
            end

            if isVarMdlRef




                mdlFile=get_param(blockH,'ModelFile');
                mi=Simulink.internal.vmgr.VMUtils.getModelInterface(mdlFile,miMap);


                Simulink.internal.vmgr.VMUtils.errorIfRefModelHasOldModels(blockH,miMap);



                if~isempty(mi)&&(numel(mi.Inports)+numel(mi.Outports)+numel(mi.Enableports)+numel(mi.Trigports)~=sum(get_param(blockH,'ports')))
                    DAStudio.error('Simulink:Variants:ConvertToVariantwithBadModelDef',getfullname(blockH));
                end



                if~isequal(get_param(blockH,'LinkStatus'),'none')
                    DAStudio.error('Simulink:Variants:ConvertToVariantForLibraryModelVarNotAllowed',get_param(blockH,'Name'));
                end
            end

            if isMdlRef&&~isVarMdlRef






                if strcmp(get_param(blockH,'ShowModelInitializePort'),'on')||...
                    strcmp(get_param(blockH,'ShowModelReinitializePorts'),'on')||...
                    strcmp(get_param(blockH,'ShowModelResetPorts'),'on')||...
                    (strcmp(get_param(blockH,'ScheduleRates'),'on')&&...
                    strcmp(get_param(blockH,'ScheduleRatesWith'),'Ports')&&...
                    ~strcmp(get_param(blockH,'IsModelRefExportFunction'),'on'))
                    DAStudio.error('Simulink:Variants:ConvertToVariantWithIRTNotSupported',get_param(blockH,'Name'));





                elseif sltp.BlockAccess(blockH).isBlockCreatingPartitions
                    DAStudio.error('Simulink:Variants:ConvertToVariantScheduledWithScheduleEditorNotSupported',get_param(blockH,'Name'));
                end

            end









            if Simulink.internal.vmgr.VMUtils.isPhysmodBlock(blockH)&&isfield(get_param(bdroot(blockH),'ObjectParameters'),'EditingMode')
                editMode=get_param(bdroot(blockH),'EditingMode');
                if strcmp(editMode,'Restricted')
                    DAStudio.error('Simulink:Variants:convertToVariantNotAllowed',get_param(bdroot(blockH),'Name'));
                end
            end






            if isSubsys
                permissionState=get_param(blockH,'Permissions');
                if isequal(permissionState,'NoReadOrWrite')
                    set_param(blockH,'Permissions','ReadOnly');
                    onCleanupPermissionState=onCleanup(@()set_param(blockH,'Permissions',permissionState));
                end
            end


            slreq.utils.onHierarchyChange('preChange',blockH);





            resolveLinkStatus=false;





            if isequal(get_param(blockH,'LinkStatus'),'resolved')

                set_param(blockH,'LinkStatus','inactive');
                resolveLinkStatus=true;
            end





            [disViewers,disAxes]=loc_disconnectAllViewers(blockH);



            cacheSelection=get_param(blockH,'selected');




            slInternal('ClearAllIOConnections',blockH);



            isCommented=get_param(blockH,'Commented');
            set_param(blockH,'Commented','off');












            attribStr=get_param(blockH,'AttributesFormatString');


            blkConnMapBefore=Simulink.internal.vmgr.VMUtils.GetConnectionMapping(blockH);
            pH=get_param(blockH,'PortHandles');




            signalMappings=Simulink.internal.vmgr.VMUtils.GetSignalMappings(blockH);





            Simulink.internal.vmgr.VMUtils.hasGapPorts(blockH,miMap);


            [iNames,oNames,cNamesAndTypes]=Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(blockH,miMap);
            iNames=[iNames,cNamesAndTypes.Names];






            if isMdlRef
                numInportsFrompH=numel(pH.Inport)+numel(pH.Enable)+numel(pH.Trigger)+...
                numel(pH.Ifaction)+numel(pH.Reset);
                numOutportsFrompH=numel(pH.Outport);
                areInportsConsistent=numel(iNames)==numInportsFrompH;
                areOutportsConsistent=numel(oNames)==numOutportsFrompH;
                if~areInportsConsistent||~areOutportsConsistent
                    DAStudio.error('Simulink:Variants:C2VInconsistentInterface',get_param(blockH,'Name'));
                end
            end


















            Simulink.internal.vmgr.VMUtils.DeleteConnectedLines(blockH);


            loc_requirementDebug(blockH,...
            'Requirements link not found before subsystem conversion',...
            'Requirements link found before subsystem conversion');



            try
                isCPOn=get_param(blockH,'ContentPreviewEnabled');
                Simulink.BlockDiagram.createSubSystem(blockH);
            catch exception
                throwAsCaller(exception);
            end


            loc_requirementDebug(blockH,...
            'Requirements link not found after subsystem conversion',...
            'Requirements link found after subsystem conversion');



            blockName=get_param(blockH,'Name');
            blockDesc=get_param(blockH,'Description');
            blockShowName=get_param(blockH,'ShowName');
            blockFGColor=get_param(blockH,'ForegroundColor');
            blockBGColor=get_param(blockH,'BackgroundColor');
            vssBlk=get_param(blockH,'Parent');
            vssHandle=get_param(vssBlk,'Handle');
            fppPortSchema=loc_cacheFlexiblePortPlacementSchema(blockH);






            set_param(vssHandle,'Name',blockName);


            vssBlk=getfullname(vssHandle);%#ok<NASGU>





            if loc_isSystemArchitecture(vssBlk)
                loc_replaceBEPWithPorts(vssBlk);
            end



            if isSubsys
                choicePortToPortBlkMap=Simulink.internal.vmgr.VMUtils.portToPortBlock(blockH);
            end

            blkConnMapAfter=Simulink.internal.vmgr.VMUtils.GetConnectionMapping(blockH);





            bO=containers.Map();
            if isMdlRef
                bO=Simulink.internal.vmgr.VMUtils.getBusInfo(blockH,miMap);
            end

            iPH=[pH.Inport,pH.Enable,pH.Trigger,...
            pH.Ifaction,pH.Reset];
            for eachPort=1:length(iPH)
                if strcmp(get_param(iPH(eachPort),'IsHidden'),'on')
                    continue
                end
                if isSubsys
                    pBlkName=Simulink.internal.vmgr.VMUtils.getPortBlockName(choicePortToPortBlkMap(iPH(eachPort)));
                else
                    pBlkName=iNames{eachPort};
                end

                iPhCh=iPH(eachPort);
                srcInfo=blkConnMapAfter(iPhCh);
                srcBlk=srcInfo.SrcBlock;

                Simulink.internal.vmgr.VMUtils.renameBlock(srcBlk,pBlkName);
                if bO.isKey(pBlkName)&&~isempty(bO(pBlkName))
                    set_param(srcBlk,'OutDataTypeStr',['Bus: ',bO(pBlkName)])
                end
            end





            oPH=[pH.Outport,pH.State,pH.LConn,pH.RConn];
            for eachPort=1:length(oPH)
                if isSubsys
                    pBlkName=Simulink.internal.vmgr.VMUtils.getPortBlockName(choicePortToPortBlkMap(oPH(eachPort)));
                else
                    pBlkName=oNames{eachPort};
                end


                Simulink.variant.utils.assert(length(blkConnMapAfter(oPH(eachPort)).DstBlock)==1);
                dstBlk=blkConnMapAfter(oPH(eachPort)).DstBlock(1);

                Simulink.internal.vmgr.VMUtils.renameBlock(dstBlk,pBlkName);
                if bO.isKey(pBlkName)&&~isempty(bO(pBlkName))
                    set_param(dstBlk,'OutDataTypeStr',['Bus: ',bO(pBlkName)]);
                end
            end



            Simulink.internal.vmgr.VMUtils.DeleteConnectedLines(blockH);










            loc_replaceInportsToControlPorts(blockH,vssBlk,cNamesAndTypes,blkConnMapAfter,isVarMdlRef);



            slInternal('SetVariantSubsystemAndUpdateProp',vssHandle,blockH);



            if resolveLinkStatus


                if isSubsys
                    set_param(blockH,'LinkStatus','restore');
                elseif(isMdlRef&&~isVarMdlRef)


                    set_param(blockH,'LinkStatus','restore');
                elseif(isVarMdlRef)


                    set_param(vssHandle,'LinkStatus','restore');
                end
            end




            loc_connectAllViewers(vssHandle,disViewers,disAxes);





            set_param(vssHandle,'Commented',isCommented);


            set_param(vssHandle,'AttributesFormatString',attribStr);


            set_param(vssHandle,'Name',blockName);


            set_param(vssHandle,'Description',blockDesc);
            set_param(vssHandle,'ShowName',blockShowName);
            set_param(vssHandle,'ForegroundColor',blockFGColor);
            set_param(vssHandle,'BackgroundColor',blockBGColor);
            set_param(vssHandle,'PortSchema',fppPortSchema);

            vssBlk=get_param(blockH,'Parent');


            Simulink.internal.vmgr.VMUtils.ReDrawLines(vssHandle,blockH,blkConnMapBefore,blkConnMapAfter);







            if isVarMdlRef


                gpcState=get_param(blockH,'GeneratePreprocessorConditionals');
                overrideState=get_param(blockH,'OverrideUsingVariant');
                pH=get_param(blockH,'PortHandles');






                callbacks={'ClipboardFcn','CloseFcn','ContinueFcn','CopyFcn','DeleteFcn',...
                'DestroyFcn','InitFcn','LoadFcn','ModelCloseFcn','MoveFcn','NameChangeFcn',...
                'OpenFcn','ParentcloseFcn','PauseFcn','PostSaveFcn','PreCopyFcn','PreDeleteFcn'...
                ,'PreSaveFcn','StartFcn','StopFcn','UndoDeleteFcn'};
                cellfun(@(x)set_param(vssBlk,x,get_param(blockH,x)),callbacks);
                Simulink.internal.vmgr.VMUtils.createMdlBlocksForMdlrefVariants(blockH,vssBlk,signalMappings);

                try

                    set_param(vssBlk,'GeneratePreprocessorConditionals',gpcState);
                catch ME
                    warning(ME.message);
                end
                try
                    set_param(vssBlk,'OverrideUsingVariant',overrideState);
                catch ME
                    warning(ME.message);
                end



                Simulink.internal.vmgr.VMUtils.makeVSSInterfaceConsistentForChoiceBlocks(vssBlk,pH,miMap);

                if~isempty(get_param(bdroot(vssBlk),'ModelBlockNormalModeVisibility'))




                    activeBlk=get_param(vssBlk,'ActiveVariantBlock');
                    if~isempty(activeBlk)






                        if strcmp(get_param(activeBlk,'BlockType'),'ModelReference')&&strcmp(get_param(activeBlk,'SimulationMode'),'Normal')
                            activeBlkCell={activeBlk};
                            set_param(bdroot(vssBlk),'ModelBlockNormalModeVisibility',{activeBlkCell});
                        elseif strcmp(get_param(activeBlk,'BlockType'),'SubSystem')
                            modelBlk=find_system(activeBlk,'SearchDepth',1,'FindAll','On','FollowLinks','On','LookUnderMasks','All','BlockType','ModelReference');
                            if strcmp(get_param(getfullname(modelBlk),'SimulationMode'),'Normal')
                                set_param(bdroot(vssBlk),'ModelBlockNormalModeVisibility',{modelBlk});
                            end
                        end
                    end
                end
            end


            set_param(vssHandle,'Selected',cacheSelection);


            set_param(vssHandle,'ContentPreviewEnabled',isCPOn);


            slreq.utils.onHierarchyChange('postChange',vssHandle);
        else


            DAStudio.error('Simulink:utility:invalidHandle');
        end
    catch exception
        throwAsCaller(exception);
    end
end





















function portSchema=loc_cacheFlexiblePortPlacementSchema(srcBlk)

    portSchema='';

    parent=get_param(srcBlk,'Parent');
    subdomain=get_param(parent,'SimulinkSubDomain');
    if strcmp(subdomain,'Simulink')
        blkType=get_param(srcBlk,'BlockType');
        if strcmp(blkType,'SubSystem')
            isSubsystemReferece=~isempty(get_param(srcBlk,'ReferencedSubsystem'));
            if~isSubsystemReferece
                portSchema=get_param(srcBlk,'PortSchema');
            end
        end
    else
        portSchema=get_param(srcBlk,'PortSchema');
    end
end


function[disViewers,disAxes]=loc_disconnectAllViewers(blkH)
    phs=get_param(blkH,'PortHandles');
    ph=phs.Outport;
    nOutports=numel(ph);
    disViewers=cell(1,nOutports);
    disAxes=cell(1,nOutports);
    for i=1:nOutports
        [disViewers{i},disAxes{i}]=loc_disconnectViewers(ph(i));
    end
end


function loc_connectAllViewers(blkH,disViewers,disAxes)
    phs=get_param(blkH,'PortHandles');
    ph=phs.Outport;
    nCachedOutports=numel(disViewers);
    for i=1:nCachedOutports
        loc_reconnectViewers(ph(i),disViewers{i},disAxes{i});
    end
end





function[disViewers,disAxes]=loc_disconnectViewers(outport)
    try
        [disViewers,disAxes]=Simulink.ModelReference.Conversion.Utilities.disconnectViewers(outport);
    catch e
        disViewers=[];
        disAxes=[];
        warning(e.message);
    end
end




function loc_reconnectViewers(outport,viewers,vAxes)
    try
        Simulink.ModelReference.Conversion.Utilities.connectViewers(outport,viewers,vAxes);
    catch e
        warning(e.message);
    end
end














function loc_replaceInportsToControlPorts(blockH,vssBlk,cNamesAndTypes,blkConnectionMap,isMdlRef)
    if slfeature('ControlPortInsideVSS')>0&&~isMdlRef
        if~isempty(cNamesAndTypes.Names)

            deletPortBlkmap=containers.Map('KeyType','double','ValueType','double');
            for cIndex=1:length(cNamesAndTypes.Names)
                iPortHandle=get_param([vssBlk,'/',cNamesAndTypes.Names{cIndex}],'handle');
                cbPath=[vssBlk,'/',cNamesAndTypes.Names{cIndex}];
                newloc=loc_getCtrlPortLoc(cbPath,get_param(blockH,'Orientation'));
                delete_block(cbPath);
                ctrlPortBlH=add_block(['built-in/',cNamesAndTypes.Types{cIndex},'Port'],cbPath);
                set_param(ctrlPortBlH,'position',newloc);
                if~isempty(cNamesAndTypes.Subtypes{cIndex})
                    set_param(ctrlPortBlH,'TriggerType',cNamesAndTypes.Subtypes{cIndex});
                end
                deletPortBlkmap(iPortHandle)=ctrlPortBlH;
            end
            pH=get_param(blockH,'PortHandles');
            iPH=[pH.Enable,pH.Trigger,pH.Reset];
            for iNext=1:length(iPH)
                if deletPortBlkmap.isKey(blkConnectionMap(iPH(iNext)).SrcBlock)
                    srcBlkDet=blkConnectionMap(iPH(iNext));
                    srcBlkDet.SrcBlock=deletPortBlkmap(srcBlkDet.SrcBlock);
                    blkConnectionMap(iPH(iNext))=srcBlkDet;
                end
            end
        end
    end
end








function newpos=loc_getCtrlPortLoc(bpath,ori)

    pos=get_param(bpath,'Position');

    adjVec=[0,0,0,0];
    magicPixCnt=30;
    if strcmp(ori,'right')
        adjVec=[magicPixCnt,-magicPixCnt,magicPixCnt,-magicPixCnt];
    elseif strcmp(ori,'left')
        adjVec=[magicPixCnt,magicPixCnt,magicPixCnt,magicPixCnt];
    end







    mx=pos(3)-pos(1);
    midx=(pos(1)+pos(3))/2;
    my=pos(4)-pos(2);
    midy=(pos(4)+pos(2))/2;
    sl=(mx+my)/4;
    newpos=[midx,midy,midx,midy];
    newpos=newpos+[-sl,-sl,sl,sl]+adjVec;
end




function isArch=loc_isSystemArchitecture(blockH)
    isArch=strcmpi(get_param(blockH,'SimulinkSubDomain'),'architecture')||...
    strcmpi(get_param(blockH,'SimulinkSubDomain'),'softwarearchitecture');
end



function loc_replaceBEPWithPorts(vssBlk)
    inports=find_system(vssBlk,'SearchDepth',1,'BlockType','Inport','IsBusElementPort','on');
    outports=find_system(vssBlk,'SearchDepth',1,'BlockType','Outport','IsBusElementPort','on');

    cellfun(@(blk)loc_replaceOneBEP(blk,true),inports);
    cellfun(@(blk)loc_replaceOneBEP(blk,false),outports);
end















function loc_replaceOneBEP(blk,isInputPort)


    lh=struct2array(get_param(blk,'LineHandles'));
    assert(isscalar(lh))
    assert(lh~=-1);

    if isInputPort
        portOnSS=get_param(lh,'DstPortHandle');
    else
        portOnSS=get_param(lh,'SrcPortHandle');
    end
    assert(isscalar(portOnSS))
    assert(portOnSS~=-1);


    parentSS=get_param(blk,'Parent');
    replace_block(parentSS,...
    'BlockType',get_param(blk,'BlockType'),...
    'Name',get_param(blk,'Name'),...
    'Parent',parentSS,...
    get_param(blk,'BlockType'),...
    'noprompt')


    portOnPortBlock=struct2array(get_param(blk,'PortHandles'));
    assert(isscalar(portOnPortBlock))
    delete_line(lh);
    if isInputPort
        add_line(parentSS,portOnPortBlock,portOnSS);
    else
        add_line(parentSS,portOnSS,portOnPortBlock);
    end

end









function loc_requirementDebug(blockH,fmsg,pmsg)
    if slsvTestingHook('ConvertToVSSDebug')==1
        reqLinks=rmi('get',blockH);
        if isempty(reqLinks)
            disp(fmsg);
        else
            disp(pmsg);
        end
    end
end





