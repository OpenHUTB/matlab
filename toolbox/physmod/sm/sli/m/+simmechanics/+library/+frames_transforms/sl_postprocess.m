function outData=sl_postprocess(inData)


    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;
    classNameParam=simmechanics.library.helper.get_class_name_param('dummy');
    cnIdx=strcmpi(ParameterNames,classNameParam.VarName);

    outData.NewBlockPath='';
    outData.NewInstanceData=inData.InstanceData;



    if any(cnIdx)&&strcmpi(inData.InstanceData(cnIdx).Value,...
        pm_message('mech2:transformSensor:TypeId'))



        paramIds={'rotation:quaternion',...
        'angularAcceleration:alphaZ',...
        'translation:x'};

        for pIdx=1:length(paramIds)
            idx=strcmpi(ParameterNames,pm_message(tsFullId(paramIds{pIdx})));
            if any(idx)&&strcmpi(outData.NewInstanceData(idx).Value,'world')
                outData.NewInstanceData(idx).Value='off';
            end
        end
    end



    outData=simmechanics.library.sl_postprocess(outData);



end

function fullMsgId=tsFullId(msgId)
    fullMsgId=['mech2:transformSensor:parameters:',msgId,':ParamName'];
end
