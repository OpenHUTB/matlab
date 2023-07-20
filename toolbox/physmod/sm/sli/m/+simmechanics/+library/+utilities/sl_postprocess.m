function outData=sl_postprocess(inData)


    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;
    classNameParam=simmechanics.library.helper.get_class_name_param('dummy');
    cnIdx=strcmpi(ParameterNames,classNameParam.VarName);

    outData.NewBlockPath='';
    outData.NewInstanceData=inData.InstanceData;



    if any(cnIdx)&&strcmpi(inData.InstanceData(cnIdx).Value,...
        pm_message('sm:model:blockNames:mechanismConfiguration:TypeId'))




        idx=strcmpi(ParameterNames,'AllowGravitySignal');
        if any(idx)
            outData.NewInstanceData(idx)=[];
        end

    end



    outData=simmechanics.library.sl_postprocess(outData);



end
