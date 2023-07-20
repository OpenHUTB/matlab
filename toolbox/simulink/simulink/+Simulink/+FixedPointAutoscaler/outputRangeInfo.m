function[isLockTypeValid,minValue,maxValue]=outputRangeInfo(hblk,outportNumber)





    minValue=[];
    maxValue=[];
    isLockTypeValid=false;

    if(~isempty(hblk))
        try
            blkObj=get_param(hblk,'Object');
            isCompiledTypeValid=false;
            isCompiledTypeFloat=false;

            lockedDtString=getLockedDataTypeString(blkObj,outportNumber);
            [minValue,maxValue,isLockTypeValid,isLockTypeFloat]=getDataTypeRange(lockedDtString,blkObj);
            if(isLockTypeValid)
                [compiledString,isScaledDouble]=getCompiledDataString(hblk,outportNumber);

                if(~isScaledDouble)
                    [compiledMin,compiledMax,isCompiledTypeValid,isCompiledTypeFloat]=getDataTypeRange(compiledString,blkObj);



                    if(isLockTypeValid&&isCompiledTypeValid)
                        minValue=getMinValue(minValue,compiledMin,isLockTypeFloat);
                        maxValue=getMaxValue(maxValue,compiledMax,isLockTypeFloat);
                    end
                end

                if(((~isCompiledTypeValid&&isLockTypeFloat)||(isLockTypeFloat&&isCompiledTypeFloat)))
                    minValue=[];
                    maxValue=[];
                    isLockTypeValid=false;
                end
            end
        catch e %#ok<NASGU>
            validRange=false;%#ok<NASGU>
        end
    end
end

function[lockedDtString]=getLockedDataTypeString(blkObj,outportNumber)

    eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
    blkAutoscaler=eai.getAutoscaler(blkObj);

    pathItem=blkAutoscaler.getPortMapping(blkObj,[],outportNumber);
    DTConInfo=blkAutoscaler.gatherSpecifiedDT(blkObj,pathItem{1});
    lockedDtString=DTConInfo.evaluatedDTString;
end

function[compiledDataStr,isScaledDouble]=getCompiledDataString(hblk,outportNumber)

    compiledDataStr='';
    isScaledDouble=false;

    compiledDataType=get_param(hblk,'CompiledPortDataTypes');
    if(~((isempty(compiledDataType))||(isempty(compiledDataType.Outport))))
        compiledDataStr=compiledDataType.Outport{outportNumber};
        if strncmp(compiledDataStr,'flt',3)
            isScaledDouble=true;
        end
    end

end

function[min,max,validRange,isFloat]=getDataTypeRange(dtString,blkObj)

    validRange=false;
    isFloat=false;

    DataTypeInfo=SimulinkFixedPoint.DTContainerInfo(dtString,blkObj);
    min=DataTypeInfo.min;
    max=DataTypeInfo.max;


    if(~(isempty(min)||isempty(max)))
        validRange=true;
        if(DataTypeInfo.isAlias)
            isFloat=DataTypeInfo.aliasDTContainerObj.isFloat;
        else
            isFloat=DataTypeInfo.isFloat;
        end
    end


end

function[rMinValue]=getMinValue(minValue,minValue1,isLockTypeFloat)

    if(minValue<minValue1)
        rMinValue=minValue1;
    elseif(isLockTypeFloat)
        rMinValue=-Inf;
    else
        rMinValue=minValue;
    end
end

function[rMaxValue]=getMaxValue(maxValue,maxValue1,isLockTypeFloat)

    if(maxValue>maxValue1)
        rMaxValue=maxValue1;
    elseif(isLockTypeFloat)
        rMaxValue=Inf;
    else
        rMaxValue=maxValue;
    end
end
