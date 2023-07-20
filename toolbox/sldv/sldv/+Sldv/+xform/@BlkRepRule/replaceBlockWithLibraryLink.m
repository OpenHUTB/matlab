function replaceBlockWithLibraryLink(obj,blockInfo)




    Block=getfullname(blockInfo.ReplacementInfo.BlockToReplaceH);
    islibraryblk=strcmp(get_param(bdroot(Block),'BlockDiagramType'),'library');

    parentSubsysType=Simulink.SubsystemType(get_param(Block,'Parent'));
    isVariantChoice=parentSubsysType.isVariantSubsystem;
    blkReplacer=Sldv.xform.BlkReplacer.getInstance();


    Sldv.xform.BlkRepRule.checkLinkStatus(Block,...
    blockInfo);

    paramsOriginalBlk=deriveOrigDialogParamsValues(Block);
    origBlkAttributesFormatString=get_param(Block,'AttributesFormatString');
    if~islibraryblk
        if~isVariantChoice
            origLineHs=populateOrigLineHs(Block);
        end
        origOutAttribs=getOutportAttributes(Block);
    end

    relativeBlockPath=obj.ReplacementBlk;
    ReplacemenBlkFullPath=[obj.ReplacementLib,relativeBlockPath(2:end)];

    orient=get_param(Block,'orientation');
    blockPos=get_param(Block,'position');
    if any(blockPos>=32767)

        blockPos(blockPos>=32767)=32750;
    end
    blockName=get_param(Block,'Name');
    newBlock=blkReplacer.addBlock(ReplacemenBlkFullPath,Block,...
    'MakeNameUnique','on',...
    'Orientation',orient...
    );
    set_param(newBlock,'LinkStatus','none');






    if isa(blockInfo,'Sldv.xform.RepMdlRefBlkTreeNode')


        mask=Simulink.Mask.get(Block);
        if~isempty(mask)
            newMask=Simulink.Mask.create(newBlock);
            newMask.copy(mask);


        end


        handleInstanceSpecificParams(blockInfo);
    end

    blkReplacer.deleteBlock(Block);
    set_param(newBlock,'Name',blockName);

    blockInfo.ReplacementInfo.AfterReplacementH=get_param(Block,'Handle');

    if~islibraryblk
        if~isVariantChoice
            fixDisconnectedLineHs(blockInfo.ReplacementInfo.AfterReplacementH,origLineHs);
        end
        fixOutportAttributes(blockInfo.ReplacementInfo.AfterReplacementH,origOutAttribs);
    end



    set_param(newBlock,'Position',blockPos);
    set_param(blockInfo.ReplacementInfo.AfterReplacementH,...
    'AttributesFormatString',origBlkAttributesFormatString);

    if strcmp(get_param(blockInfo.ReplacementInfo.AfterReplacementH,'BlockType'),'SubSystem')

        tmpIntrinsicParamProps=[];
        tmpIntrinsicParamProps.Prompt='';
        tmpIntrinsicParamProps.Type='string';
        tmpIntrinsicParamProps.Attributes={};

        additionalMaskParamsForMdlRef=[];
        parametersToCarry={};
        if isa(blockInfo,'Sldv.xform.RepMdlRefBlkTreeNode')&&...
            ~isempty(blockInfo.BaseOrModelWSCarrSSMaskVars)
            parameterMap=blockInfo.ReplacementInfo.ParameterMapReplacement;
            varsToCarryStruct=blockInfo.BaseOrModelWSCarrSSMaskVars;
            parametersToCarry=fieldnames(varsToCarryStruct);
            additionalMaskParamsForMdlRef=Simulink.MaskParameter.createStandalone(length(parametersToCarry));
            for idx=1:length(parametersToCarry)
                parameterMap.(parametersToCarry{idx})=varsToCarryStruct.(parametersToCarry{idx});
                localIntrinsicParamProps=tmpIntrinsicParamProps;
                localIntrinsicParamProps.Prompt=parametersToCarry{idx};
                Sldv.xform.maskUtils.constructMaskParam(additionalMaskParamsForMdlRef(idx),parametersToCarry{idx},...
                localIntrinsicParamProps);
            end
            blockInfo.ReplacementInfo.ParameterMapReplacement=parameterMap;
        end

        extraMaskParams=[];
        if~isempty(blockInfo.ReplacementInfo.ParameterMapReplacement)
            replacementParamNames=Sldv.xform.maskUtils.getAllParamNames(blockInfo.ReplacementInfo.AfterReplacementH);
            toMapParamNames=fieldnames(blockInfo.ReplacementInfo.ParameterMapReplacement);
            toMapParamNames=setdiff(toMapParamNames,parametersToCarry);
            if isa(blockInfo,'Sldv.xform.RepMdlRefBlkTreeNode')
                blockInfo.ExtraMaskParameters=toMapParamNames;
            end
            if obj.CopyOrigDialogParams&&~isempty(paramsOriginalBlk)
                extraParam=setdiff(toMapParamNames,union(replacementParamNames,{paramsOriginalBlk.Name}));
            else
                extraParam=setdiff(toMapParamNames,replacementParamNames);
            end

            extraParam=filterAlreadyExisting(extraParam,blockInfo.ReplacementInfo.AfterReplacementH);
            if~isempty(extraParam)
                extraMaskParams=Simulink.MaskParameter.createStandalone(length(extraParam));
                for idx=1:length(extraParam)
                    localIntrinsicParamProps=tmpIntrinsicParamProps;
                    localIntrinsicParamProps.Prompt=extraParam{idx};
                    localIntrinsicParamProps.Attributes={'dont-eval','read-only-if-compiled'};
                    Sldv.xform.maskUtils.constructMaskParam(extraMaskParams(idx),extraParam{idx},...
                    localIntrinsicParamProps);
                end
            end

        end
        if~strcmp(obj.BlockType,'ModelReference')
            if obj.CopyOrigDialogParams
                Sldv.xform.maskUtils.copyDialogParams(...
                blockInfo.ReplacementInfo.AfterReplacementH,...
                [paramsOriginalBlk,extraMaskParams]);
            else
                Sldv.xform.maskUtils.copyDialogParams(...
                blockInfo.ReplacementInfo.AfterReplacementH,...
                extraMaskParams);
            end
        else
            if(blockInfo.ReplacementInfo.IsMaskConstructedMdlBlk||...
                blockInfo.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
                blockInfo.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk)
                subsysForCopyingInstanceParams=...
                Sldv.xform.getChildSubSystem(blockInfo.ReplacementInfo.AfterReplacementH);
            else
                subsysForCopyingInstanceParams=blockInfo.ReplacementInfo.AfterReplacementH;
            end
            Sldv.xform.maskUtils.copyDialogParams(...
            subsysForCopyingInstanceParams,additionalMaskParamsForMdlRef);
            Sldv.xform.maskUtils.copyDialogParams(...
            blockInfo.ReplacementInfo.AfterReplacementH,extraMaskParams);
        end

        if~strcmp(obj.BlockType,'ModelReference')
            blockInfo.ReplacementInfo.TableSubsystemsInserted(blockInfo.ReplacementInfo.AfterReplacementH)=true;
        end
    end

end

function origLineHs=populateOrigLineHs(Block)
    blockH=get_param(Block,'Handle');
    ports=get_param(blockH,'PortHandles');
    origLineHs.Inlines=getLines(ports.Inport);
    origLineHs.Enables=getLines(ports.Enable);
    origLineHs.Triggers=getLines(ports.Trigger);
    origLineHs.Outlines=getLines(ports.Outport);
end

function fixDisconnectedLineHs(blockH,origLineHs)
    parentH=get_param(blockH,'Parent');
    ports=get_param(blockH,'PortHandles');
    inports=ports.Inport;
    enables=ports.Enable;
    triggers=ports.Trigger;
    outports=ports.Outport;
    linesToDelete=[];
    fixInportsWithoutLineConstruction=true;
    blkReplacer=Sldv.xform.BlkReplacer.getInstance();

    if~isempty(origLineHs.Enables)||~isempty(origLineHs.Triggers)
        if~isempty(enables)||~isempty(triggers)
            if~isempty(origLineHs.Enables)&&get_param(origLineHs.Enables{1},'DstPortHandle')==-1
                linesToDelete=constructLine(parentH,...
                origLineHs.Enables{1},enables(1),linesToDelete);
            end
            if~isempty(origLineHs.Triggers)&&get_param(origLineHs.Triggers{1},'DstPortHandle')==-1
                linesToDelete=constructLine(parentH,...
                origLineHs.Triggers{1},triggers(1),linesToDelete);
            end
        else
            fixInportsWithoutLineConstruction=false;
            idx_offset=1;
            if~isempty(origLineHs.Triggers)&&~isempty(origLineHs.Enables)
                idx_offset=idx_offset+1;
            end
            origSrcPortHandles=cell(1,length(origLineHs.Inlines));
            for idx=1:length(origLineHs.Inlines)
                origSrcPortHandles{idx}=...
                get_param(origLineHs.Inlines{idx},'SrcPortHandle');
                blkReplacer.deleteLine(origLineHs.Inlines{idx});
            end
            for idx=1:length(origLineHs.Inlines)
                blkReplacer.addLine(parentH,origSrcPortHandles{idx},inports(idx+idx_offset),'autorouting','on');
            end
            if~isempty(origLineHs.Enables)
                linesToDelete=constructLine(parentH,...
                origLineHs.Enables{1},inports(1),linesToDelete);
            end
            if~isempty(origLineHs.Triggers)
                linesToDelete=constructLine(parentH,...
                origLineHs.Triggers{1},inports(idx_offset),linesToDelete);
            end
        end
    end

    if fixInportsWithoutLineConstruction
        for idx=1:length(origLineHs.Inlines)
            if origLineHs.Inlines{idx}~=-1&&...
                get_param(origLineHs.Inlines{idx},'DstPortHandle')==-1

                linesToDelete=constructLine(parentH,...
                origLineHs.Inlines{idx},inports(idx),linesToDelete);
            end
        end
    end

    for idx=1:length(origLineHs.Outlines)
        if origLineHs.Outlines{idx}~=-1&&...
            get_param(origLineHs.Outlines{idx},'SrcPortHandle')==-1

            linesToDelete=constructLine(parentH,...
            origLineHs.Outlines{idx},outports(idx),linesToDelete,true);
        end
    end

    for idx=1:length(linesToDelete)
        try
            blkReplacer.deleteLine(linesToDelete(idx));
        catch Mex %#ok<NASGU>
        end
    end
end

function paramsOriginalBlk=deriveOrigDialogParamsValues(block)
    paramsOriginalBlk=[];
    if strcmp(get_param(block,'Mask'),'on')
        maskObject=get_param(block,'MaskObject');
        paramsOriginalBlk=Simulink.MaskParameter.createStandalone(length(maskObject.Parameters));
        for idx=1:length(maskObject.Parameters)
            aMaskParameter=paramsOriginalBlk(idx);
            aMaskParameter.set(...
            'Type',maskObject.Parameters(idx).Type,...
            'TypeOptions',maskObject.Parameters(idx).TypeOptions,...
            'Evaluate',maskObject.Parameters(idx).Evaluate,...
            'Tunable',maskObject.Parameters(idx).Tunable,...
            'Name',maskObject.Parameters(idx).Name,...
            'Prompt',maskObject.Parameters(idx).Prompt,...
            'Value',maskObject.Parameters(idx).Value,...
            'Enabled',maskObject.Parameters(idx).Enabled,...
            'Visible',maskObject.Parameters(idx).Visible,...
            'Callback',maskObject.Parameters(idx).Callback,...
            'Alias',maskObject.Parameters(idx).Alias,...
            'TabName',maskObject.Parameters(idx).TabName...
            );
        end
    else
        origBlkIntrinsicParams=get_param(block,'IntrinsicDialogParameters');
        if~isempty(origBlkIntrinsicParams)
            params=fieldnames(origBlkIntrinsicParams);
            paramsOriginalBlk=Simulink.MaskParameter.createStandalone(length(params));
            for idx=1:length(params)
                Sldv.xform.maskUtils.constructMaskParam(paramsOriginalBlk(idx),...
                params{idx},...
                origBlkIntrinsicParams.(params{idx}));
            end
        end
    end
end

function lines=getLines(ports)
    if~isempty(ports)
        lines=get_param(ports,'Line');
        if~iscell(lines)
            lines={lines};
        end
    else
        lines={};
    end
end

function attribs=getOutportAttributes(Block)
    blockH=get_param(Block,'Handle');
    ports=get_param(blockH,'PortHandles');
    if~isempty(ports.Outport)
        mustResolve=get_param(ports.Outport,'MustResolveToSignalObject');
        testPoint=get_param(ports.Outport,'TestPoint');
        if~iscell(mustResolve)
            mustResolve={mustResolve};
        end
        if~iscell(testPoint)
            testPoint={testPoint};
        end
        attribs.MustResolveToSignalObject=mustResolve;
        attribs.testPointPortParameter=testPoint;
    else
        attribs.MustResolveToSignalObject={};
        attribs.testPointPortParameter={};
    end
end

function fixOutportAttributes(blockH,origOutAttribs)
    ports=get_param(blockH,'PortHandles');
    outports=ports.Outport;
    if~isempty(outports)

        assert(~isempty(origOutAttribs.MustResolveToSignalObject));
        assert(~isempty(origOutAttribs.testPointPortParameter));
        for i=1:length(outports)
            set_param(outports(i),'MustResolveToSignalObject',...
            origOutAttribs.MustResolveToSignalObject{i});
            set_param(outports(i),'TestPoint',...
            origOutAttribs.testPointPortParameter{i});
        end
    end
end

function linesToDelete=constructLine(parentH,origLine,newPort,linesToDelete,isOutport)

    if nargin<5
        isOutport=false;
    end
    blkReplacer=Sldv.xform.BlkReplacer.getInstance();

    if origLine==-1

        return;
    end



    lineParams=get_param(origLine,'ObjectParameters');
    rawParamNames=fieldnames(lineParams);
    cachedLineInfo={};
    for idx=1:length(rawParamNames)
        thisPrm=rawParamNames{idx};
        isReadWrite=any(strcmp('read-write',lineParams.(thisPrm).Attributes));
        isListType=strcmp(lineParams.(thisPrm).Type,'list');
        if isReadWrite&&~isListType

            cachedLineInfo{end+1}=thisPrm;%#ok<AGROW>
            cachedLineInfo{end+1}=get_param(origLine,thisPrm);%#ok<AGROW>
        end
    end

    newLine=[];
    if isOutport
        DstPortHandle=get_param(origLine,'DstPortHandle');
        for idx=1:length(DstPortHandle)

            if get(DstPortHandle(idx),'Line')~=-1
                blkReplacer.deleteLine(origLine);
            else
                linesToDelete(end+1)=origLine;%#ok<AGROW>
            end
            break;
        end
        for idx=1:length(DstPortHandle)
            newLine=blkReplacer.addLine(parentH,...
            newPort,...
            DstPortHandle(idx),...
            'autorouting','on');

        end
    else
        newLine=blkReplacer.addLine(parentH,...
        get_param(origLine,'SrcPortHandle'),...
        newPort,...
        'autorouting','on');
        linesToDelete(end+1)=origLine;
    end

    if(~isempty(newLine))


        cachedLineInfo=reshape(cachedLineInfo,[2,numel(cachedLineInfo)/2]);
        for lineInfoIdx=1:size(cachedLineInfo,2)
            try
                set_param(newLine,cachedLineInfo{:,lineInfoIdx});
            catch ME


                if~strcmp(ME.identifier,'Simulink:blocks:BusSelectorCantChangeSignalLabel')
                    ME.rethrow();
                end
            end
        end
    end
end

function extraParamFiltered=filterAlreadyExisting(extraParam,blockH)
    extraParamFiltered=extraParam;
    for idx=1:length(extraParam)
        exists=true;
        try
            get_param(blockH,extraParam{idx});
        catch Mex %#ok<NASGU>
            exists=false;
        end
        if exists
            extraParamFiltered(idx)=[];
        end
    end
end

function handleInstanceSpecificParams(blockInfo)

    if blockInfo.HasModelMask

        return;
    end

    instanceParameters=blockInfo.InstanceParameters;
    if isempty(instanceParameters)

        return;
    end

    aliasInfo=cell(length(instanceParameters),1);
    blkReplacer=Sldv.xform.BlkReplacer.getInstance();
    varsToCarryStruct=blockInfo.BaseOrModelWSCarrSSMaskVars;
    for insParamIdx=1:length(instanceParameters)
        insParam=instanceParameters(insParamIdx);
        aliasInfo{insParamIdx}='';
        pathOfInsParam=insParam.Path;
        if~insParam.Argument||blockInfo.BlockPath.getLength()==1









            dataTypeOfInstParam=blockInfo.DataTypeOfInstParams{insParamIdx};
            if strcmp(dataTypeOfInstParam,'embedded.fi')
                insParamValue=['fi(',insParam.Value,',''numerictype'','...
                ,blockInfo.NumericTypeOfInstParams{insParamIdx},',''fimath'','...
                ,blockInfo.FimathOfInstParams{insParamIdx},')'];
            elseif~isempty(dataTypeOfInstParam)
                insParamValue=[dataTypeOfInstParam,'(',insParam.Value,')'];
            else
                insParamValue=insParam.Value;
            end

            if pathOfInsParam.getLength()==0


                varsToCarryStruct.(insParam.Name)=insParamValue;
            else



                aliasName=sprintf('aliasForInsPar_%d_%s',...
                blkReplacer.incAndGetMwsVarId,insParam.Name);
                aliasInfo{insParamIdx}=aliasName;
                varsToCarryStruct.(aliasName)=insParamValue;
            end
        else



            if pathOfInsParam.getLength()==0

                parentNode=blockInfo.Up;
                blockInfoBlkPath=blockInfo.BlockPath.convertToCell;
                defOfInstParamFound=false;
                while~isempty(parentNode)

                    if isa(parentNode,'Sldv.xform.RepMdlRefBlkTreeNode')
                        aliasCreatedInParent=parentNode.AliasCreatedForInstanceParams;
                        insParamsOfParent=parentNode.InstanceParameters;
                        parentBlkPath=parentNode.BlockPath.convertToCell;
                        for ii=1:length(insParamsOfParent)
                            insParamOfParent=insParamsOfParent(ii);
                            if~strcmp(insParamOfParent.Name,insParam.Name)
                                continue;
                            end
                            PathOfInsParamOfParent=insParamOfParent.Path.convertToCell;
                            completePathOfInsParamOfParent=parentBlkPath;
                            for jj=1:length(PathOfInsParamOfParent)
                                completePathOfInsParamOfParent{end+1}=...
                                PathOfInsParamOfParent{jj};%#ok<AGROW>
                            end
                            if isSamePath(blockInfoBlkPath,completePathOfInsParamOfParent)&&...
                                ~isempty(aliasCreatedInParent{ii})

                                varsToCarryStruct.(insParam.Name)=aliasCreatedInParent{ii};
                                defOfInstParamFound=true;
                                break;
                            end
                        end
                    end
                    if defOfInstParamFound
                        break;
                    else
                        parentNode=parentNode.Up;
                    end
                end


            end
        end
    end


    blockInfo.AliasCreatedForInstanceParams=aliasInfo;
    blockInfo.BaseOrModelWSCarrSSMaskVars=varsToCarryStruct;
end

function out=isSamePath(blockInfoBlkPath,completePathOfInsParamOfParent)
    out=false;
    if length(blockInfoBlkPath)==length(completePathOfInsParamOfParent)
        for ii=1:length(blockInfoBlkPath)
            if~strcmp(blockInfoBlkPath{ii},completePathOfInsParamOfParent{ii})
                return;
            end
        end
        out=true;
    end
end
