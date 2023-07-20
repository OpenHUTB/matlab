function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

    comments={};

    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    unknownParam=0;

    switch pathItem

    case 'Accumulator'
        prefixStr='accum';
    case 'Product output'
        prefixStr='prodOutput';
    case{'Gradients','Output'}
        prefixStr='output';
    otherwise
        unknownParam=1;
    end

    if unknownParam
        return;
    else
        paramNames.modeStr=strcat(prefixStr,'Mode');
        paramNames.wlStr=strcat(prefixStr,'WordLength');
        paramNames.flStr=strcat(prefixStr,'FracLength');
    end

    [~,~,~,specifiedDTStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
    isDataTypeFullyInherited=~isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'));

    if isDataTypeFullyInherited



        [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
        return;
    else

        wlString=paramNames.wlStr;
        wlValueStr=blkObj.(wlString);


        if isempty(wlValueStr)
            return;
        end

        [~,~,~,specifiedDTStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        isDataTypeFracLengthOnlyInherited=strcmpi(specifiedDTStr,'Specify word length');

        if isDataTypeFracLengthOnlyInherited

            sgVal=1;

            blkPath=regexprep(blkObj.getFullName,'\n',' ');
            [isWLValid,wlVal]=evalBlkWLFLVal(blkPath,wlValueStr);


            if isWLValid

                specifiedDTStr=sprintf('fixdt(%d,%d)',sgVal,wlVal);
            else
                specifiedDTStr='';
            end

            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

            return;
        else

            flString=paramNames.flStr;
            flValueStr=blkObj.(flString);


            if isempty(flValueStr)
                return;
            else

                sgVal=1;

                blkPath=regexprep(blkObj.getFullName,'\n',' ');
                [isWLValid,wlVal]=evalBlkWLFLVal(blkPath,wlValueStr);


                [isFLValid,flVal]=evalBlkWLFLVal(blkPath,flValueStr);

                if isWLValid&&isFLValid
                    specifiedDTStr=sprintf('fixdt(%d,%d,%d)',sgVal,wlVal,flVal);
                else
                    specifiedDTStr='';
                end
            end
        end

        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    end


    function[isValid,val]=evalBlkWLFLVal(blockPath,unevaledParamStr)

        try
            val=slResolve(unevaledParamStr,blockPath);
            isValid=~isempty(val);
        catch
            val=[];
            isValid=false;
        end




