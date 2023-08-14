function[outData]=dspFIRHDLBlockTransform(inData)






    newInstanceData=inData.InstanceData;



    newInstanceData=removeObsoleteParameter(newInstanceData,'ReadyPort');
    newInstanceData=removeObsoleteParameter(newInstanceData,'ValidInputPort');
    index1=findParameterIndex(newInstanceData,'Sharing');
    index2=findParameterIndex(newInstanceData,'SharingFactor');
    if~isempty(index1)
        if strcmpi(newInstanceData(index1).Value,'on')
            SharingFactor=newInstanceData(index2).Value;
            newIndex1=findParameterIndex(newInstanceData,'FilterStructure');
            newIndex2=findParameterIndex(newInstanceData,'NumCycles');
            if~isempty(newIndex1)
                newInstanceData(newIndex1).Value='Partly serial systolic';
            else
                newInstanceData(end+1).Name='FilterStructure';
                newInstanceData(end).Value='Partly serial systolic';
            end
            if~isempty(newIndex2)
                newInstanceData(newIndex2).Value=SharingFactor;
            else
                newInstanceData(end+1).Name='NumCycles';
                newInstanceData(end).Value=SharingFactor;
            end
        end
    end
    index1=findParameterIndex(newInstanceData,'SerializationOption');
    index2=findParameterIndex(newInstanceData,'SerializationFactor');
    if~isempty(index1)
        if strcmpi(newInstanceData(index1).Value,'Minimum number of cycles between valid input samples')
            if~isempty(index2)
                newInstanceData(index2).Name='NumCycles';
            end
        else
            if~isempty(index2)
                newInstanceData(index2).Name='NumberOfMultipliers';
            end
        end
    end



    index_fs=findParameterIndex(newInstanceData,'FilterStructure');
    if~isempty(index_fs)
        val_fs=newInstanceData(index_fs).Value;
        if strcmpi(val_fs,'partly serial systolic')
            warning(message('dsphdl:FIRFilter:InitializeRAMForSerialFIR'));
        end
    end

    newInstanceData=removeObsoleteParameter(newInstanceData,'Sharing');
    newInstanceData=removeObsoleteParameter(newInstanceData,'SharingFactor');
    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMax');
    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMax');


    outData.NewInstanceData=newInstanceData;


    oldProperty='NumberOfCycles';
    newProperty='NumCycles';
    numCyclesIndex=findParameterIndex(outData.NewInstanceData,oldProperty);
    if~isempty(numCyclesIndex)

        outData.NewInstanceData(numCyclesIndex).Name=newProperty;
    end

    outData.NewBlockPath=inData.ForwardingTableEntry.('__slOldName__');

end


function newInstanceData=removeObsoleteParameter(newInstanceData,parameterName)
    for index=1:length(newInstanceData)
        if strcmp(newInstanceData(index).Name,parameterName)

            newInstanceData=[newInstanceData(1:index-1),newInstanceData(index+1:end)];
            break;
        end
    end
end
function index=findParameterIndex(newInstanceData,oldProperty)
    index=[];
    for loop=1:length(newInstanceData)
        if strcmp(newInstanceData(loop).Name,oldProperty)
            index=loop;
            break;
        end
    end
end
