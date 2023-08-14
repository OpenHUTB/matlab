classdef ParameterDefinitionBuilder




    methods(Static=true)
        function action=Create(blkPath,argName,argValue,fromDialog)
            action=[];
            action.label=DAStudio.message('Simulink:dialog:CreateParameterDefinition');
            mdl_name=Simulink.ModelReference.internal.PropAction.getModelName(blkPath);
            action.command=['slprivate(''createWorkspaceVar'', '''...
            ,argValue,''',''',mdl_name,''',''','Parameter',''',''',blkPath,''',''','',''',''','true',''');'];

            action.enabled=true;
            action.visible=true;
        end
    end
end

