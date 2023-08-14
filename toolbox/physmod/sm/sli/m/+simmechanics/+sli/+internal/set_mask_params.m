function set_mask_params(hBlock,paramValuePairs)







    editorDomain=[];
    editor=[];
    if slfeature('SelectiveParamUndoRedo')>0
        try
            ownerSys=get_param(hBlock,'Parent');
            editors=GLUE2.Util.findAllEditors(ownerSys);
            if~isempty(editors)

                numEditors=length(editors);
                for i=1:numEditors
                    editor=editors(i);
                    if editor.isVisible
                        editorDomain=editors.getStudio.getActiveDomain();
                        break;
                    end
                end
            end
        catch
            editorDomain=[];
        end
    end

    if iscell(paramValuePairs)&&all(cellfun(@ischar,paramValuePairs))
        paramValuePairsWithChanges={};
        numElems=length(paramValuePairs);
        for elemIdx=1:2:numElems
            paramName=paramValuePairs{elemIdx};
            oldParamValue=get_param(hBlock,paramName);
            newParamValue=paramValuePairs{elemIdx+1};
            if~isequal(oldParamValue,newParamValue)
                paramValuePairsWithChanges{end+1}=paramName;%#ok
                paramValuePairsWithChanges{end+1}=newParamValue;%#ok
            end
        end

        noop=isempty(paramValuePairsWithChanges);
        if~noop
            if isempty(editorDomain)

                set_mask_params_impl(hBlock,paramValuePairsWithChanges,[]);
            else

                editorDomain.createParamChangesCommand(...
                editor,...
                'Simulink:studio:ParameterChanges',...
                DAStudio.message('Simulink:studio:ParameterChanges'),...
                @set_mask_params_impl,...
                {hBlock,paramValuePairsWithChanges,editorDomain},...
                false,...
                true,...
                false,...
                false,...
                true);
            end
        end
        return;
    end

    msg=pm_message('sm:sli:setmaskparam:InvalidNameValuePairCell');
    stage='Setting Parameters';
    simmechanics.sli.internal.error_in_diagnostic_viewer(hBlock,stage,msg);
end

function[success,noop]=set_mask_params_impl(hBlock,paramValuePairs,editorDomain)
    success=false;
    noop=false;
    stage='Setting Parameters';
    try
        if~isempty(editorDomain)
            editorDomain.paramChangesCommandAddObject(hBlock);
        end
        set_param(hBlock,paramValuePairs{:});
        success=true;
    catch excp
        simmechanics.sli.internal.error_in_diagnostic_viewer(hBlock,stage,excp);
    end
    return;
end

