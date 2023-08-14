function exportSlice(obj,deadBlocks,allH,inactiveV,groups,sliceMdl,newPath)






    import Analysis.*;
    import Transform.*;

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    if~isempty(obj.dlg)
        modelslicerprivate('MessageHandler','open',obj.model);
    end

    deadBlocks=unique(deadBlocks);


    [checkPortAttributes,fixPortAttributes]=obj.determineCheckAndFixPortAttributes;

    obj.updateWaitBarTotalProgress(checkPortAttributes,fixPortAttributes);

    [hdls,deadBlocksMapped,toRemove,activeH,allNonVirtH,synthDeadBlockH]=obj.utilGetAllHandles(deadBlocks);



    post=obj.postAnalyze(activeH,inactiveV,allH);

    obj.updateWaitBar('Sldv:ModelSlicer:ModelSlicer:MakingCopyOfModel');


    sliceFileName=obj.getSliceFileName(sliceMdl,newPath);


    [origSys,sliceRootSys,deadBlocks,toRemove,allNonVirtH]=obj.createModelFileForSlice(sliceMdl,sliceFileName,toRemove,allNonVirtH,deadBlocksMapped,deadBlocks);


    sliceMdlH=obj.setConfigForSlice(sliceMdl,newPath);
    ModelSlicer.addModelCloseCallback(sliceMdlH);

    SlicerConfiguration.refreshConfiguration(sliceMdl);



    inlineSIDLibFirst=get_param(sliceMdl,'SIDHighWatermark');
    if obj.options.InlineOptions.Libraries
        updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:BreakingLibraryLinks');
        breakLibraryLinks(sliceMdl);
    end


    deadBlocks=obj.filterAtomicBlks(sliceMdl,groups,deadBlocks,post);

    if~obj.options.InlineOptions.ModelBlocks
        deadBlocks(bdroot(deadBlocks)~=obj.modelH)=[];
    end

    if~obj.isSubsystemSlice
        sliceXfrmr=Transform.SliceTransformer(obj.model);
    else
        sliceXfrmr=Transform.SliceTransformer(get_param(bdroot(obj.sliceSubSystemH),'Name'));
    end
    sliceXfrmr.setSliceName(sliceMdl);
    sliceXfrmr.setModelSlicerObj(obj);

    updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:CopyingContentsOfModelReferences');

    inlineSIDMdlRefFirst=get_param(sliceMdl,'SIDHighWatermark');

    sliceXfrmr.mappingOn();


    replaceModelBlockH=obj.getModelBlksToInline;

    replaceModelBlockH=setdiff(replaceModelBlockH,toRemove);
    hasMdlRef=~isempty(replaceModelBlockH);


    obj.applyInlineTransforms(hasMdlRef,sliceXfrmr,replaceModelBlockH,sliceMdl,hdls,origSys,sliceRootSys);



    sliceMdlH=get_param(sliceMdl,'Handle');

    inlineSIDlast=get_param(sliceMdl,'SIDHighWatermark');

    obj.changeReadonlySystemWritable(sliceMdl);


    preSliceSubsysPorts=obj.getSubsysCache(sliceMdl);



    sliceXfrmr.mappingOn();
    sliceXfrmr.sliceMapper.setInlinedSIDRange(...
    str2double(inlineSIDLibFirst),...
    str2double(inlineSIDMdlRefFirst),...
    str2double(inlineSIDlast));
    if obj.isSubsystemSlice
        sliceXfrmr.sliceMapper.setSliceSubsystem(obj.sliceSubSystemH,sliceRootSys);
    end


    transformedSys=Transform.transformDisableSystemOutput(sliceXfrmr,...
    origSys,sliceRootSys,deadBlocks,obj.SimState);

    handles=setdiff(toRemove,transformedSys);


    modifiedSystems=obj.removeUnusedBlksAndPerformTransforms(groups,handles,origSys,sliceRootSys,post,sliceMdl,sliceXfrmr);
    sldvPassthroughDeadBlocks=removeUnreachableGroups(sliceXfrmr,sliceRootSys,origSys,allH,groups);
    obj.utilRemoveBlocks(sliceXfrmr,sliceRootSys,origSys,groups,sldvPassthroughDeadBlocks,synthDeadBlockH);

    modifiedSystems(modifiedSystems==sliceMdlH)=[];

    obj.utilExpandTrivialSubsystems(allNonVirtH,origSys,sliceRootSys,modifiedSystems,sliceXfrmr);




    sliceXfrmr.mappingOff();
    Transform.fixAllDisconnectedPorts(sliceXfrmr,sliceMdl);


    obj.postProcessSubsysPorts(sliceXfrmr,sliceMdl,preSliceSubsysPorts);

    obj.updateWaitBar('Sldv:ModelSlicer:ModelSlicer:OpeningSliceModel');

    open_system(sliceMdl);
    sliceXfrmr.mappingOff();


    ModelSlicer.addParamsForSliceMapping(sliceMdl,origSys);


    configureSliceMdlSampleTime(obj,origSys,sliceMdl);

    if~strcmpi(get_param(sliceMdl,'SimulationMode'),'Normal')
        set_param(sliceMdl,'SimulationMode','Normal');
    end

    if~isempty(obj.cvd)
        [~,stopTime]=obj.cvd.getStartStopTime;
        set_param(sliceMdl,'StopTime',num2str(stopTime));
    else
        set_param(sliceMdl,'StopTime',get_param(obj.modelH,'StopTime'));
    end

    obj.setSliceMapperForModelHierarchy(origSys,sliceMdl,sliceXfrmr)


    modelslicerprivate('MessageHandler','close')


    if~isempty(obj.dlg)
        UImode=true;

        modelslicerprivate('MessageHandler','open',sliceMdl);
    else
        UImode=false;
    end



    allSliceMdls=find_mdlrefs(sliceMdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
    sliceHasMdlRef=numel(allSliceMdls)>1;

    expandLib=obj.options.InlineOptions.Libraries;
    hasGlobal=obj.checkHasGlobal;

    if sliceHasMdlRef




        origAttrMap=cachePortAttributeInOrig(sliceMdlH,sliceXfrmr);
    else



        origAttrMap=[];
    end

    obj.handlePortAttributes(checkPortAttributes,fixPortAttributes,sliceMdl,UImode,expandLib,hasGlobal,sliceXfrmr,origAttrMap);

    if~isempty(transformedSys)...
        &&strcmp(get_param(obj.modelH,'UnderspecifiedInitializationDetection'),'Classic')

        obj.issueInitValueWarning(sliceMdl,sliceXfrmr,transformedSys);
    end


    modelslicerprivate('MessageHandler','close')


    if~isempty(obj.mdlStructureInfo)
        obj.mdlStructureInfo.clearAfterSliceGeneration;
    end
end
