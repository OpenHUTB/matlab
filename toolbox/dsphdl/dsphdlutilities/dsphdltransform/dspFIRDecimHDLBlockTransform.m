function[outData]=dspFIRDecimHDLBlockTransform(inData)







    newInstanceData=inData.InstanceData;



    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMax');
    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMax');


    outData.NewInstanceData=newInstanceData;
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
