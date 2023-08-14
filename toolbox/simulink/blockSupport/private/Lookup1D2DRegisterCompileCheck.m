
function Lookup1D2DRegisterCompileCheck(block,h)



    appendCompileCheck(h,block,@CollectLookup1D2DData,@ReplaceLookup1D2DWithLookupND);

end






function[hasRepeatBP,needEditBpType]=checkRepeatBP(block,Data)

    hasRepeatBP=false;
    needEditBpType=false;

    blkType=get_param(block,'BlockType');

    lum=get_param(block,'LookupMeth');




    if strcmp(blkType,'Lookup')
        if strcmp(lum,'Interpolation-Extrapolation')&&isSameFloatType(block,Data)


            bp=slResolve(get_param(block,'InputValues'),block);


            if strcmp(Data.inputType,'double')
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

        bpRow=slResolve(get_param(block,'RowIndex'),block);

        bpCol=slResolve(get_param(block,'ColumnIndex'),block);

        if strcmp(lum,'Interpolation-Extrapolation')&&isSameFloatType(block,Data)


            if strcmp(Data.inputType1,'double')

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

end



function result=isSameFloatType(block,Data)

    if strcmp(get_param(block,'BlockType'),'Lookup')
        sameDouble=strcmp(Data.inputType,'double')&&strcmp(Data.outputType,'double');
        sameSingle=strcmp(Data.inputType,'single')&&strcmp(Data.outputType,'single');
    else
        sameDouble=strcmp(Data.inputType1,'double')&&strcmp(Data.inputType2,'double')&&strcmp(Data.outputType,'double');
        sameSingle=strcmp(Data.inputType1,'single')&&strcmp(Data.inputType2,'single')&&strcmp(Data.outputType,'single');
    end
    result=sameDouble||sameSingle;

end


function pos=computeNewBlockPosition(startPoint,endPoint,Orientation,isInput)

    Girth=20;MinGirth=14;Separation=14;

    switch(Orientation)
    case 'left'
        LastSegmentLen=abs(endPoint(1,1)-startPoint(1,1));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        if isInput
            x1=endPoint(1,1)+Separation;
            y1=max(0,endPoint(1,2)-Girth/2);
        else
            x1=startPoint(1,1)-Girth-Separation;
            y1=max(0,startPoint(1,2)-Girth/2);
        end
    case 'right'
        LastSegmentLen=abs(endPoint(1,1)-startPoint(1,1));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        if isInput
            x1=max(0,endPoint(1,1)-Girth-Separation);
            y1=max(0,endPoint(1,2)-Girth/2);
        else
            x1=max(0,startPoint(1,1)+Separation);
            y1=max(0,startPoint(1,2)-Girth/2);
        end
    case 'up'
        LastSegmentLen=abs(endPoint(1,2)-startPoint(1,2));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        if isInput
            x1=max(0,endPoint(1,1)-Girth/2);
            y1=endPoint(1,2)+Separation;
        else
            x1=max(0,startPoint(1,1)-Girth/2);
            y1=startPoint(1,2)-Separation-Girth;
        end
    case 'down'
        LastSegmentLen=abs(endPoint(1,2)-startPoint(1,2));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        if isInput
            x1=max(0,endPoint(1,1)-Girth/2);
            y1=max(0,endPoint(1,2)-Separation-Girth);
        else
            x1=max(0,startPoint(1,1)-Girth/2);
            y1=max(0,startPoint(1,2)+Separation);
        end
    end
    pos=[x1,y1,x1+Girth,y1+Girth];
end



function insertDTCBlockForInput(block,Data)

    Lut2DBlockHandle=get_param(block,'handle');

    Lut2DLineHandles=get_param(Lut2DBlockHandle,'LineHandles');

    if strcmp(Data.inputType1,'boolean')
        portIdx=1;
    else
        portIdx=2;
    end

    DstLineHandle=Lut2DLineHandles.Inport(portIdx);

    LinePoints=get_param(DstLineHandle,'Points');

    startPoint=[LinePoints(end-1,1),LinePoints(end-1,2)];
    endPoint=[LinePoints(end,1),LinePoints(end,2)];


    decorations=get_decoration_params_l(Lut2DBlockHandle);

    BlockParent=get_param(block,'Parent');

    dtcName='slupdate11bbool2int';
    dataType='uint8';

    FinalDTCPos=computeNewBlockPosition(startPoint,endPoint,lower(get_param(Lut2DBlockHandle,'Orientation')),true);













    DTCBlocHandle=add_block('built-in/DataTypeConversion',...
    [BlockParent,'/',dtcName],'MakeNameUnique','on','Position',...
    FinalDTCPos,'ShowName','off',decorations{:},'OutDataTypeStr',dataType);



    originalLUT2DName=get_param(block,'Name');
    originalLUTPosition=get_param(block,'Position');



    newLUT2DHandle=add_block(block,[BlockParent,'/',originalLUT2DName],'MakeNameUnique','on','Position',FinalDTCPos);


    delete_block(block);


    set_param(newLUT2DHandle,'Name',originalLUT2DName);


    strSrc=sprintf('%s/%d',get_param(DTCBlocHandle,'Name'),1);
    strDst=sprintf('%s/%d',get_param(newLUT2DHandle,'Name'),portIdx);

    hNewDstInportLineHandle=add_line(BlockParent,strSrc,strDst,'autorouting','on');


    newPoint=get_param(DstLineHandle,'Points');
    dtcPortH=get_param(DTCBlocHandle,'PortHandles');
    dtcPortPoint=get_param(dtcPortH.Inport(1),'Position');
    deltaX=newPoint(end,1)-dtcPortPoint(end,1);
    deltaY=newPoint(end,2)-dtcPortPoint(end,2);

    newDTCPos=FinalDTCPos+[deltaX,deltaY,deltaX,deltaY];
    set_param(DTCBlocHandle,'Position',newDTCPos);


    set_param(DTCBlocHandle,'Position',FinalDTCPos);


    set_param(newLUT2DHandle,'Position',originalLUTPosition);


    delete_line(hNewDstInportLineHandle);
    hNewDstInportLineHandle=add_line(BlockParent,strSrc,strDst,'autorouting','on');%#ok

end




function insertDTCBlockForOutput(block,Data,isInput)

    Lut2DBlockHandle=get_param(block,'handle');

    Lut2DLineHandles=get_param(Lut2DBlockHandle,'LineHandles');

    portIdx=1;
    DstLineHandle=Lut2DLineHandles.Outport(portIdx);

    LinePoints=get_param(DstLineHandle,'Points');

    startPoint=[LinePoints(1,1),LinePoints(1,2)];
    endPoint=[LinePoints(2,1),LinePoints(2,2)];


    decorations=get_decoration_params_l(Lut2DBlockHandle);

    BlockParent=get_param(block,'Parent');

    dtcName='slupdate11bint2bool';
    dataType='boolean';

    FinalDTCPos=computeNewBlockPosition(startPoint,endPoint,lower(get_param(Lut2DBlockHandle,'Orientation')),false);












    DTCBlocHandle=add_block('built-in/DataTypeConversion',...
    [BlockParent,'/',dtcName],'MakeNameUnique','on','Position',...
    FinalDTCPos,'ShowName','off',decorations{:},'OutDataTypeStr',dataType);



    originalLUT2DName=get_param(block,'Name');
    originalLUTPosition=get_param(block,'Position');


    newLUT2DHandle=add_block(block,[BlockParent,'/',originalLUT2DName],'MakeNameUnique','on','Position',FinalDTCPos);


    delete_block(block);


    set_param(newLUT2DHandle,'Name',originalLUT2DName);


    strSrc=sprintf('%s/%d',get_param(newLUT2DHandle,'Name'),1);
    strDst=sprintf('%s/%d',get_param(DTCBlocHandle,'Name'),portIdx);

    hNewDTCOutportLineHandle=add_line(BlockParent,strSrc,strDst,'autorouting','on');


    newPoint=get_param(DstLineHandle,'Points');
    dtcPortH=get_param(DTCBlocHandle,'PortHandles');
    dtcPortPoint=get_param(dtcPortH.Outport(1),'Position');
    deltaX=newPoint(1,1)-dtcPortPoint(end,1);
    deltaY=newPoint(1,2)-dtcPortPoint(end,2);

    newDTCPos=FinalDTCPos+[deltaX,deltaY,deltaX,deltaY];
    set_param(DTCBlocHandle,'Position',newDTCPos);


    set_param(DTCBlocHandle,'Position',FinalDTCPos);


    set_param(newLUT2DHandle,'Position',originalLUTPosition);


    delete_line(hNewDTCOutportLineHandle);
    hNewDstInportLineHandle=add_line(BlockParent,strSrc,strDst,'autorouting','on');%#ok

end


function decorations=get_decoration_params_l(block)
    decorations={
    'Orientation',[];
    'ForegroundColor',[];
    'BackgroundColor',[];
    'DropShadow',[];
    'NamePlacement',[];
    'FontName',[];
    'FontSize',[];
    'FontWeight',[];
    'FontAngle',[]
    };

    num=size(decorations,1);
    for i=1:num,
        decorations{i,2}=get_param(block,decorations{i,1});
    end
    decorations=reshape(decorations',1,length(decorations(:)));
end



function hasWrongLum=checkUnsupportedLum(block)

    hasWrongLum=false;

    lum=get_param(block,'LookupMeth');
    if strcmp(lum,'Use Input Nearest')||strcmp(lum,'Use Input Above')
        hasWrongLum=true;
    end

end






function hasWrongExtrapMeth=checkUnsupportedExtrapMeth(block,Data)

    hasWrongExtrapMeth=false;
    lum=get_param(block,'LookupMeth');


    if strcmp(lum,'Interpolation-Extrapolation')&&~isSameFloatType(block,Data)
        hasWrongExtrapMeth=true;
    end

end



function result=isInFixptMode(block,Data)

    result=false;
    table=slResolve(get_param(block,'Table'),block);

    is_real=isreal(table);


    if~is_real
        result=true;
        return;
    end


    if~isSameFloatType(block,Data)
        result=true;
        return;
    end


    if strcmp(Data.logs,'MinMaxAndOverflow')||strcmp(Data.logs,'OverflowOnly')
        result=true;
    end

end


function res=calBigProd(inType,outType)

    res=false;
    if inType.isfixed&&outType.isfixed
        bigProdBits=inType.WordLength+outType.WordLength;

        if bigProdBits<32
            res=true;
        end
    end

end



function useBigProdMeth=checkBigProduct(block,Data)

    useBigProdMeth=false;

    if strcmp(get_param(block,'LookUpMeth'),'Interpolation-Use End Values')==1||...
        strcmp(get_param(block,'LookUpMeth'),'Interpolation-Extrapolation')==1

        if isInFixptMode(block,Data)

            if strcmp(get_param(block,'BlockType'),'Lookup')
                inType=fixdt(Data.inputType{1});
                outType=fixdt(Data.outputType{1});

                useBigProdMeth=calBigProd(inType,outType);
            end


            if strcmp(get_param(block,'BlockType'),'Lookup2D')
                inType1=fixdt(Data.inputType1{1});
                inType2=fixdt(Data.inputType2{1});
                outType=fixdt(Data.outputType{1});

                useBigProdMeth=calBigProd(inType1,outType);


                if~useBigProdMeth
                    useBigProdMeth=calBigProd(inType2,outType);
                end

            end
        end
    end

end

function res=get_runtimeparam_by_name(curBlk,paramName)


    slerr=sllasterror;
    try
        rto=[];
        rto=get_param(curBlk,'RuntimeObject');
    catch ME1
        err=sllasterror;
        if length(err)>1
            errID=err{1}.MessageID;
        else
            errID=err.MessageID;
        end

        if(strcmp(errID,'Simulink:Engine:RTI_REDUCED_BLOCK'))
            sllasterror(slerr);
        else
            rethrow(ME1);
        end
    end

    res=[];

    if(~isempty(rto))
        for i=1:rto.NumRuntimePrms

            curRuntimePrm=rto.RuntimePrm(i);

            if(~isempty(curRuntimePrm)&&...
                strcmp(curRuntimePrm.Name,paramName))

                res=curRuntimePrm;
                break;
            end
        end
    end

end



function isRtpEvenSpacing=CheckRtpEvenSpacing(fxpProp,xdata)

    isRtpEvenSpacing=false;

    if fxpProp.isfixed
        [~,spacingStatus,~]=fixpt_evenspace_cleanup(xdata,fxpProp);
        if strcmp(spacingStatus,DAStudio.message('SimulinkFixedPoint:datatyperules:EvenSpacing'))
            isRtpEvenSpacing=true;
        end
    end

end




function isEvenSpacing=CheckEvenSpacing(block,Data)

    if strcmp(get_param(block,'BlockType'),'Lookup')
        isEvenSpacing=CheckRtpEvenSpacing(Data.rtpFxpProp,Data.rtpData);
    else
        isEvenSpacing=CheckRtpEvenSpacing(Data.rtpRowFxpProp,Data.rtpRowData)...
        &&CheckRtpEvenSpacing(Data.rtpColFxpProp,Data.rtpColData);
    end

end



function Data=CollectLookup1D2DData(block,h)



    dts=get_param(block,'CompiledPortAliasedThruDataTypes');

    if strcmp(get_param(block,'BlockType'),'Lookup')
        Data.inputType=dts.Inport;
        rtp=get_runtimeparam_by_name(block,'InputValues');
        Data.rtpFxpProp=fixdt(rtp.AliasedThroughDatatype);
        Data.rtpData=double(rtp.Data);
    else
        Data.inputType1=dts.Inport(1);
        Data.inputType2=dts.Inport(2);
        rtpRow=get_runtimeparam_by_name(block,'RowIndex');
        rtpCol=get_runtimeparam_by_name(block,'ColumnIndex');
        Data.rtpRowFxpProp=fixdt(rtpRow.AliasedThroughDatatype);
        Data.rtpRowData=double(rtpRow.Data);
        Data.rtpColFxpProp=fixdt(rtpCol.AliasedThroughDatatype);
        Data.rtpColData=double(rtpCol.Data);
    end
    rtpTable=get_runtimeparam_by_name(block,'Table');
    Data.tableData=rtpTable.Data;

    Data.outputType=dts.Outport;


    Data.logs=get_param(block,'MinMaxOverflowLogging_Compiled');

end







function ReplaceLookup1D2DWithLookupND(block,h,Data)










    [hasRepeatBP,useBpEditType]=checkRepeatBP(block,Data);



    hasUnsupportedLum=checkUnsupportedLum(block);




    hasUnsupportedExtrapMeth=checkUnsupportedExtrapMeth(block,Data);



    hasBigProdMeth=checkBigProduct(block,Data);


    isBpEvenSpacing=CheckEvenSpacing(block,Data);



    allInputsAreBoolean=false;
    lookup2DHasOneBooleanInput=false;
    if(strcmp(get_param(block,'BlockType'),'Lookup')&&strcmp(Data.inputType,'boolean'))
        allInputsAreBoolean=true;
    end

    if(strcmp(get_param(block,'BlockType'),'Lookup2D'))
        if(strcmp(Data.inputType1,'boolean')&&strcmp(Data.inputType2,'boolean'))
            allInputsAreBoolean=true;
        else
            if(strcmp(Data.inputType1,'boolean')||strcmp(Data.inputType2,'boolean'))
                lookup2DHasOneBooleanInput=true;
            end
        end
    end


    if hasRepeatBP
        reason=DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleRepeatedBp');
        appendTransaction(h,block,reason,{});
        return;
    end

    isCompatible=allInputsAreBoolean||...
    (~hasUnsupportedLum&&~hasUnsupportedExtrapMeth&&~hasBigProdMeth);


    lum=get_param(block,'LookUpMeth');

    if~isCompatible
        if getPrompt(h)

            name=h.cleanLocationName(block);

            if hasUnsupportedLum
                reason=DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedLumPrompt',name,name);
                appendTransaction(h,block,reason,{});
            end

            if hasBigProdMeth
                reason=DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedBigProdPrompt',name,name);
                appendTransaction(h,block,reason,{});
            end

            if hasUnsupportedExtrapMeth
                reason=DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedExtrapMethPrompt',name,name);
                appendTransaction(h,block,reason,{});
            end

            replacePrompt=DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleReplacePrompt',name);
            replaceChoice=input(replacePrompt,'s');

            if isempty(replaceChoice)
                isCompatible=true;
            else
                if strcmp(replaceChoice(1),'y')==1
                    isCompatible=true;
                elseif strcmp(replaceChoice(1),'a')==1
                    isCompatible=true;
                    setPrompt(h,false);
                end
            end

        elseif doUpdate(h)
            isCompatible=true;
        end


        if isCompatible
            if hasUnsupportedLum||hasUnsupportedExtrapMeth
                lum='Interpolation-Use End Values';
            end
        end
    else

        if~askToReplace(h,block)
            return;
        end
    end


    if isCompatible

        if strcmp(get_param(block,'BlockType'),'Lookup')

            bp=get_param(block,'InputValues');
        else
            bp1=get_param(block,'RowIndex');
            bp2=get_param(block,'ColumnIndex');
            inputSameDT=get_param(block,'InputSameDT');
        end

        table=get_param(block,'Table');
        outMin=get_param(block,'OutMin');
        outMax=get_param(block,'OutMax');

        outDataTypeStr=get_param(block,'OutDataTypeStr');
        if strcmp(outDataTypeStr,'Inherit: Same as input')
            outDataTypeStr='Inherit: Same as first input';
        end

        lockScale=get_param(block,'LockScale');
        rndMeth=get_param(block,'RndMeth');
        overFlow=get_param(block,'SaturateOnIntegerOverflow');
        st=get_param(block,'SampleTime');

        if strcmp(lum,'Interpolation-Extrapolation')
            extrapMeth='Linear';
        elseif strcmp(lum,'Interpolation-Use End Values')
            extrapMeth='None - Clip';
        end


        indexSearchMeth='Binary search';


        if getPrompt(h)&&isBpEvenSpacing
            name=h.cleanLocationName(block);
            SL_indexSearchPrompt=DAStudio.message('SimulinkBlocks:upgrade:lookup1D2DChooseIndexSearchMethPrompt',name,name);
            indexSearchChoice=input(SL_indexSearchPrompt,'s');

            if isempty(indexSearchChoice)
                indexSearchMeth='Evenly spaced points';
            else
                if strcmp(indexSearchChoice(1),'y')
                    indexSearchMeth='Evenly spaced points';
                else strcmp(indexSearchChoice(1),'a')
                    indexSearchMeth='Evenly spaced points';
                    setPrompt(h,false);
                end
            end
        end

        if useBpEditType
            bpDataTypeStr='Inherit: Inherit from ''Breakpoint data''';
        else
            bpDataTypeStr='Inherit: Same as corresponding input';
        end

        if allInputsAreBoolean

            if(strcmp(outDataTypeStr,'Inherit: Inherit via back propagation'))
                outDataTypeStr=['fixdt(''',Data.outputType{1},''')'];
            else
                if(strcmp(outDataTypeStr,'Inherit: Same as first input'))
                    outDataTypeStr='boolean';
                end
            end

            if strcmp(get_param(block,'BlockType'),'Lookup')
                funcSet=uReplaceBlock(h,block,'built-in/LookupNDDirect',...
                'NumberOfTableDimensions','1',...
                'InputsSelectThisObjectFromTable','Element',...
                'TableIsInput','off',...
                'Table',table,...
                'DiagnosticForOutOfRangeInput','none',...
                'SampleTime',st,...
                'TableMin',outMin,...
                'TableMax',outMax,...
                'TableDataTypeStr',outDataTypeStr,...
                'LockScale','off');
            else
                funcSet=uReplaceBlock(h,block,'built-in/LookupNDDirect',...
                'NumberOfTableDimensions','2',...
                'InputsSelectThisObjectFromTable','Element',...
                'TableIsInput','off',...
                'Table',table,...
                'DiagnosticForOutOfRangeInput','none',...
                'SampleTime',st,...
                'TableMin',outMin,...
                'TableMax',outMax,...
                'TableDataTypeStr',outDataTypeStr,...
                'LockScale','off');
            end
        else

            if strcmp(lum,'Use Input Below')

                if strcmp(get_param(block,'BlockType'),'Lookup')

                    funcSet=uReplaceBlock(h,block,'built-in/Lookup_n-D',...
                    'NumberOfTableDimensions','1',...
                    'BreakpointsForDimension1',bp,...
                    'Table',table,...
                    'OutMin',outMin,...
                    'OutMax',outMax,...
                    'OutDataTypeStr',outDataTypeStr,...
                    'LockScale',lockScale,...
                    'RndMeth',rndMeth,...
                    'SaturateOnIntegerOverflow',overFlow,...
                    'InternalRulePriority','Speed',...
                    'SampleTime',st,...
                    'InterpMethod','None - Flat',...
                    'ExtrapMethod','Clip',...
                    'IndexSearchMethod',indexSearchMeth,...
                    'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
                else
                    if(lookup2DHasOneBooleanInput)
                        insertDTCBlockForInput(block,Data);
                        if((strcmp(outDataTypeStr,'Inherit: Same as first input'))&&strcmp(Data.inputType1,'boolean'))
                            insertDTCBlockForOutput(block,Data);
                        end
                    end

                    funcSet=uReplaceBlock(h,block,'built-in/Lookup_n-D',...
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
                    'InternalRulePriority','Speed',...
                    'InterpMethod','None - Flat',...
                    'ExtrapMethod','Clip',...
                    'IndexSearchMethod',indexSearchMeth,...
                    'BreakpointsForDimension1DataTypeStr',bpDataTypeStr,...
                    'BreakpointsForDimension2DataTypeStr',bpDataTypeStr);
                end

            else

                if strcmp(get_param(block,'BlockType'),'Lookup')
                    funcSet=uReplaceBlock(h,block,'built-in/Lookup_n-D',...
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
                    'InternalRulePriority','Speed',...
                    'InterpMethod','Linear',...
                    'ExtrapMethod',extrapMeth,...
                    'IndexSearchMethod',indexSearchMeth,...
                    'BreakpointsForDimension1DataTypeStr',bpDataTypeStr);
                else
                    if(lookup2DHasOneBooleanInput)
                        insertDTCBlockForInput(block,Data);
                        if((strcmp(outDataTypeStr,'Inherit: Same as first input'))&&strcmp(Data.inputType1,'boolean'))
                            insertDTCBlockForOutput(block,Data);
                        end
                    end

                    funcSet=uReplaceBlock(h,block,'built-in/Lookup_n-D',...
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
                    'InternalRulePriority','Speed',...
                    'InterpMethod','Linear',...
                    'ExtrapMethod',extrapMeth,...
                    'IndexSearchMethod',indexSearchMeth,...
                    'BreakpointsForDimension1DataTypeStr',bpDataTypeStr,...
                    'BreakpointsForDimension2DataTypeStr',bpDataTypeStr);
                end
            end
        end
        reason=DAStudio.message('SimulinkBlocks:upgrade:lookupTableCompatible');
        appendTransaction(h,block,reason,{funcSet});


    else
        funcSet={};

        if hasUnsupportedLum
            reason=...
            DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedLum');
        elseif hasUnsupportedExtrapMeth
            reason=...
            DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedExtrapMeth');
        elseif hasBigProdMeth
            reason=...
            DAStudio.message('SimulinkBlocks:upgrade:lookupTableIncompatibleUnsupportedBigProd');
        end
        appendTransaction(h,block,reason,{funcSet});
    end

end
