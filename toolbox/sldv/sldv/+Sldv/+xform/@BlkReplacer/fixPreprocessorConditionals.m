function fixPreprocessorConditionals(obj,mdlRefItem)%#ok<INUSL>




    parentSubsystem=get_param(mdlRefItem.ReplacementInfo.AfterReplacementH,'Parent');
    while~isempty(parentSubsystem)&&~isempty(get_param(parentSubsystem,'Parent'))
        variantControl=get_param(parentSubsystem,'VariantControl');
        if~isempty(variantControl)


            grandParent=get_param(parentSubsystem,'Parent');
            grandParentHandle=get_param(grandParent,'Handle');
            propValStruct=get(grandParentHandle);
            if isfield(propValStruct,'ActiveVariant')
                parentvariantObj=propValStruct.ActiveVariant;
            else
                parentvariantObj='';
            end

            if~isempty(parentvariantObj)&&...
                strcmp(parentvariantObj,variantControl)
                set_param(get_param(parentSubsystem,'Parent'),'GeneratePreprocessorConditionals','off');
                break;
            end
        end
        parentSubsystem=get_param(parentSubsystem,'Parent');
    end
end
