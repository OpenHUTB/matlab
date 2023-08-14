classdef DDGWidget<handle





    properties
    end

    methods(Static)
        function togglePanel=getWidgetStruct(hDlgSrc,isLink)


            import SLCC.blocks.ui.PortSpec.*;
            try

                ssWidget.Type='spreadsheet';
                colNames={DAStudio.message('Simulink:CustomCode:PortSpec_ArgName'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Scope'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Label'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Type'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Size')};
                ssWidget.Columns=colNames;
                ssWidget.Tag='slcc_portSpec_spreadsheet_tag';
                ssWidget.MinimumSize=[500,1];
                ssWidget.RowSpan=[2,15];
                ssWidget.ColSpan=[1,2];
                ssWidget.DisableLastRowStretch=1;

                hBlock=get(hDlgSrc.getBlock,'Handle');
                hPortSpec=get_param(hBlock,'PortSpecification');
                hSS=hPortSpec.getSSSource();
                hSS.setDialogSrc(hDlgSrc)

                ssWidget.Source=hSS;



                togglePanel.Type='togglepanel';
                togglePanel.Name=DAStudio.message('Simulink:CustomCode:PortSpec_Prompt');
                togglePanel.Expand=isLink;
                togglePanel.Tag='slcc_portSpec_container_tag';
                togglePanel.LayoutGrid=[1,1];
                togglePanel.ColStretch=[1];
                togglePanel.Items={ssWidget};
            catch e
                warning(e.message);
                togglePanel.Type='text';
                togglePanel.Name=DAStudio.message('Simulink:CustomCode:PortSpec_Prompt');
            end
        end
    end

end

