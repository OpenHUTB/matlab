function outData=sl_postprocess(inData)


    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;
    classNameParam=simmechanics.library.helper.get_class_name_param('dummy');
    cnIdx=strcmpi(ParameterNames,classNameParam.VarName);

    outData.NewBlockPath='';
    outData.NewInstanceData=inData.InstanceData;



    if any(cnIdx)
        typeid=inData.InstanceData(cnIdx).Value;
        if strcmpi(typeid,pm_message('sm:model:blockNames:commonGearConstraint:TypeId'))||...
            strcmpi(typeid,pm_message('sm:model:blockNames:bevelGearConstraint:TypeId'))||...
            strcmpi(typeid,pm_message('sm:model:blockNames:rackAndPinionConstraint:TypeId'))



            idx=strcmpi(ParameterNames,'WrenchFrame');
            if any(idx)
                old_val=outData.NewInstanceData(idx).Value;
                if strcmpi(old_val,'Base')||strcmpi(old_val,'Follower')
                    outData.NewInstanceData(idx).Value=[old_val,'Frame'];
                end
            end
        end
    end



    outData=simmechanics.library.sl_postprocess(outData);



end
