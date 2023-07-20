classdef FaultTab<autosar.ui.bsw.Tab




    properties(Constant)
        tag='faultTag';
    end

    methods(Static)
        function text=getTab(h)
            tagPrefix=autosar.ui.bsw.FaultTab.tag;


            descriptionText.Type='text';
            descriptionText.Name=DAStudio.message('autosarstandard:ui:uiRTEDesc');
            descriptionText.ToolTip=DAStudio.message('autosarstandard:ui:uiRTEDescTip');
            descriptionText.WordWrap=true;
            descriptionText.Tag=[tagPrefix,'descriptionText'];
            descriptionText.ColSpan=[1,1];
            descriptionText.RowSpan=[1,1];

            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag=[tagPrefix,'spreadsheetfilterWidget'];
            filterWidget.PlaceholderText=DAStudio.message('autosarstandard:ui:uiRTEFilterText');
            filterWidget.Clearable=true;
            filterWidget.TargetSpreadsheet=[tagPrefix,'faultSpreadsheet'];
            filterWidget.RowSpan=[2,2];
            filterWidget.ColSpan=[1,1];

            topContainer.Type='panel';
            topContainer.Tag=[tagPrefix,'topContainer'];
            topContainer.LayoutGrid=[1,2];
            topContainer.ColSpan=[1,1];
            topContainer.RowSpan=[1,1];
            topContainer.Items={
descriptionText...
            ,filterWidget...
            };


            matrixSpreadsheet.Type='spreadsheet';
            matrixSpreadsheet.Columns={
            autosar.ui.bsw.FaultSpreadsheetRow.EventIdColumn
            autosar.ui.bsw.FaultSpreadsheetInnerRow.NameColumn
            autosar.ui.bsw.FaultSpreadsheetInnerRow.TypeColumn
            };
            matrixSpreadsheet.SortColumn=autosar.ui.bsw.FaultSpreadsheetRow.EventIdColumn;
            matrixSpreadsheet.SortOrder=true;
            matrixSpreadsheet.ColSpan=[1,19];
            matrixSpreadsheet.RowSpan=[1,20];
            matrixSpreadsheet.Enabled=true;
            matrixSpreadsheet.Source=autosar.ui.bsw.FaultSpreadsheet(h);
            matrixSpreadsheet.Tag=[tagPrefix,'faultSpreadsheet'];
            matrixSpreadsheet.Visible=true;
            matrixSpreadsheet.Hierarchical=true;
            matrixSpreadsheet.ItemClickedCallback=@autosar.ui.bsw.FaultSpreadsheet.onItemClicked;

            addButton.Type='pushbutton';
            addButton.Tag=[tagPrefix,'AddButton'];
            addButton.ColSpan=[20,20];
            addButton.RowSpan=[2,3];
            addButton.MatlabArgs={'%dialog'};
            addButton.ArgDataTypes={'handle'};
            addButton.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.addFault';
            addButton.ToolTip=DAStudio.message('autosarstandard:ui:uiFaultAddFaultTooltip');
            addButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','add_row.gif');
            addButton.Enabled=autosar.ui.bsw.FaultSpreadsheet.isAddButtonEnabled(h);

            removeButton.Type='pushbutton';
            removeButton.Tag=[tagPrefix,'RemoveButton'];
            removeButton.ColSpan=[20,20];
            removeButton.RowSpan=[4,5];
            removeButton.MatlabArgs={'%dialog'};
            removeButton.ArgDataTypes={'handle'};
            removeButton.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.removeFault';
            removeButton.ToolTip=DAStudio.message('autosarstandard:ui:uiFaultDeleteFaultTooltip');
            removeButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','TTE_delete.gif');
            removeButton.Enabled=autosar.ui.bsw.FaultSpreadsheet.isRemoveButtonEnabled(h);

            spreadsheetContainer.Type='panel';
            spreadsheetContainer.Tag=[tagPrefix,'matrixContainer'];
            spreadsheetContainer.LayoutGrid=[20,20];
            spreadsheetContainer.ColSpan=[1,15];
            spreadsheetContainer.RowSpan=[2,10];
            spreadsheetContainer.Items={
matrixSpreadsheet...
            ,addButton...
            ,removeButton...
            };


            sidebarIdx=0;
            sidebarIdxMax=20;

            sidebarIdx=sidebarIdx+1;
            faultTriggerLookup.Type='combobox';
            faultTriggerLookup.Entries=autosar.ui.bsw.Fault.triggerTypeOptions;
            faultTriggerLookup.Name=DAStudio.message('autosarstandard:bsw:TriggerTypePrompt');
            faultTriggerLookup.ToolTip=DAStudio.message('autosarstandard:bsw:TriggerTypeTooltip');
            faultTriggerLookup.Tag=[tagPrefix,'faultTriggerLookup'];
            faultTriggerLookup.ColSpan=[1,1];
            faultTriggerLookup.RowSpan=[sidebarIdx,sidebarIdx];
            faultTriggerLookup.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultTriggerType';
            faultTriggerLookup.MatlabArgs={'%dialog','%value'};

            sidebarIdx=sidebarIdx+1;
            faultTriggerStartTime.Type='edit';
            faultTriggerStartTime.Name=DAStudio.message('autosarstandard:bsw:StartTimePrompt');
            faultTriggerStartTime.ToolTip=DAStudio.message('autosarstandard:bsw:StartTimeTooltip');
            faultTriggerStartTime.Tag=[tagPrefix,'faultTriggerStartTime'];
            faultTriggerStartTime.ColSpan=[1,1];
            faultTriggerStartTime.RowSpan=[sidebarIdx,sidebarIdx];
            faultTriggerStartTime.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultStartTime';
            faultTriggerStartTime.MatlabArgs={'%dialog','%value'};

            tfCheck.Type='checkbox';
            tfCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_TF');
            tfCheck.Tag=[tagPrefix,'tfCheck'];
            tfCheck.ColSpan=[1,1];
            tfCheck.RowSpan=[1,1];
            tfCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            tfCheck.MatlabArgs={'%dialog',1,'%value'};

            tftocCheck.Type='checkbox';
            tftocCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_TFTOC');
            tftocCheck.Tag=[tagPrefix,'tftocCheck'];
            tftocCheck.ColSpan=[1,1];
            tftocCheck.RowSpan=[2,2];
            tftocCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            tftocCheck.MatlabArgs={'%dialog',2,'%value'};

            pdtcCheck.Type='checkbox';
            pdtcCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_PDTC');
            pdtcCheck.Tag=[tagPrefix,'pdtcCheck'];
            pdtcCheck.ColSpan=[1,1];
            pdtcCheck.RowSpan=[3,3];
            pdtcCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            pdtcCheck.MatlabArgs={'%dialog',3,'%value'};

            cdtcCheck.Type='checkbox';
            cdtcCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_CDTC');
            cdtcCheck.Tag=[tagPrefix,'cdtcCheck'];
            cdtcCheck.ColSpan=[1,1];
            cdtcCheck.RowSpan=[4,4];
            cdtcCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            cdtcCheck.MatlabArgs={'%dialog',4,'%value'};

            tncslcCheck.Type='checkbox';
            tncslcCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_TNCSLC');
            tncslcCheck.Tag=[tagPrefix,'tncslcCheck'];
            tncslcCheck.ColSpan=[1,1];
            tncslcCheck.RowSpan=[5,5];
            tncslcCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            tncslcCheck.MatlabArgs={'%dialog',5,'%value'};

            tfslcCheck.Type='checkbox';
            tfslcCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_TFSLC');
            tfslcCheck.Tag=[tagPrefix,'tfslcCheck'];
            tfslcCheck.ColSpan=[1,1];
            tfslcCheck.RowSpan=[6,6];
            tfslcCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            tfslcCheck.MatlabArgs={'%dialog',6,'%value'};

            tnctocCheck.Type='checkbox';
            tnctocCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_TNCTOC');
            tnctocCheck.Tag=[tagPrefix,'tnctocCheck'];
            tnctocCheck.ColSpan=[1,1];
            tnctocCheck.RowSpan=[7,7];
            tnctocCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            tnctocCheck.MatlabArgs={'%dialog',7,'%value'};

            wirCheck.Type='checkbox';
            wirCheck.Name=DAStudio.message('autosarstandard:bsw:UDS_WIR');
            wirCheck.Tag=[tagPrefix,'wirCheck'];
            wirCheck.ColSpan=[1,1];
            wirCheck.RowSpan=[8,8];
            wirCheck.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultOverrideBit';
            wirCheck.MatlabArgs={'%dialog',8,'%value'};

            sidebarIdx=sidebarIdx+1;
            faultTypeLookup.Type='combobox';
            faultTypeLookup.Entries=autosar.ui.bsw.FaultSpreadsheet.faultInjectOptions;
            faultTypeLookup.Name=DAStudio.message('autosarstandard:bsw:FaultInjectFaultTypePrompt');
            faultTypeLookup.ToolTip=DAStudio.message('autosarstandard:bsw:FaultOverrideFaultTypeTooltip');
            faultTypeLookup.Tag=[tagPrefix,'faultLookup'];
            faultTypeLookup.ColSpan=[1,1];
            faultTypeLookup.RowSpan=[sidebarIdx,sidebarIdx];
            faultTypeLookup.MatlabMethod='autosar.ui.bsw.FaultSpreadsheet.setFaultInjectType';
            faultTypeLookup.MatlabArgs={'%dialog','%value'};

            sidebarIdx=sidebarIdx+1;
            faultOverrideContainer.Type='panel';
            faultOverrideContainer.Tag=[tagPrefix,'faultOverrideContainer'];
            faultOverrideContainer.LayoutGrid=[1,8];
            faultOverrideContainer.ColSpan=[1,1];
            faultOverrideContainer.RowSpan=[sidebarIdx,sidebarIdx];
            faultOverrideContainer.Items={
tfCheck...
            ,tftocCheck...
            ,pdtcCheck...
            ,cdtcCheck...
            ,tncslcCheck...
            ,tfslcCheck...
            ,tnctocCheck...
            ,wirCheck...
            };

            sidebarIdx=sidebarIdx+1;
            faultHelp.Type='text';
            faultHelp.Name=DAStudio.message('autosarstandard:bsw:FaultPaneDescription');
            faultHelp.WordWrap=true;
            faultHelp.Tag=[tagPrefix,'faultHelp'];
            faultHelp.ColSpan=[1,1];
            faultHelp.RowSpan=[sidebarIdx,sidebarIdx];



            sidebarIdx=sidebarIdx+1;
            filler.Type='text';
            filler.Name='';
            filler.WordWrap=true;
            filler.Tag=[tagPrefix,'sideBarFiller'];
            filler.ColSpan=[1,1];
            filler.RowSpan=[sidebarIdx,sidebarIdxMax];

            sidePanel.Type='group';
            sidePanel.Name=DAStudio.message('autosarstandard:bsw:FaultSidebarTitle');
            sidePanel.Tag=[tagPrefix,'sideContainer'];
            sidePanel.LayoutGrid=[1,20];
            sidePanel.ColSpan=[11,15];
            sidePanel.RowSpan=[1,sidebarIdxMax];
            sidePanel.Items={
faultHelp...
            ,faultTriggerLookup...
            ,faultTriggerStartTime...
            ,faultOverrideContainer...
            ,faultTypeLookup...
            ,filler...
            };

            mainPanel.Type='panel';
            mainPanel.Tag=[tagPrefix,'topContainer'];
            mainPanel.LayoutGrid=[1,2];
            mainPanel.ColSpan=[1,10];
            mainPanel.RowSpan=[1,10];
            mainPanel.Items={
topContainer...
            ,spreadsheetContainer...
            };


            matrixContainer.Type='panel';
            matrixContainer.Tag=[tagPrefix,'matrixContainer'];
            matrixContainer.LayoutGrid=[15,10];
            matrixContainer.ColSpan=[1,1];
            matrixContainer.RowSpan=[1,1];
            matrixContainer.Items={
mainPanel...
            ,sidePanel...
            };

            text=[];
            text.Name=DAStudio.message('autosarstandard:ui:uiFaultTab');
            text.Tag=[tagPrefix,'faulttabtext'];

            text.Items={
matrixContainer
            };

        end
    end
end



