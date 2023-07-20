function[status,msg,irvLines]=p_checkIrvs(wrapperH,ssBlkH,stopOnError)

















    if nargin<2
        stopOnError=true;
    end


    msg='';
    status=1;
    irvLines=containers.Map();

    ssBlkH=get_param(ssBlkH,'Handle');


    blocks=find_system(ssBlkH,'FindAll','on','SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Type','block','BlockType','SubSystem');
    for idx=1:length(blocks)
        if(blocks(idx)~=ssBlkH)&&(strcmpi(get_param(blocks(idx),'Virtual'),'on'))
            [status,msg,ssIrvLines]=autosar.validation.p_checkIrvs(wrapperH,blocks(idx),stopOnError);
            if(status~=1)&&stopOnError
                return
            end
            mapkeys=keys(ssIrvLines);
            for mapidx=1:length(mapkeys)
                irvLines(mapkeys{mapidx})=ssIrvLines(mapkeys{mapidx});
            end
            clear ssIrvLines
        end
    end


    lines=find_system(ssBlkH,'FindAll','on','SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Type','line');
    labels=containers.Map();
    for idx=1:length(lines)
        try
            lineObj=get_param(lines(idx),'Object');
            srcBlock=lineObj.SrcBlockHandle;
            [dstBlocks,srcLabels,srcLabelBlocks]=...
            autosar.validation.walkThruVirtualBlockToDsts(lineObj,wrapperH,false);


            if srcBlock<0
                if~isempty(dstBlocks)&&dstBlocks(1)>0
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableLineWithNoSrc',...
                        get_param(lineObj.DstPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(dstBlocks(1))));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                else

                    continue
                end
            end



            if strcmpi(get_param(srcBlock,'BlockType'),'From')||...
                (strcmpi(get_param(srcBlock,'BlockType'),'Inport')&&...
                ~strcmpi(get_param(get_param(srcBlock,'Parent'),'Type'),'block_diagram')&&...
                strcmpi(get_param(get_param(srcBlock,'Parent'),'Virtual'),'on'))&&...
                (strcmpi(get_param(srcBlock,'BlockType'),'Subsystem')&&...
                strcmpi(get_param(srcBlock,'Virtual'),'on'))
                continue
            end





            if(strcmpi(get_param(srcBlock,'BlockType'),'VariantSource')||strcmpi(get_param(srcBlock,'BlockType'),'VariantSink'))
                continue;
            end

            if isempty(dstBlocks)||dstBlocks(1)<0
                status=0;
                if stopOnError
                    msg=message('RTW:autosar:MultiRunnableLineWithNoDst',...
                    get_param(lineObj.SrcPortHandle,'PortNumber'),...
                    autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                    msg=MSLDiagnostic(msg).message;
                    return
                else

                    continue
                end
            end



            if(strcmp(get_param(srcBlock,'BlockType'),'Inport')||...
                strcmp(get_param(srcBlock,'BlockType'),'InportShadow'))&&...
                get_param(get_param(srcBlock,'Parent'),'Handle')==wrapperH
                for dstIdx=1:length(dstBlocks)
                    curDestBlock=dstBlocks(dstIdx);
                    if~(slInternal('isFunctionCallSubsystem',curDestBlock)||...
                        i_isViewingDevice(curDestBlock)||...
                        strcmp(get_param(curDestBlock,'BlockType'),'ExportFunctionSpecification')||...
                        autosar.validation.ExportFcnValidator.isServerSubSys(curDestBlock)||...
                        autosar.validation.ExportFcnValidator.isModelWideEvent(curDestBlock)||...
                        autosar.simulink.msgTrigSS.Utils.isMessageTriggeredSS(curDestBlock))
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableNoPassThru',...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end
                    end
                end







            elseif strcmp(get_param(srcBlock,'BlockType'),'Merge')
                connectedToOutport=0;
                connectedToFCSS=0;
                connectedToRTB=0;
                for dstIdx=1:length(dstBlocks)
                    if slInternal('isFunctionCallSubsystem',dstBlocks(dstIdx))
                        connectedToFCSS=connectedToFCSS+1;
                    elseif(strcmp(get_param(dstBlocks(dstIdx),'BlockType'),'Outport'))
                        connectedToOutport=connectedToOutport+1;
                    elseif(strcmp(get_param(dstBlocks(dstIdx),'BlockType'),'RateTransition'))
                        connectedToRTB=connectedToRTB+1;
                    elseif(strcmp(get_param(dstBlocks(dstIdx),'BlockType'),'Merge'))

                    elseif i_isViewingDevice(dstBlocks(dstIdx))

                    else
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableMergeBadDst',...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end
                    end
                end


                if(connectedToFCSS>0)&&(connectedToOutport>0)
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableMergeBadDst2',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end


                if(connectedToOutport>1||connectedToRTB>1)
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableMergeBadDst3',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end






                if connectedToFCSS>0
                    if isempty(srcLabels)
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableNoLabel',...
                            1,autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end
                    end
                    [uniqueLabels,uniqueLabelIndices]=unique(srcLabels);
                    if length(uniqueLabels)~=1
                        status=0;
                        if stopOnError
                            msg=message(...
                            'RTW:autosar:MultiRunnableAmbiguousLabel',...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcLabelBlocks{uniqueLabelIndices(1)})),...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcLabelBlocks{uniqueLabelIndices(2)})));
                            msg=MSLDiagnostic(msg).message;
                            return;
                        else

                            continue
                        end
                    end


                    if(labels.isKey(uniqueLabels{1})==true)&&(labels(uniqueLabels{1})~=srcBlock)
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableReusedLabel',...
                            get_param(lineObj.SrcPortHandle,'PortNumber'),...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)),...
                            uniqueLabels{1});
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end
                    end
                    labels(uniqueLabels{1})=srcBlock;
                    irvLines(uniqueLabels{1})=lineObj;
                end


                if strcmp(get_param(srcBlock,'AllowUnequalInputPortWidths'),'on')
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableMergeBadWidths',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end

                nInputs=eval(get_param(srcBlock,'Inputs'));
                srcsOfMerge=zeros(nInputs,1);
                srcBlockLines=get_param(srcBlock,'LineHandles');
                inputLines=srcBlockLines.Inport;
                for pIdx=1:nInputs
                    line=inputLines(pIdx);
                    if line<0
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableUnconnectedPort',...
                            'Inport',...
                            pIdx,...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end
                    end

                    [srcsOfMerge(pIdx),candidateLabel]=i_getSrcOfMerge(line,wrapperH);


                    if connectedToFCSS>0
                        if isempty(candidateLabel)
                            status=0;
                            if stopOnError
                                msg=message(...
                                'RTW:autosar:MultiRunnableNoLabel',...
                                get_param(get_param(line,'SrcPortHandle'),'PortNumber'),...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcsOfMerge(pIdx))));
                                msg=MSLDiagnostic(msg).message;
                                return
                            else

                                continue
                            end
                        end

                        if~strcmp(uniqueLabels{1},candidateLabel)
                            status=0;
                            if stopOnError
                                msg=message(...
                                'RTW:autosar:MultiRunnableInconsistentMergeLabel',...
                                get_param(get_param(line,'SrcPortHandle'),'PortNumber'),...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcsOfMerge(pIdx))),...
                                uniqueLabels{1},...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                                msg=MSLDiagnostic(msg).message;
                                return
                            else

                                continue
                            end
                        end
                    end
                end


                if~isequal(size(unique(srcsOfMerge)),size(srcsOfMerge))
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableMergeBadSrc',...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end

                end





            elseif slInternal('isFunctionCallSubsystem',srcBlock)
                connectedToMerge=0;
                connectedToOutport=0;
                connectedToFCSS=0;
                connectedToViewingDevice=0;
                for dstIdx=1:length(dstBlocks)
                    if slInternal('isFunctionCallSubsystem',dstBlocks(dstIdx))||...
                        autosar.validation.ExportFcnValidator.isServerSubSys(dstBlocks(dstIdx))
                        connectedToFCSS=connectedToFCSS+1;





                        if isempty(srcLabels)
                            status=0;
                            if stopOnError
                                msg=message('RTW:autosar:MultiRunnableNoLabel',...
                                get_param(lineObj.SrcPortHandle,'PortNumber'),...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                                msg=MSLDiagnostic(msg).message;
                                return
                            else

                                continue
                            end
                        end
                        [uniqueLabels,uniqueLabelIndices]=unique(srcLabels);
                        if length(uniqueLabels)~=1
                            status=0;
                            if stopOnError
                                msg=message(...
                                'RTW:autosar:MultiRunnableAmbiguousLabel',...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcLabelBlocks{uniqueLabelIndices(1)})),...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcLabelBlocks{uniqueLabelIndices(2)})));
                                msg=MSLDiagnostic(msg).message;
                                return;
                            else

                                continue
                            end
                        end


                        if(labels.isKey(uniqueLabels{1})==true)&&(labels(uniqueLabels{1})~=srcBlock)
                            status=0;
                            if stopOnError
                                msg=message('RTW:autosar:MultiRunnableReusedLabel',...
                                get_param(lineObj.SrcPortHandle,'PortNumber'),...
                                autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)),...
                                uniqueLabels{1});
                                msg=MSLDiagnostic(msg).message;
                                return
                            else

                                continue
                            end
                        end
                        labels(uniqueLabels{1})=srcBlock;
                        irvLines(uniqueLabels{1})=lineObj;

                    elseif strcmp(get_param(dstBlocks(dstIdx),'BlockType'),...
                        'Outport')
                        connectedToOutport=connectedToOutport+1;
                    elseif strcmp(get_param(dstBlocks(dstIdx),'BlockType'),...
                        'Merge')
                        connectedToMerge=connectedToMerge+1;
                    elseif strcmp(get_param(dstBlocks(dstIdx),'BlockType'),...
                        'RateTransition')

                    elseif i_isViewingDevice(dstBlocks(dstIdx))
                        connectedToViewingDevice=connectedToViewingDevice+1;
                    else
                        status=0;
                        if stopOnError
                            msg=message('RTW:autosar:MultiRunnableBadDst',...
                            get_param(lineObj.SrcPortHandle,'PortNumber'),...
                            autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                            msg=MSLDiagnostic(msg).message;
                            return
                        else

                            continue
                        end

                    end
                end


                if connectedToFCSS>0&&connectedToMerge>0
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableBadDst2',...
                        get_param(lineObj.SrcPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end


                if connectedToOutport>1
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableBadDst3',...
                        get_param(lineObj.SrcPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end


                if connectedToMerge>1
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableBadDst4',...
                        get_param(lineObj.SrcPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end
                end


                if connectedToOutport>0&&connectedToMerge>0
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableBadDst5',...
                        get_param(lineObj.SrcPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end

                end

                if connectedToViewingDevice>0&&connectedToFCSS==0&&...
                    connectedToOutport==0&&connectedToMerge==0&&...
                    strcmp(lineObj.SegmentType,'trunk')
                    status=0;
                    if stopOnError
                        msg=message('RTW:autosar:MultiRunnableBadDst6',...
                        get_param(lineObj.SrcPortHandle,'PortNumber'),...
                        autosar.validation.AutosarUtils.removeNewLine(getfullname(srcBlock)));
                        msg=MSLDiagnostic(msg).message;
                        return
                    else

                        continue
                    end

                end

            end

        catch me

            status=0;
            if stopOnError
                msg=me.message;
                return
            else

                continue
            end
        end
    end



    function isValid=i_isViewingDevice(blk)


        switch get_param(blk,'BlockType')
        case{'Scope','Display'}
            isValid=true;
        otherwise
            isValid=false;
        end

        function[srcOfMerge,srcLabel]=i_getSrcOfMerge(line,wrapperH)

            lineObj=get_param(line,'Object');
            srcBlock=lineObj.SrcBlockHandle;
            srcLabel='';
            if(srcBlock>0&&...
                strcmp(get_param(srcBlock,'BlockType'),'From'))
                blkObj=get_param(srcBlock,'Object');
                gotoHandle=blkObj.GotoBlock.handle;
                gotoPortHandles=get_param(gotoHandle,'PortHandles');
                gotoInPortHandle=gotoPortHandles.Inport;
                gotoLineHandle=get_param(gotoInPortHandle,'Line');
                [srcOfMerge,candidateLabel]=i_getSrcOfMerge(gotoLineHandle,wrapperH);
                if~isempty(candidateLabel)
                    srcLabel=candidateLabel;
                end
            elseif(srcBlock>0&&...
                strcmpi(get_param(srcBlock,'BlockType'),'Subsystem')&&...
                strcmp(get_param(srcBlock,'virtual'),'on'))
                outPortHdl=lineObj.SrcPortHandle;
                outPortIdx=num2str(get_param(outPortHdl,'PortNumber'));
                outPort=find_system(srcBlock,'SearchDepth',1,'LookUnderMasks','all',...
                'FollowLinks','on','Type','Block',...
                'BlockType','Outport','Port',outPortIdx);
                outPortPortHandles=get_param(outPort,'PortHandles');
                outPortOutPortHandle=outPortPortHandles.Inport(1);
                outPortLineHandle=get_param(outPortOutPortHandle,'Line');
                [srcOfMerge,candidateLabel]=i_getSrcOfMerge(outPortLineHandle,wrapperH);
                if~isempty(candidateLabel)
                    srcLabel=candidateLabel;
                end
            elseif(srcBlock>0&&...
                strcmp(get_param(srcBlock,'BlockType'),'Inport')&&...
                strcmp(get_param(get_param(srcBlock,'Parent'),'Type'),'block'))&&...
                get_param(get_param(srcBlock,'Parent'),'Handle')~=wrapperH
                ssParent=get_param(srcBlock,'Parent');
                ssParentPortIdx=str2double(get_param(srcBlock,'Port'));
                ssParentPortHandles=get_param(ssParent,'PortHandles');
                ssParentInPortHandle=ssParentPortHandles.Inport(ssParentPortIdx);
                ssParentLineHandle=get_param(ssParentInPortHandle,'Line');
                [srcOfMerge,candidateLabel]=i_getSrcOfMerge(ssParentLineHandle,wrapperH);
                if~isempty(candidateLabel)
                    srcLabel=candidateLabel;
                end
            else
                srcOfMerge=srcBlock;
            end

            if~isempty(lineObj.Name)
                srcLabel=lineObj.Name;
            end



