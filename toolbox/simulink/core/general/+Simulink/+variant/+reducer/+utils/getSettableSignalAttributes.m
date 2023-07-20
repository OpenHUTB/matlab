function modAttrStruct=getSettableSignalAttributes(attrStruct)





















    if contains(attrStruct.CompiledBusType,'NOT_BUS')
        dtStr=attrStruct.CompiledPortAliasedThruDataType;
        if~isempty(dtStr)
            if sl('sldtype_is_builtin',dtStr)
                modAttrStruct.OutDataTypeStr=dtStr;
            elseif sldvshareprivate('util_is_enum_type',dtStr)
                modAttrStruct.OutDataTypeStr=['Enum: ',dtStr];
            elseif sldvshareprivate('util_is_fxp_type',dtStr)
                modAttrStruct.OutDataTypeStr=sprintf('fixdt(''%s'')',dtStr);
            else
            end
        end
    end


    modAttrStruct.OutMax=i_num2str(attrStruct.CompiledPortDesignMax);


    modAttrStruct.OutMin=i_num2str(attrStruct.CompiledPortDesignMin);


    if~strcmp(attrStruct.CompiledBusType,'BUS')
        if~isempty(attrStruct.CompiledPortSymbolicDimensions)&&...
            contains(attrStruct.CompiledPortSymbolicDimensions,{'INHERIT','NOSYMBOLIC'})
            modAttrStruct.Dimensions=i_getDimensionsStr(attrStruct.CompiledPortDimensions);
        else

            modAttrStruct.Dimensions=attrStruct.CompiledPortSymbolicDimensions;
        end
    end


    modAttrStruct.SampleTime=Simulink.variant.reducer.utils.getSampleTimeStr(attrStruct.CompiledPortSampleTime);


    modAttrStruct.SignalType=i_getComplexityStr(attrStruct.CompiledPortComplexSignal);


    if strcmp(attrStruct.CompiledBusType,'NOT_BUS')
        modAttrStruct.SamplingMode=i_getFrameDataStr(attrStruct.CompiledPortFrameData);
    end


    modAttrStruct.Unit=Simulink.variant.utils.i_cell2mat(attrStruct.CompiledPortUnits);


    modAttrStruct.DimensionsMode=i_getDimensionsMode(attrStruct.CompiledPortDimensionsMode);




end

function dimsStr=i_getDimensionsStr(compDims)
    if isempty(compDims)
        dimsStr='';
        return;
    end
    if(compDims(1)>=2)
        nDims=compDims(1);
        dimsStr='';
        spcVal='';
        for k=1:nDims
            if k>1
                spcVal=' ';
            end
            dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
        end
        dimsStr=['[',dimsStr,']'];
    else
        dimsStr=sprintf('%d',compDims(2));
    end

end

function Complexity=i_getComplexityStr(compComplex)
    Complexity='';
    if compComplex==0
        Complexity='real';
    elseif compComplex==1
        Complexity='complex';
    end
end

function SamplingMode=i_getFrameDataStr(compFrame)
    SamplingMode='';
    if compFrame==0
        SamplingMode='Sample based';
    elseif compFrame==1
        SamplingMode='Frame based';
    end
end

function DimensionsMode=i_getDimensionsMode(compDimsMode)
    DimensionsMode='';
    if compDimsMode==0
        DimensionsMode='Fixed';
    elseif compDimsMode==1
        DimensionsMode='Variable';
    end
end


function str=i_num2str(str)
    if isnumeric(str)||islogical(str)
        str=num2str(str);
    end
end


