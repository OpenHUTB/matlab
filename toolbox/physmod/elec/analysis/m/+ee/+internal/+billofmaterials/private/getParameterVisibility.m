function parameterVisibility=getParameterVisibility(blockHandle)











    componentSchema=physmod.schema.internal.blockComponentSchema(blockHandle);



    controlData=lControlData(componentSchema,blockHandle);


    info=componentSchema.info();
    parameterNames={info.Members.Parameters.ID,info.Members.Variables.ID};



    visibilityIdx=simscape.schema.internal.visible(parameterNames,componentSchema,controlData);


    parameterVisibility=cell2struct(num2cell(visibilityIdx),parameterNames,2);

end

function controlData=lControlData(componentSchema,blockHandle)
    controlData=componentSchema.defaultControls();
    maskWorkspaceVariables=get_param(blockHandle,'MaskWSVariables');
    valuesStruct=cell2struct({maskWorkspaceVariables.Value},{maskWorkspaceVariables.Name},2);
    for controlDataIdx=1:numel(controlData)
        if~ischar(valuesStruct.(controlData(controlDataIdx).ID))
            controlData(controlDataIdx).Value=simscape.Value(...
            valuesStruct.(controlData(controlDataIdx).ID),...
            valuesStruct.([controlData(controlDataIdx).ID,'_unit']));
        else

            enumValue=str2num(valuesStruct.(controlData(controlDataIdx).ID));%#ok<ST2NM>
            if isenum(enumValue)

                controlData(controlDataIdx).Value=simscape.Value(...
                enumValue,...
                valuesStruct.([controlData(controlDataIdx).ID,'_unit']));
            else

                controlData(controlDataIdx).Value=simscape.Value(NaN,'1');
            end
        end
    end
end
