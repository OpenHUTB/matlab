function setBlockParamsWithUndo(hBlock,varargin)




    editorDomain=[];
    editor=[];
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

    paramValuePairs=varargin;

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

                set_params_impl(hBlock,paramValuePairsWithChanges,[]);
            else

                editorDomain.createParamChangesCommand(...
                editor,...
                'Simulink:studio:ParameterChanges',...
                DAStudio.message('Simulink:studio:ParameterChanges'),...
                @set_params_impl,...
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




end

function[success,noop]=set_params_impl(hBlock,paramValuePairs,editorDomain)
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
        if(strcmpi(get_param(get_param(hBlock,'Parent'),'SimulinkSubDomain'),'Architecture')||...
            strcmpi(get_param(get_param(hBlock,'Parent'),'SimulinkSubDomain'),'SoftwareArchitecture'))
            editor=SLM3I.SLDomain.getLastActiveEditor();
            editor.deliverWarnNotification(excp.identifier,excp.message)
        end

    end
    return;
end


