function dlgstruct=getDialogSchema(this,~)

    dlgstruct=getDlgStruct(this);

end

function dlgstruct=getDlgStruct(this)

    tag_prefix='cosimsignal_';

    descriptionTextInput.Name=DAStudio.message('CoSimService:PortConfig:ConfigDialogUsageDescription');
    descriptionTextInput.Type='text';
    descriptionTextInput.WordWrap=true;
    descriptionTextInput.ColSpan=[1,1];
    descriptionTextInput.RowSpan=[1,1];
    descriptionTextInput.Alignment=1;

    description_group.Name=DAStudio.message('CoSimService:PortConfig:ConfigDialogUsageGroup');
    description_group.Type='group';
    description_group.LayoutGrid=[1,1];
    description_group.Items={descriptionTextInput};
    description_group.RowSpan=[1,1];
    description_group.ColSpan=[1,1];


    inputPorts.Type='spreadsheet';
    inputPorts.Columns={DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnPort'),...
    DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnContinuousQuantity'),...
    DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnRequestCompensation')};
    inputPorts.RowSpan=[1,1];
    inputPorts.ColSpan=[1,1];
    inputPorts.Tag=[tag_prefix,'inputPorts'];
    inputPorts.DialogRefresh=false;
    inputPorts.Hierarchical=true;
    inputPorts.MinimumSize=[100,50];
    inputPorts.Source=this.inputPortsSource;
    inputPorts.SelectionChangedCallback=@(tag,sels,dlg)this.inputPortsSource.handleSelectionChanged(tag,sels,dlg);

    inputAdvancedButton.Name=DAStudio.message('CoSimService:PortConfig:ConfigDialogAdvanced');
    inputAdvancedButton.Type='pushbutton';
    inputAdvancedButton.RowSpan=[2,2];
    inputAdvancedButton.ColSpan=[1,1];
    inputAdvancedButton.Alignment=7;
    inputAdvancedButton.Tag=[tag_prefix,'inputAdvancedButton'];
    inputAdvancedButton.DialogRefresh=false;
    inputAdvancedButton.ObjectMethod='openCoSimSignalCompensationAdvancedDialog';
    inputAdvancedButton.Enabled=false;

    inputTab.Name=DAStudio.message('CoSimService:PortConfig:ConfigDialogInputTab');
    inputTab.LayoutGrid=[2,1];
    inputTab.RowStretch=[1,0];
    inputTab.Items={inputPorts,inputAdvancedButton};

    outputPorts.Type='spreadsheet';
    outputPorts.Columns={DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnPort'),...
    DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnContinuousQuantity')};
    outputPorts.RowSpan=[1,1];
    outputPorts.ColSpan=[1,1];
    outputPorts.Tag=[tag_prefix,'outputPorts'];
    outputPorts.DialogRefresh=false;
    outputPorts.Hierarchical=true;
    outputPorts.MinimumSize=[100,50];
    outputPorts.Source=this.outputPortsSource;

    outputTab.Name=DAStudio.message('CoSimService:PortConfig:ConfigDialogOutputTab');
    outputTab.LayoutGrid=[1,1];
    outputTab.Items={outputPorts};

    ports_tab.Type='tab';
    ports_tab.Name='';
    ports_tab.Tabs={inputTab,outputTab};
    ports_tab.RowSpan=[2,2];
    ports_tab.ColSpan=[1,1];

    dlgstruct.DialogTitle=[DAStudio.message('CoSimService:PortConfig:CoSimDialogTitle'),': ',this.block];
    dlgstruct.DialogTag='CoSimSignalCompensationConfiguration';

    dlgstruct.LayoutGrid=[3,2];
    dlgstruct.Transient=false;
    dlgstruct.DialogStyle='Normal';
    dlgstruct.ExplicitShow=true;
    dlgstruct.Sticky=true;
    dlgstruct.Items={description_group,ports_tab};

    dlgstruct.PreApplyMethod='coSimPreApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'ShowCouplingElementParameterDialog'};

end
