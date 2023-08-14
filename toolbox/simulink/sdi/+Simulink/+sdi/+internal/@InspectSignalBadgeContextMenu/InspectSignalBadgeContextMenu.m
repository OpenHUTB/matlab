classdef InspectSignalBadgeContextMenu %#ok<*MCDIR>






    methods(Static)


        function schema=SDISignalSettings(cbinfo)

            import Simulink.sdi.internal.SignalObserverMenu;
            schema=sl_action_schema;
            schema.tag='Simulink:SDISignalSettings';
            schema.label=DAStudio.message('Simulink:studio:SDISignalSettings');
            schema.state='Enabled';
            schema.userdata.mdl=SignalObserverMenu.getModelName(cbinfo);
            schema.userdata.portH=...
            SignalObserverMenu.locGetValidSrcPortHandles(cbinfo);
            schema.callback=@Simulink.sdi.internal.sigSettingsDlg.openDialog;
            schema.autoDisableWhen='Busy';
        end


        function schema=HighlightInSDI(cbinfo)

            import Simulink.sdi.internal.SignalObserverMenu;
            import Simulink.sdi.internal.InspectSignalBadgeContextMenu;
            schema=sl_action_schema;
            schema.tag='Simulink:HighlightInSDI';
            schema.label=DAStudio.message('Simulink:studio:HighlightInSDI');
            schema.state='Enabled';
            schema.userdata.portH=...
            SignalObserverMenu.locGetValidSrcPortHandles(cbinfo);
            schema.callback=@InspectSignalBadgeContextMenu.locHighlightSignalInSDI;
            schema.autoDisableWhen='Never';
        end


        function fullPath=getFullPathForPort(hPort)


            hBlk=get_param(get_param(hPort,'parent'),'Handle');


            blk=get_param(hBlk,'Object');
            fullPath=Simulink.SimulationData.BlockPath(blk.getFullName());


            hSubSys=get_param(get_param(hBlk,'parent'),'Handle');
            ed=SLM3I.SLDomain.getLastActiveEditorFor(hSubSys);
            if~isempty(ed)
                parentHID=ed.getHierarchyId;
                fullPath=Simulink.BlockPath.fromHierarchyIdAndHandle(parentHID,hBlk);
            end


            fullPath=convertToCell(fullPath);
        end

    end


    methods(Static,Hidden)


        function locHighlightSignalInSDI(cbinfo)


            portH=cbinfo.userdata.portH;
            portIdx=get(portH,'PortNumber');
            bPath=Simulink.sdi.internal.InspectSignalBadgeContextMenu.getFullPathForPort(portH);
            Simulink.sdi.highlightSignalFromLatestRunInSDI(bPath,portIdx)
        end

    end
end

