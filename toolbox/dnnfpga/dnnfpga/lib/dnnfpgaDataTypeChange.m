function dataTypeOut=dnnfpgaDataTypeChange(dataType,signalSpec)

    if(strcmp(dataType,'single'))
        if(signalSpec==1)
            dataTypeOut='uint32';
        elseif(signalSpec==2)
            dataTypeOut=dataType;
        else
            dataTypeOut=dataType;
        end
    elseif(strcmp(dataType,'half'))
        if(signalSpec==1)
            dataTypeOut='uint16';
        elseif(signalSpec==2)
            dataTypeOut=dataType;
        else
            dataTypeOut='single';
        end
    else
        if(signalSpec==1)
            dataTypeOut='uint32';
        elseif(signalSpec==2)
            dataTypeOut='uint8';
        else
            dataTypeOut='int32';
        end

    end
end