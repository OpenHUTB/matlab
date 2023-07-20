

function[valid,errorText]=onInputFieldChange(this,row)
    valid=false;
    errorText='';

    bindableTypeEnum=BindMode.BindableTypeEnum.getEnumTypeFromChar(row.bindableTypeChar);
    if bindableTypeEnum~=BindMode.BindableTypeEnum.SLPARAMETER&&...
        bindableTypeEnum~=BindMode.BindableTypeEnum.VARIABLE
        return;
    end

    targetHandle=get_param(row.bindableMetaData.blockPathStr,'Handle');
    paramOrVarName=row.bindableMetaData.name;
    varWorkspaceType='';
    if(bindableTypeEnum==BindMode.BindableTypeEnum.VARIABLE)
        varWorkspaceType=row.bindableMetaData.workspaceType.sourceName;
    end
    element=row.bindableMetaData.inputValue;
    try
        valid=utils.HMIBindMode.bindParameter(this.sourceElementHandle,targetHandle,paramOrVarName,varWorkspaceType,element);
    catch e


        errorText=e.message;
    end


    if valid
        SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:ConnectedFeedbackMessage')," "+row.bindableName+" ");
    end
end