classdef HiddenRateTransBlkBadgeContextMenu %#ok<*MCDIR>






    methods(Static)

        function schema=InsertedRTBlock(cbinfo)

            schema=sl_action_schema;
            schema.tag='Simulink:InsertHiddenRTB';
            schema.label=DAStudio.message('Simulink:studio:InsertHiddenRTB');
            schema.state='Enabled';
            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidPort(target)&&...
                (strcmpi(target.type,'In Port')||...
                strcmpi(target.type,'Out Port'))
                schema.userdata.portH=target.handle;
            end
            schema.callback=@SLStudio.HiddenRateTransBlkBadgeContextMenu.callBackInsertRTB;
        end

        function schema=InsertedRTBlockHelp(~)

            schema=sl_action_schema;
            schema.tag='Simulink:HelpMenu';
            schema.label=DAStudio.message('Simulink:studio:HelpMenu');
            schema.callback=@SLStudio.HiddenRateTransBlkBadgeContextMenu.callBackHelpview;
        end

    end



    methods(Static,Hidden)


        function callBackInsertRTB(cbinfo)
            portH=cbinfo.userdata.portH;
            obj=get_param(portH,'Object');
            obj.insertRateTransBlockOnPort(obj);
        end

        function callBackHelpview(~)
            helpview(fullfile(docroot,'mapfiles','simulink.map'),'ratetransition_badge_help');
        end

    end
end


