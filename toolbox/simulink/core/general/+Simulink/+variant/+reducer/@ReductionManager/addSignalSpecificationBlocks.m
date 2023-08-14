function addSignalSpecificationBlocks(obj)









    try
        topModelName=obj.getOptions().TopModelName;

        hVarRedConfig=Simulink.variant.reducer.CompileManager.getInstance();


        toBeProcessedModelInfoStruct=obj.ProcessedModelInfoStructsVec(1);
        configInfoStructsVec=toBeProcessedModelInfoStruct.ConfigInfos;
        numConfigInfos=numel(configInfoStructsVec);
        compiledPortAttributesMap=containers.Map;

        for configInfoIdx=1:numConfigInfos
            currConfig=configInfoStructsVec(configInfoIdx).Configuration;
            hVarRedConfig.clean();
            hVarRedConfig.setTopModel(topModelName);


            hVarRedConfig.setValidateSignalsFlag(true);

            if~isempty(currConfig)
                currConfigName=currConfig.Name;




                Simulink.VariantConfigurationData.validateModel(topModelName,currConfigName);
            end




            hplgmngr=Simulink.PluginMgr;
            mdlHandle=get_param(topModelName,'Handle');
            hplgmngr.attach(mdlHandle,'VARIANTREDUCER');
            hVarRedConfig.callValidationCompile(obj.getOptions().isCodegenCompileMode());
            hplgmngr.detachForAllModels('VARIANTREDUCER');





            compiledPortAttributesMapTmp=hVarRedConfig.getCompiledPortAttributeMap();
            blks=compiledPortAttributesMapTmp.keys;
            for blkId=1:numel(blks)
                if~isKey(compiledPortAttributesMap,blks{blkId})
                    compiledPortAttributesMap(blks{blkId})=compiledPortAttributesMapTmp(blks{blkId});
                end
            end


            hVarRedConfig.clean();
        end



        if isempty(compiledPortAttributesMap)
            addSignalSpec=false;
        else



            comparePortAttributes(obj,compiledPortAttributesMap);



            addSignalSpec=obj.PortsToAddSigSpec.Count~=0;
        end
    catch ex
        Simulink.variant.reducer.utils.logException(ex);



        addSignalSpec=true;
    end


    hVarRedConfig.clean();


    if addSignalSpec

        i_addSignalSpecificationBlocks(obj);
    end

end






function comparePortAttributes(obj,mapRed)


    blks=obj.PortsToAddSigSpec.keys;


    if isempty(blks)
        return;
    end



    mapOrig=obj.CompiledPortAttributesMap;




    mapReducedModelNamesToOrignalModelNames=...
    i_invertMap(obj.BDNameRedBDNameMap);

    for blkId=1:numel(blks)




        if~isKey(mapRed,blks{blkId})
            continue;
        end



        if~isKey(mapOrig,blks{blkId})
            [mdlRefNameinRedModel,blkRemPath]=strtok(blks{blkId},'/');
            mdlRefNameinOrigModel=mapReducedModelNamesToOrignalModelNames(mdlRefNameinRedModel);
            keyOrig=[mdlRefNameinOrigModel,blkRemPath];
        else
            keyOrig=blks{blkId};
        end



        if~isKey(mapOrig,keyOrig)

            continue;
        end

        portAttributesOrig=mapOrig(keyOrig);
        portAttributesRed=mapRed(blks{blkId});

        blkType=get_param(blks{blkId},'BlockType');



        isSubsystem=strcmp(blkType,'SubSystem');
        isNonProtectedModel=strcmp(blkType,'ModelReference')&&strcmp(get_param(blks{blkId},'ProtectedModel'),'off');
        isSubsystemResolved=isSubsystem&&strcmp(get_param(blks{blkId},'StaticLinkStatus'),'resolved');
        isSubsystemReference=isSubsystem&&~isempty(get_param(blks{blkId},'ReferencedSubsystem'));


        for portId=1:numel(portAttributesRed)
            portHandle=portAttributesRed(portId).Handle;



            if(isSubsystem&&isSubsystemResolved)||isNonProtectedModel||isSubsystemReference
                portBlkName=portAttributesRed(portId).PortBlockName;
                idx=Simulink.variant.reducer.utils.searchNameInCell(portBlkName,{portAttributesOrig.PortBlockName});
                Simulink.variant.reducer.utils.assert(~isempty(idx));
                origPortHandle=portAttributesOrig(idx).Handle;
            else
                origPortHandle=portHandle;
            end

            origPortAttribute=portAttributesOrig(origPortHandle==[portAttributesOrig(:).Handle]);


            Simulink.variant.reducer.utils.assert(~isempty(origPortAttribute),'Port handle not found');


            fieldsToRemove={'Handle';...
            'PortNumber';...
            'PortType';...
            'CompiledBusStruct';...
            'CompiledSignalHierarchy'};
            origPortAttribute=rmfield(origPortAttribute,fieldsToRemove);
            redPortAttribute=portAttributesRed(portId);
            redPortAttribute=rmfield(redPortAttribute,fieldsToRemove);







            origPortAttribute.CompiledPortSampleTime=...
            Simulink.variant.reducer.utils.getSampleTimeStr(origPortAttribute.CompiledPortSampleTime);
            redPortAttribute.CompiledPortSampleTime=...
            Simulink.variant.reducer.utils.getSampleTimeStr(redPortAttribute.CompiledPortSampleTime);
















            isPortAttributeSame=isequal(origPortAttribute,redPortAttribute);


            oldVal=obj.PortsToAddSigSpec(blks{blkId});
            srcPortHandles=[oldVal(:).SrcPortHandle];


            dstPortHandles={oldVal(:).DstPortHandle};
            if isPortAttributeSame
                idx=srcPortHandles==portHandle;

                newVal=oldVal(~idx);



                if~any(idx)
                    idx=i_searchHandleInCell(dstPortHandles,portHandle);
                    newVal1=newVal(~idx);
                else
                    newVal1=newVal;
                end
                obj.PortsToAddSigSpec(blks{blkId})=newVal1;
            end
        end

        if isempty(obj.PortsToAddSigSpec(blks{blkId}))
            remove(obj.PortsToAddSigSpec,blks{blkId});
        end
    end
end


function i_addSignalSpecificationBlocks(obj)
    portStructValues=obj.PortsToAddSigSpec.values;
    for blkId=1:numel(portStructValues)

        portStructs=portStructValues{blkId};



        for structId=1:numel(portStructs)
            srcPort=portStructs(structId).SrcPortHandle;
            dstPorts=portStructs(structId).DstPortHandle;


            if isempty(srcPort)||isempty(dstPorts)
                continue;
            end



            if srcPort==-1&&all(dstPorts==-1)
                continue;
            end


            if srcPort==-1
                lineH=get(dstPorts(1),'Line');

                Simulink.variant.reducer.utils.assert(lineH~=-1);
                srcPort=get(lineH,'SrcPortHandle');
            end



            if srcPort==0
                continue;
            end

            try

                srcPortObj=get(srcPort,'Object');%#ok<NASGU> 
            catch ex %#ok<NASGU>




                continue;
            end



            if all(dstPorts==-1)
                lineH=get(srcPort,'Line');

                Simulink.variant.reducer.utils.assert(lineH~=-1);
                dstPorts=get(lineH,'DstPortHandle');
            end



            if all(dstPorts==0)
                srcBlkPath=get(srcPort,'Parent');
                blkToAdd=Simulink.variant.reducer.types.VRedBlockToAdd;
                blkToAdd.System=get_param(srcBlkPath,'Parent');
                blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.TERMINATOR;
                blkToAdd.BlkPath=[srcBlkPath,'_Term'];
                blkToAdd.SrcPort=srcPort;
                blkToAdd.DstPort=-1;

                blkUniqH=i_addBlock(obj,blkToAdd);
                blkterminatorPortH=get(blkUniqH,'PortHandles');
                dstPorts=blkterminatorPortH.Inport;
            end








            dstPorts=dstPorts(ishandle(dstPorts));



            if isempty(dstPorts)
                continue;
            end



            srcBlock=get(srcPort,'Parent');
            if strcmp(get_param(srcBlock,'BlockType'),'SignalSpecification')
                continue;
            end





            if isempty(portStructs(structId).PortAttributes)
                continue;
            end

            blkH=i_insertSigSpecBlk(obj,srcPort,dstPorts);
            i_addAttrToSigSpecBlk(blkH,portStructs(structId).PortAttributes);
        end
    end
end



function idx=i_searchHandleInCell(cellarray,handle)
    idx=false(1,numel(cellarray));
    for cellId=1:numel(cellarray)
        numArray=cellarray{cellId};
        if any(numArray==handle)
            idx(cellId)=true;
        end
    end
end


function blkH=i_insertSigSpecBlk(obj,srcPortH,dstPortH)

    lineH=get(srcPortH,'Line');


    Simulink.variant.reducer.utils.assert(lineH~=-1);
    srcBlock=get(srcPortH,'Parent');

    blkToAdd=Simulink.variant.reducer.types.VRedBlockToAdd;
    blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION;
    blkToAdd.BlkPath=[srcBlock,'_SS'];
    blkToAdd.SrcPort=srcPortH;
    blkToAdd.DstPort=dstPortH;
    blkToAdd.System=get_param(srcBlock,'Parent');

    blkH=i_addBlock(obj,blkToAdd);
    blkMask=Simulink.Mask.create(blkH);
    blkMask.Display='disp([''s''])';

    blkPortH=get(blkH,'PortHandles');

    blkGraph=get_param(blkH,'Parent');


    try
        arrayfun(@(x)delete_line(blkGraph,srcPortH,x),dstPortH(:));
    catch ex %#ok<NASGU>
    end


    try
        add_line(blkGraph,srcPortH,blkPortH.Inport,'autorouting','on');
    catch ex %#ok<NASGU>
    end


    try
        arrayfun(@(x)add_line(blkGraph,blkPortH.Outport,x,'autorouting','on'),dstPortH(:));
    catch ex %#ok<NASGU>
    end
end


function i_addAttrToSigSpecBlk(blkH,attrStruct)

    if blkH==-1
        return;
    end

    modAttrStruct=Simulink.variant.reducer.utils.getSettableSignalAttributes(attrStruct);

    objParams=get_param(blkH,'ObjectParameters');
    redBlk=getfullname(blkH);

    fieldsToSet=fieldnames(modAttrStruct);

    for ii=1:numel(fieldsToSet)
        if~isfield(objParams,fieldsToSet{ii})
            continue;
        end

        try
            i_set_param(redBlk,fieldsToSet{ii},modAttrStruct.(fieldsToSet{ii}));
        catch ex %#ok<NASGU>
        end
    end
end

function i_set_param(blk,attr,val)
    if~isempty(val)
        set_param(blk,attr,val);
    end
end


