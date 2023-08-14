classdef PropActionCreateVarFromDefault<Simulink.ModelReference.internal.PropAction




    methods(Static=true)
        function action=build(blkPath,argName,argValue,isFromDialog)



            action=[];



            return;

            mdl_name=Simulink.ModelReference.internal.PropAction.getModelName(blkPath);
            if isempty(mdl_name)
                return;
            end

            if isFromDialog
                isFromDlgStr='true';
            else
                isFromDlgStr='false';
            end

            action.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Create_From_Expression');
            action.command=[...
'slprivate(''Simulink.ModelReference.internal.PropActionCreateVarFromDefault.run'', '''...
            ,mdl_name,''', ''',blkPath,''', '''...
            ,argName,''', ''',isFromDlgStr,''');'];


            if isempty(argValue)
                action.enabled=true;
                action.visible=true;
            else
                action.enabled=false;
                action.visible=false;
            end
        end

        function run(mdlName,blkPath,argName,~)

            info=slInternal('getInstanceParameterCachedInfo',blkPath,argName);

            slprivate('createWorkspaceVar',info.DefaultValue,mdlName,...
            'ModelArgument',blkPath,argName);
        end
    end
end
