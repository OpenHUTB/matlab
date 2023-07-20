classdef PropActionResetToDefault<Simulink.ModelReference.internal.PropAction




    methods(Static=true)
        function action=build(blkPath,argName,argValue,isFromDialog)



            action=[];
            mdl_name=Simulink.ModelReference.internal.PropAction.getModelName(blkPath);
            if isempty(mdl_name)
                return;
            end

            if isFromDialog
                isFromDlgStr='true';
            else
                isFromDlgStr='false';
            end

            action.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Reset');
            action.command=[...
'slprivate(''Simulink.cosimblock.internal.PropActionResetToDefault.run'', '''...
            ,mdl_name,''', ''',blkPath,''', '''...
            ,argName,''', ''',isFromDlgStr,''');'];

            if~isempty(argValue)
                action.enabled=true;
            else
                action.enabled=false;
            end

            action.visible=true;
        end

        function run(~,blk_path,argName,isFromDialogStr)


            if isequal(isFromDialogStr,'true')
                blkHdl=get_param(blk_path,'Handle');
                blkObj=get(blkHdl,'Object');

                ssTag='cosim_ArgumentSpreadsheet';
                dlgSrc=blkObj.getDialogSource;
                openDlgs=DAStudio.ToolRoot.getOpenDialogs(dlgSrc);
                for i=1:length(openDlgs)
                    dlg=openDlgs(i);


                    src=dlg.getWidgetSource(ssTag);
                    found=src.findAndUpdateChild(argName,'Value','');
                    assert(isequal(found,true));


                    inf=dlg.getWidgetInterface(ssTag);
                    inf.update;
                end
            else
                instParams=get_param(blk_path,'InstanceParameters');



                instParamsInfo=get_param(blk_path,'InstanceParametersInfo');
                for idx=1:numel(instParams)
                    if isequal(instParamsInfo(idx).SIDPath,argName)
                        instParams(idx).Value='';
                        break;
                    end
                end

                set_param(blk_path,'InstanceParameters',instParams);
            end
        end
    end
end