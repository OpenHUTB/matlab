function[outData]=dspCICDecimHDLBlockTransform(inData)




    outData.NewInstanceData=inData.InstanceData;
    outData.NewBlockPath='dsphdlfiltering2/CIC Decimator';




    oldProperty='VariableDownsample';
    newProperty='DecimationSource';
    vardsIndex=findParameterIndex(outData.NewInstanceData,oldProperty);
    if~isempty(vardsIndex)
        if strcmpi(inData.InstanceData(vardsIndex).Value,'on')
            decimSource='Input port';
        else
            decimSource='Property';
        end


        outData.NewInstanceData=[outData.NewInstanceData(1:vardsIndex-1),outData.NewInstanceData(vardsIndex+1:end)];

        outData.NewInstanceData(end+1)=struct('Name',newProperty,...
        'Value',decimSource);


        if strcmpi(decimSource,'Input port')
            dfIndex=findParameterIndex(outData.NewInstanceData,'DecimationFactor');
            dfValue=outData.NewInstanceData(dfIndex).Value;
            outData.NewInstanceData(end+1)=struct('Name','MaxDecimationFactor',...
            'Value',dfValue);
        end
    end




    oldProperty1='ResetIn';
    newProperty1='ResetInputPort';
    resetIndex=findParameterIndex(outData.NewInstanceData,oldProperty1);
    if~isempty(resetIndex)

        outData.NewInstanceData(resetIndex).Name=newProperty1;
    end

end

function index=findParameterIndex(instanceData,property)


    index=[];
    for loop=1:length(instanceData)
        if strcmp(instanceData(loop).Name,property)
            index=loop;
            break;
        end
    end
end
