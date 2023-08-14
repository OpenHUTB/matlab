classdef CFcnDDGWidget<handle




    methods(Static)
        function togglePanel=getWidgetStruct(hDlgSrc,isLink)


            import SLCC.blocks.ui.PortSpec.*;
            try



                hiddenText.Type='text';
                hiddenText.Name='';
                hiddenText.MinimumSize=[50,1];


                ssWidget.Type='spreadsheet';
                colNames={DAStudio.message('Simulink:CustomCode:PortSpec_ArgName'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Scope'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Label'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Type'),...
                DAStudio.message('Simulink:CustomCode:CSPortSpec_Size'),...
                DAStudio.message('Simulink:CustomCode:PortSpec_Index')};
                ssWidget.Columns=colNames;
                ssWidget.Tag='csb_portSpec_spreadsheet_tag';
                ssWidget.RowSpan=[2,6];
                ssWidget.ColSpan=[1,70];
                ssWidget.ItemClickedCallback=@(tag,item,name,dlg)ssWidgetClickCallBack(tag,item,name,dlg);
                ssWidget.SelectionChangedCallback=@(tag,sels,hDlgSrc)ssWidgetSelectionChanged(tag,sels,hDlgSrc);

                hBlock=get(hDlgSrc.getBlock,'Handle');
                hPortSpec=get_param(hBlock,'PortSpecificationCScriptUI');
                hSS=hPortSpec.getSSSource();
                hSS.setDialogSrc(hDlgSrc);
                hSS.updateSpreadsheet();

                ssWidget.Source=hSS;

                pushbuttonAdd.Type='pushbutton';
                pushbuttonAdd.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogAddButtonName');
                pushbuttonAdd.Tag='pushbuttonTagAdd';
                pushbuttonAdd.RowSpan=[1,1];
                pushbuttonAdd.ColSpan=[1,12];
                pushbuttonAdd.MatlabMethod='SLCC.blocks.ui.PortSpec.addDataButton';
                pushbuttonAdd.MatlabArgs={'%dialog','%source',ssWidget.Tag};

                pushbuttonRemove.Type='pushbutton';
                pushbuttonRemove.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogDeleteButtonName');
                pushbuttonRemove.Tag='pushbuttonTagRemove';
                pushbuttonRemove.RowSpan=[1,1];
                pushbuttonRemove.ColSpan=[14,33];
                pushbuttonRemove.MatlabMethod='SLCC.blocks.ui.PortSpec.removeDataButton';
                pushbuttonRemove.MatlabArgs={'%dialog','%source',ssWidget.Tag};
                pushbuttonRemove.Enabled=false;
                if aRowIsSelected(hDlgSrc,ssWidget.Tag)
                    pushbuttonRemove.Enabled=true;
                end


                togglePanel.Type='togglepanel';
                togglePanel.Name=DAStudio.message('Simulink:CustomCode:CFunctionPortSpec_Prompt');
                togglePanel.Expand=true;
                togglePanel.Tag='csb_portSpec_container_tag';
                togglePanel.LayoutGrid=[6,70];
                togglePanel.RowStretch=[1,1,1,1,1,1];
                togglePanel.ColStretch=ones(1,70);
                togglePanel.ColStretch([1:33])=0;
                togglePanel.Items={ssWidget,pushbuttonAdd,pushbuttonRemove,hiddenText};
            catch e
                warning(e.message);
                togglePanel.Type='text';
                togglePanel.Name=DAStudio.message('Simulink:CustomCode:CFunctionPortSpec_Prompt');
            end
        end
    end

end

function ssWidgetClickCallBack(tag,~,~,dlg)
    ss=dlg.getWidgetInterface(tag);
    dlg.setEnabled('pushbuttonTagRemove',~isempty(ss.getSelection));
end

function ret=ssWidgetSelectionChanged(tag,sels,dlg)
    if(numel(sels)>0)
        dlg.setEnabled('pushbuttonTagRemove',true);
    else
        dlg.setEnabled('pushbuttonTagRemove',false);
    end
end

function ret=aRowIsSelected(dlgHandle,tag)
    ret=false;
    openDlg=dlgHandle.getOpenDialogs;
    if~isempty(openDlg)
        ss=openDlg{1}.getWidgetInterface(tag);
        if~isempty(ss.getSelection)
            ret=true;
        end
    end
end