

classdef ClockReset<CosimWizardPkg.StepBase
    methods
        function obj=ClockReset(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end

        function WidgetGroup=getDialogSchema(this)

            HdlUnit.Type='combobox';
            HdlUnit.Name='HDL time unit';
            HdlUnit.Tag='edaHdlTimeUnit';
            HdlUnit.Entries=this.Wizard.UserData.HdlTimeUnitNames;
            HdlUnit.RowSpan=[1,1];
            HdlUnit.ColSpan=[1,1];
            HdlUnit.Mode=1;
            HdlUnit.ObjectProperty='HdlTimeUnit';
            HdlUnit.DialogRefresh=true;


            this.Wizard.UserData.HdlTimeUnit=this.Wizard.HdlTimeUnit;
            hdlUnitName=this.Wizard.HdlTimeUnit;


            ClkTable=l_CreateTable({'Clock Name',['Period(',hdlUnitName,')'],'Active Edge'});
            ClkTable.Name='Clocks';
            ClkTable.Tag='edaClocks';
            ClkTable.Data=l_CreateClkData(this.Wizard.UserData);
            ClkTable.Size=size(ClkTable.Data);
            ClkTable.RowSpan=[2,3];
            ClkTable.ColSpan=[1,4];
            ClkTable.ReadOnlyColumns=0;
            ClkTable.ColumnHeaderHeight=1;
            ClkTable.FontFamily='Courier';


            RstTable=l_CreateTable({'Reset Name','Initial Value',['Duration(',hdlUnitName,')']});
            RstTable.Name='Resets';
            RstTable.Tag='edaResets';
            RstTable.Data=l_CreateRstData(this.Wizard.UserData);
            RstTable.Size=size(RstTable.Data);
            RstTable.RowSpan=[4,5];
            RstTable.ColSpan=[1,4];
            RstTable.ReadOnlyColumns=0;
            RstTable.ColumnHeaderHeight=1;
            RstTable.FontFamily='Courier';


            WidgetGroup.LayoutGrid=[5,4];
            WidgetGroup.ColStretch=[1,1,1,1];
            WidgetGroup.RowStretch=[0,1,1,1,1];
            WidgetGroup.Items={HdlUnit,ClkTable,RstTable};


            this.Wizard.UserData.CurrentStep=7;
        end

        function Description=getDescription(~)

            Description='Set clock and reset parameters here. The time in these tables refers to time in the HDL simulator.';
        end
        function onBack(this,dlg)

            this.Wizard.UserData.HdlTimeUnit=this.Wizard.HdlTimeUnit;


            row=numel(this.Wizard.UserData.ClkList);
            for m=1:row
                this.Wizard.UserData.ClkList{m}.Period=getTableItemValue(this.Wizard,dlg,'edaClocks',m-1,1);
                this.Wizard.UserData.ClkList{m}.Edge=getTableItemValue(this.Wizard,dlg,'edaClocks',m-1,2);
            end


            row=numel(this.Wizard.UserData.RstList);
            for m=1:row
                this.Wizard.UserData.RstList{m}.Initial=getTableItemValue(this.Wizard,dlg,'edaResets',m-1,1);
                this.Wizard.UserData.RstList{m}.Duration=getTableItemValue(this.Wizard,dlg,'edaResets',m-1,2);
            end
            this.Wizard.NextStepID=6;
        end
        function EnterStep(this,~)
            this.Wizard.HdlTimeUnit=this.Wizard.UserData.HdlTimeUnit;
        end
        function onNext(this,dlg)
            this.Wizard.UserData.HdlTimeUnit=this.Wizard.HdlTimeUnit;


            row=numel(this.Wizard.UserData.ClkList);
            for m=1:row
                Period=getTableItemValue(this.Wizard,dlg,'edaClocks',m-1,1);
                Edge=getTableItemValue(this.Wizard,dlg,'edaClocks',m-1,2);
                this.Wizard.UserData.setClkInfo(m,Period,Edge);
            end


            row=numel(this.Wizard.UserData.RstList);
            for m=1:row
                Initial=getTableItemValue(this.Wizard,dlg,'edaResets',m-1,1);
                Duration=getTableItemValue(this.Wizard,dlg,'edaResets',m-1,2);
                this.Wizard.UserData.setRstInfo(m,Initial,Duration);
            end


            hasRst=~isempty(this.Wizard.UserData.RstList);
            hasClk=~isempty(this.Wizard.UserData.ClkList);

            if(hasRst||hasClk)
                displayStatusMessage(this.Wizard,dlg,'Please wait while generating waveforms.');
                onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);%#ok<NASGU>
                genWaveform(this.Wizard.UserData,true);
                this.Wizard.NextStepID=8;
                restoreFromSchema(this.Wizard,dlg);
            else
                switch(this.Wizard.UserData.Workflow)
                case 'Simulink'
                    this.Wizard.NextStepID=9;
                case 'MATLAB System Object'
                    this.Wizard.NextStepID=12;
                end
            end
        end

    end
end

function widget=l_CreateTable(entries)
    widget.Type='table';
    widget.HeaderVisibility=[0,1];
    widget.ColHeader=entries;
    widget.RowHeader={};
    widget.Enabled=true;
    widget.Editable=true;
    widget.Mode=1;
end

function Data=l_CreateClkData(UserData)
    row=numel(UserData.ClkList);
    col=3;
    Data=cell(row,col);
    for m=1:row
        Data{m,1}=UserData.ClkList{m}.Name;
        Data{m,2}=num2str(UserData.ClkList{m}.Period);
        Data{m,3}=l_CreateComboBox({'Rising','Falling'},UserData.ClkList{m}.Edge);
    end
end

function widget=l_CreateComboBox(entries,value)
    widget.Type='combobox';
    widget.Entries=entries;
    widget.Enabled=true;
    widget.Mode=0;
    switch(value)
    case entries{1}
        value=0;
    case entries{2}
        value=1;
    otherwise
        error(message('HDLLink:CosimWizard:InvalidEntries'));
    end
    widget.Value=value;
end

function Data=l_CreateRstData(UserData)
    row=numel(UserData.RstList);
    col=3;
    Data=cell(row,col);
    for m=1:row
        Data{m,1}=UserData.RstList{m}.Name;
        Data{m,2}=l_CreateComboBox({'0','1'},UserData.RstList{m}.Initial);
        Data{m,3}=num2str(UserData.RstList{m}.Duration);
    end
end


