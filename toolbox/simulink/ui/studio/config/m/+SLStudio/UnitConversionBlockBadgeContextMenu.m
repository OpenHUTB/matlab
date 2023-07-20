classdef UnitConversionBlockBadgeContextMenu %#ok<*MCDIR>






    methods(Static)

        function schema=InsertBlock(cbinfo)

            schema=sl_action_schema;
            schema.tag='Simulink:InsertUnitConversionBlock';
            schema.label=DAStudio.message('Simulink:studio:InsertUnitConversionBlock');
            schema.state='Enabled';
            target=SLStudio.Utils.getOneMenuTarget(cbinfo);
            if SLStudio.Utils.objectIsValidPort(target)&&...
                (strcmpi(target.type,'In Port')||...
                strcmpi(target.type,'Out Port'))
                schema.userdata.portH=target.handle;
            end
            schema.callback=@SLStudio.UnitConversionBlockBadgeContextMenu.callBackInsertBlock;
        end
    end



    methods(Static,Hidden)

        function callBackInsertBlock(cbinfo)
            portH=cbinfo.userdata.portH;
            obj=get_param(portH,'Object');
            obj.insertUnitConversionBlockOnPort(portH);
        end
    end
end


