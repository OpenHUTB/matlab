function[outData]=dspFIRRCHDLBlockTransform(inData)






    newInstanceData=inData.InstanceData;







    reqPortIdx=findParameterIndex(newInstanceData,'RequestPort');
    if~isempty(reqPortIdx)
        reqPort=strcmpi(newInstanceData(reqPortIdx).Value,'on');
    else
        reqPort=false;
    end

    if reqPort
        outData.NewBlockPath='dsphdlobslib/FIR Rate Converter';

        subsys_err=DAStudio.message('dsphdl:FIRRateConverter:ObsLibFIRRateConverterDeprecated',gcb);
        warning('dsphdl:FIRRateConverter:ObsLibFIRRateConverterDeprecated',subsys_err);
    else
        outData.NewBlockPath='dsphdlfiltering2/FIR Rate Converter';
    end

    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMax');
    newInstanceData=removeObsoleteParameter(newInstanceData,'CoefficientsMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMin');
    newInstanceData=removeObsoleteParameter(newInstanceData,'OutputMax');
    newInstanceData=removeObsoleteParameter(newInstanceData,'RequestPort');



    outData.NewInstanceData=newInstanceData;

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
function newInstanceData=removeObsoleteParameter(newInstanceData,parameterName)
    for index=1:length(newInstanceData)
        if strcmp(newInstanceData(index).Name,parameterName)

            newInstanceData=[newInstanceData(1:index-1),newInstanceData(index+1:end)];
            break;
        end
    end
end
