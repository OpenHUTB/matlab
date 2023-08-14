function Info=utilGetLookup1D2DInfo(model,quickScan)














    if quickScan
        Info=utilGetLookup1D2DQuickScanInfo(model);
    else
        Info=utilGetLookup1D2DCompInfo(model);
    end

end



function Info=utilGetLookup1D2DQuickScanInfo(model)















    Info={};



    commonArgs={'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on'};

    LUT1DBlks=find_system(model,commonArgs{:},'BlockType','Lookup');
    LUT2DBlks=find_system(model,commonArgs{:},'BlockType','Lookup2D');
    stdLUTBlks={LUT1DBlks{:},LUT2DBlks{:}};

    blkName=struct('BlockName','');

    val=struct('isCompatible',true,...
    'useBpEditType',false,...
    'hasUnsupportedExtrapMeth',true,...
    'isBpEvenSpacing',false);

    if~isempty(stdLUTBlks)
        retVal=cell(1,numel(stdLUTBlks));
        for i=1:numel(stdLUTBlks)
            block=stdLUTBlks{i};
            blkName.BlockName=block;
            names=[fieldnames(blkName);fieldnames(val)];
            retStr=cell2struct([struct2cell(blkName);struct2cell(val)],names,1);
            retVal{i}=retStr;
        end
        Info=retVal;
    end

end



function compInfo=utilGetLookup1D2DCompInfo(model)











    compInfo={};



    commonArgs={'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on'};

    LUT1DBlks=find_system(model,commonArgs{:},'BlockType','Lookup');
    LUT2DBlks=find_system(model,commonArgs{:},'BlockType','Lookup2D');
    stdLUTBlks={LUT1DBlks{:},LUT2DBlks{:}};

    blkName=struct('BlockName','');

    if~isempty(stdLUTBlks)
        retVal=cell(1,numel(stdLUTBlks));
        for i=1:numel(stdLUTBlks)
            block=stdLUTBlks{i};
            data=CollectLookup1D2DData(block);

            if isempty(data)
                continue;
            end
            flags=CheckLookup1D2DWithLookupND(block,data);
            blkName.BlockName=block;
            names=[fieldnames(blkName);fieldnames(flags)];
            retStr=cell2struct([struct2cell(blkName);struct2cell(flags)],names,1);
            retVal{i}=retStr;
        end
        compInfo=retVal;
    end
end


function retVal=CheckLookup1D2DWithLookupND(block,Data)













    val=struct('isCompatible',false,...
    'useBpEditType',false,...
    'hasUnsupportedExtrapMeth',false,...
    'isBpEvenSpacing',false);



    [hasRepeatBP,useBpEditType]=checkRepeatBP(block,Data);

    hasBooleanInputs=false;

    if(strcmp(get_param(block,'BlockType'),'Lookup')&&strcmp(Data.inputType,'boolean'))
        hasBooleanInputs=true;
    else
        if(strcmp(get_param(block,'BlockType'),'Lookup2D'))
            if(strcmp(Data.inputType1,'boolean')||strcmp(Data.inputType2,'boolean'))
                hasBooleanInputs=true;
            end
        end
    end



    hasUnsupportedLum=checkUnsupportedLum(block);

    val.isCompatible=~hasRepeatBP&&~hasBooleanInputs&&~hasUnsupportedLum;

    if(val.isCompatible)


        val.useBpEditType=useBpEditType;



        val.hasUnsupportedExtrapMeth=checkUnsupportedExtrapMeth(block,Data);



        val.isBpEvenSpacing=CheckEvenSpacing(block,Data);
    end

    retVal=val;

end








function Data=CollectLookup1D2DData(block)



    dts=get_param(block,'CompiledPortAliasedThruDataTypes');

    if strcmp(get_param(block,'BlockType'),'Lookup')
        Data.inputType=dts.Inport;
        rtp=get_runtimeparam_by_name(block,'InputValues');
        if isempty(rtp)



            Data=[];
            return;
        end
        Data.rtpFxpProp=fixdt(rtp.AliasedThroughDatatype);
        Data.rtpData=double(rtp.Data);
    else
        Data.inputType1=dts.Inport(1);
        Data.inputType2=dts.Inport(2);
        rtpRow=get_runtimeparam_by_name(block,'RowIndex');
        if isempty(rtpRow)
            Data=[];
            return;
        end
        rtpCol=get_runtimeparam_by_name(block,'ColumnIndex');
        if isempty(rtpCol)
            Data=[];
            return;
        end
        Data.rtpRowFxpProp=fixdt(rtpRow.AliasedThroughDatatype);
        Data.rtpRowData=double(rtpRow.Data);
        Data.rtpColFxpProp=fixdt(rtpCol.AliasedThroughDatatype);
        Data.rtpColData=double(rtpCol.Data);
    end
    rtpTable=get_runtimeparam_by_name(block,'Table');
    if isempty(rtpTable)
        Data=[];
        return;
    end
    Data.tableData=rtpTable.Data;
    Data.outputType=dts.Outport;


    Data.logs=get_param(block,'MinMaxOverflowLogging_Compiled');

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






function hasWrongLum=checkUnsupportedLum(block)

    hasWrongLum=false;

    lum=get_param(block,'LookupMeth');
    if strcmp(lum,'Use Input Above')
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




function isEvenSpacing=CheckEvenSpacing(block,Data)

    if strcmp(get_param(block,'BlockType'),'Lookup')
        isEvenSpacing=CheckRtpEvenSpacing(Data.rtpFxpProp,Data.rtpData);
    else
        isEvenSpacing=CheckRtpEvenSpacing(Data.rtpRowFxpProp,Data.rtpRowData)...
        &&CheckRtpEvenSpacing(Data.rtpColFxpProp,Data.rtpColData);
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
