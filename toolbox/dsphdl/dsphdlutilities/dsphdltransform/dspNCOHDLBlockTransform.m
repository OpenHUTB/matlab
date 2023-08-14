function[outData]=dspNCOHDLBlockTransform(inData)






    newInstanceData=inData.InstanceData;



    newInstanceData=removeObsoleteParameter(newInstanceData,'ValidInputPort');


    outData.NewInstanceData=newInstanceData;
    outData.NewBlockPath=inData.ForwardingTableEntry.('__slOldName__');

end


function newInstanceData=removeObsoleteParameter(newInstanceData,parameterName)
    for index=1:length(newInstanceData)
        if strcmp(newInstanceData(index).Name,parameterName)

            if(strcmp(newInstanceData(index).Value,'off'))
                subsys_err=DAStudio.message('dsp:HDLNCO:ValidInMandatory',gcb);
                warning('dsp:HDLNCO:ValidInMandatory',subsys_err);
            end
            newInstanceData=[newInstanceData(1:index-1),newInstanceData(index+1:end)];

            break;
        end
    end
end

