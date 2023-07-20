function rule=blkrep_rule_lookup_dep

    rule=Sldv.xform.BlkRepRule;
    rule.FileName=mfilename;

    rule.BlockType='Lookup';

    rule.ReplacementPath=sprintf('sldvautoblkreplib/DV Lookup');



    rule.ReplacementMode='Normal';

    rule.CopyOrigDialogParams=true;

    rule.RunTimeParamsToCapture={'InputValues','Table'};

    rule.IsReplaceableCallBack=@replacementTestFunction;
    rule.PostReplacementCallBack=@postReplacementFunction;
end

function out=replacementTestFunction(blockH,blockInfo)
    out=false;
    if strcmp(get_param(blockH,'Mask'),'off')
        if nargin<2
            out=true;
        else
            compiledInfo=blockInfo.infoForPostReplacement;
            is1D=strcmp(get_param(blockH,'BlockType'),'Lookup');
            out=~checkRepeatBP(blockH,is1D,compiledInfo);
        end
    end
end

function postReplacementFunction(blockH,preReplacementCompiledInfo)
    is1D=true;
    try
        get_param(blockH,'InputValues');
    catch Mex %#ok<NASGU>
        is1D=false;
    end
    setPostReplacementAttributes(blockH,is1D,preReplacementCompiledInfo);
end

function setPostReplacementAttributes(blockH,is1D,compiledInfo)
    compiledInfo=updateBoolInputSingnals(blockH,is1D,compiledInfo);
    [~,useBpEditType,blockH]=checkRepeatBP(blockH,is1D,compiledInfo);
    isBpEvenSpacing=checkEvenSpacing(is1D,compiledInfo);
    lum=get_param(blockH,'LookUpMeth');
    if checkUnsupportedLum(blockH)






        lum='Use Input Below';
    elseif checkUnsupportedExtrapMeth(blockH,is1D,compiledInfo)
        lum='Interpolation-Use End Values';
    end
    if is1D
        bp=get_param(blockH,'InputValues');
    else
        bp1=get_param(blockH,'RowIndex');
        bp2=get_param(blockH,'ColumnIndex');
        inputSameDT=get_param(blockH,'InputSameDT');
    end

    table=get_param(blockH,'Table');
    outMin=get_param(blockH,'OutMin');
    outMax=get_param(blockH,'OutMax');

    outDataTypeStr=get_param(blockH,'OutDataTypeStr');
    if strcmp(outDataTypeStr,'Inherit: Same as input')
        outDataTypeStr='Inherit: Same as first input';
    end

    lockScale=get_param(blockH,'LockScale');
    rndMeth=get_param(blockH,'RndMeth');
    overFlow=get_param(blockH,'SaturateOnIntegerOverflow');
    st=get_param(blockH,'SampleTime');

    if strcmp(lum,'Interpolation-Extrapolation')
        extrapMeth='Linear';
    elseif strcmp(lum,'Interpolation-Use End Values')
        extrapMeth='None - Clip';
    end

    indexSearchMeth='Binary search';
    if isBpEvenSpacing
        indexSearchMeth='Evenly spaced points';
    end

    if useBpEditType
        bpDataTypeStr='Inherit: Inherit from ''Breakpoint data''';
    else
        bpDataTypeStr='Inherit: Same as corresponding input';
    end

    opts={'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Lookup_n-D'};
    lookupNDBlock=find_system(blockH,opts{:});

    if strcmp(lum,'Use Input Below')
        if is1D
            set_param(lookupNDBlock,...
            'NumberOfTableDimensions','1',...
            'BreakpointsForDimension1',bp,...
            'Table',table,...
            'OutMin',outMin,...
            'OutMax',outMax,...
            'OutDataTypeStr',outDataTypeStr,...
            'LockScale',lockScale,...
            'RndMeth',rndMeth,...
            'SaturateOnIntegerOverflow',overFlow,...
            'SampleTime',st,...
            'InterpMethod','None - Flat',...
            'IndexSearchMethod',indexSearchMeth,...
            'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
        else
            set_param(lookupNDBlock,...
            'NumberOfTableDimensions','2',...
            'BreakpointsForDimension1',bp1,...
            'BreakpointsForDimension2',bp2,...
            'InputSameDT',inputSameDT,...
            'Table',table,...
            'OutMin',outMin,...
            'OutMax',outMax,...
            'OutDataTypeStr',outDataTypeStr,...
            'LockScale',lockScale,...
            'RndMeth',rndMeth,...
            'SaturateOnIntegerOverflow',overFlow,...
            'SampleTime',st,...
            'InterpMethod','None - Flat',...
            'IndexSearchMethod',indexSearchMeth,...
            'BreakpointsForDimension1DataTypeStr',bpDataTypeStr,...
            'BreakpointsForDimension2DataTypeStr',bpDataTypeStr);
        end

    else

        if is1D
            set_param(lookupNDBlock,...
            'NumberOfTableDimensions','1',...
            'BreakpointsForDimension1',bp,...
            'Table',table,...
            'OutMin',outMin,...
            'OutMax',outMax,...
            'OutDataTypeStr',outDataTypeStr,...
            'LockScale',lockScale,...
            'RndMeth',rndMeth,...
            'SaturateOnIntegerOverflow',overFlow,...
            'SampleTime',st,...
            'InterpMethod','Linear',...
            'ExtrapMethod',extrapMeth,...
            'IndexSearchMethod',indexSearchMeth,...
            'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
        else
            set_param(lookupNDBlock,...
            'NumberOfTableDimensions','2',...
            'BreakpointsForDimension1',bp1,...
            'BreakpointsForDimension2',bp2,...
            'InputSameDT',inputSameDT,...
            'Table',table,...
            'OutMin',outMin,...
            'OutMax',outMax,...
            'OutDataTypeStr',outDataTypeStr,...
            'LockScale',lockScale,...
            'RndMeth',rndMeth,...
            'SaturateOnIntegerOverflow',overFlow,...
            'SampleTime',st,...
            'InterpMethod','Linear',...
            'ExtrapMethod',extrapMeth,...
            'IndexSearchMethod',indexSearchMeth,...
            'BreakpointsForDimension1DataTypeStr',bpDataTypeStr,...
            'BreakpointsForDimension2DataTypeStr',bpDataTypeStr);
        end
    end
end

function isEvenSpacing=checkEvenSpacing(is1D,compiledInfo)
    if~isempty(compiledInfo)&&isfield(compiledInfo,'rtpParamInfo')&&...
        ~isempty(compiledInfo.rtpParamInfo)
        try
            rtpParamInfo=compiledInfo.rtpParamInfo;
            if is1D
                if isfield(rtpParamInfo,'rtp_InputValues_Data')&&...
                    isfield(rtpParamInfo,'rtp_InputValues_FxpProp')
                    isEvenSpacing=isEvenSpaced(rtpParamInfo.rtp_InputValues_FxpProp,...
                    rtpParamInfo.rtp_InputValues_Data);
                end
            else
                if isfield(rtpParamInfo,'rtp_RowIndex_Data')&&...
                    isfield(rtpParamInfo,'rtp_RowIndex_FxpProp')&&...
                    isfield(rtpParamInfo,'rtp_ColumnIndex_Data')&&...
                    isfield(rtpParamInfo,'rtp_ColumnIndex_FxpProp')
                    isEvenSpacing=isEvenSpaced(rtpParamInfo.rtp_RowIndex_FxpProp,rtpParamInfo.rtp_RowIndex_Data)&&...
                    isEvenSpaced(rtpParamInfo.rtp_ColumnIndex_FxpProp,rtpParamInfo.rtp_ColumnIndex_Data);
                end
            end
        catch Mex %#ok<NASGU>
            isEvenSpacing=false;
        end
    else
        isEvenSpacing=false;
    end
end

function isRtpEvenSpacing=isEvenSpaced(fxpProp,xdata)
    isRtpEvenSpacing=false;
    if fxpProp.isfixed
        [~,spacingStatus,~]=fixpt_evenspace_cleanup(xdata,fxpProp);
        if strcmp(spacingStatus,DAStudio.message('SimulinkFixedPoint:datatyperules:EvenSpacing'))
            isRtpEvenSpacing=true;
        end
    end
end

function[hasRepeatBP,needEditBpType,newBlockH]=checkRepeatBP(blockH,is1D,compiledInfo)
    hasRepeatBP=false;
    needEditBpType=false;

    lum=get_param(blockH,'LookupMeth');
    blockFullPath=getfullname(blockH);
    if is1D
        if strcmp(lum,'Interpolation-Extrapolation')&&...
            isSameFloatType(is1D,compiledInfo)

            bp=slResolve(get_param(blockFullPath,'InputValues'),blockFullPath);

            inputType=compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType;
            if strcmp(inputType,'double')
                space=diff(double(bp));
            else
                space=diff(single(bp));
            end

            if length(space)~=nnz(space)
                hasRepeatBP=true;
            end

            if hasRepeatBP
                space=diff(bp);
                if length(space)==nnz(space)
                    hasRepeatBP=false;
                    needEditBpType=true;
                end
            end
        end
    else
        bpRow=slResolve(get_param(blockFullPath,'RowIndex'),blockFullPath);
        bpCol=slResolve(get_param(blockFullPath,'ColumnIndex'),blockFullPath);

        if strcmp(lum,'Interpolation-Extrapolation')&&isSameFloatType(is1D,compiledInfo)
            inputType1=compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType;
            if strcmp(inputType1,'double')
                spaceRow=diff(double(bpRow));
                spaceCol=diff(double(bpCol));
            else
                spaceRow=diff(single(bpRow));
                spaceCol=diff(single(bpCol));
            end

            if length(spaceRow)~=nnz(spaceRow)||length(spaceCol)~=nnz(spaceCol)
                hasRepeatBP=true;
            end

            if hasRepeatBP
                spaceRow=diff(bpRow);
                spaceCol=diff(bpCol);
                if length(spaceRow)==nnz(spaceRow)&&length(spaceCol)==nnz(spaceCol)
                    hasRepeatBP=false;
                    needEditBpType=true;
                end
            end
        end
    end
    newBlockH=get_param(blockFullPath,'handle');
end

function hasWrongLum=checkUnsupportedLum(blockH)
    hasWrongLum=false;
    lum=get_param(blockH,'LookupMeth');
    if strcmp(lum,'Use Input Nearest')||strcmp(lum,'Use Input Above')
        hasWrongLum=true;
    end
end

function hasWrongExtrapMeth=checkUnsupportedExtrapMeth(blockH,is1D,compiledInfo)
    hasWrongExtrapMeth=false;
    lum=get_param(blockH,'LookupMeth');
    if strcmp(lum,'Interpolation-Extrapolation')&&~isSameFloatType(is1D,compiledInfo)
        hasWrongExtrapMeth=true;
    end
end

function result=isSameFloatType(is1D,compiledInfo)
    if is1D
        inputType=compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType;
        ouputType=compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType;
        sameDouble=strcmp(inputType,'double')&&strcmp(ouputType,'double');
        sameSingle=strcmp(inputType,'single')&&strcmp(ouputType,'single');
    else
        inputType=compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType;
        inputType2=compiledInfo.Inport{2}.compiledAttributes.AliasThruDataType;
        ouputType=compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType;
        sameDouble=strcmp(inputType,'double')&&strcmp(inputType2,'double')&&strcmp(ouputType,'double');
        sameSingle=strcmp(inputType,'single')&&strcmp(inputType2,'single')&&strcmp(ouputType,'single');
    end
    result=sameDouble||sameSingle;
end

function compiledInfo=updateBoolInputSingnals(blockH,is1D,compiledInfo)
    if is1D
        inputType={compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType};
    else
        inputType={compiledInfo.Inport{1}.compiledAttributes.AliasThruDataType,...
        compiledInfo.Inport{2}.compiledAttributes.AliasThruDataType};
    end
    ouputType=compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType;
    booltypes=strcmp([inputType,ouputType],'boolean');
    if any(booltypes)
        [ssInBlkHs,ssOutBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(blockH);
        if all(booltypes)

            castType='double';
            inportsToFix=ssInBlkHs;
            for idx=1:length(inportsToFix)
                addDataTypeConversion(inportsToFix(idx),castType);
                compiledInfo.Inport{idx}.compiledAttributes.AliasThruDataType=castType;
            end
            addDataTypeConversion(ssOutBlkHs,'Inherit: Inherit via back propagation');
            compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType=castType;
        elseif all(booltypes(1:end-1))&&~booltypes(end)

            castType=ouputType;
            inportsToFix=ssInBlkHs;
            for idx=1:length(inportsToFix)
                addDataTypeConversion(inportsToFix(idx),castType);
                compiledInfo.Inport{idx}.compiledAttributes.AliasThruDataType=castType;
            end
        elseif all(~booltypes(1:end-1))&&booltypes(end)
            castType='double';
            addDataTypeConversion(ssOutBlkHs,'Inherit: Inherit via back propagation');
            compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType=castType;
        else
            assert(~is1D);
            castType=inputType(~booltypes(1:end-1));
            castType=castType{1};
            inportsToFix=ssInBlkHs(booltypes(1:end-1));
            for idx=1:length(inportsToFix)
                addDataTypeConversion(inportsToFix(idx),castType);
                compiledInfo.Inport{idx}.compiledAttributes.AliasThruDataType=castType;
            end
            if booltypes(end)
                addDataTypeConversion(ssOutBlkHs,'Inherit: Inherit via back propagation');
                compiledInfo.Outport{1}.compiledAttributes.AliasThruDataType=castType;
            end
        end
    end
end

function addDataTypeConversion(portToFix,castType)
    dataTypeBlk='simulink/Signal Attributes/Data Type Conversion';
    newBlkPath=sprintf('%s_dataTypeConvert',getfullname(portToFix));
    positionPort=get_param(portToFix,'Position');
    portH=get_param(portToFix,'PortHandles');
    if strcmp(get_param(portToFix,'BlockType'),'Inport')
        srcPortH=portH.Outport;
        origLineH=get_param(srcPortH,'Line');
        dstPortH=get_param(origLineH,'DstPortHandle');
        dstBlockPosition=get_param(get_param(dstPortH,'Parent'),'Position');
        delete_line(origLineH);
        distance=dstBlockPosition(1)-positionPort(3);
        dataTypeConvertPosition=...
        [positionPort(3)+distance/3,positionPort(2),positionPort(3)+(2*distance/3),positionPort(4)];
    else
        dstPortH=portH.Inport;
        origLineH=get_param(dstPortH,'Line');
        srcPortH=get_param(origLineH,'SrcPortHandle');
        srcBlockPosition=get_param(get_param(srcPortH,'Parent'),'Position');
        delete_line(origLineH);
        distance=positionPort(1)-srcBlockPosition(3);
        dataTypeConvertPosition=...
        [srcBlockPosition(3)+distance/3,positionPort(2),srcBlockPosition(3)+(2*distance/3),positionPort(4)];
    end
    newDataTypeConvertBlock=add_block(dataTypeBlk,newBlkPath,...
    'Position',dataTypeConvertPosition,'ShowName','off',...
    'OutDataTypeStr',castType);
    newDataTypeConvertBlockPorts=get_param(newDataTypeConvertBlock,'PortHandles');
    add_line(get_param(portToFix,'Parent'),...
    srcPortH,...
    newDataTypeConvertBlockPorts.Inport,...
    'autorouting','on');
    add_line(get_param(portToFix,'Parent'),...
    newDataTypeConvertBlockPorts.Outport,...
    dstPortH,...
    'autorouting','on');
end
