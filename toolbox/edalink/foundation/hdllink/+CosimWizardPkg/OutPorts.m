

classdef OutPorts<CosimWizardPkg.StepBase
    methods
        function obj=OutPorts(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end

        function WidgetGroup=getDialogSchema(this)

            onInherit.Type='pushbutton';
            onInherit.Name='Set all sample times and data types to ''Inherit''';
            onInherit.Tag='edaOnInherit';
            onInherit.ObjectMethod='onInherit';
            onInherit.MethodArgs={'%dialog'};
            onInherit.ArgDataTypes={'handle'};
            onInherit.RowSpan=[1,1];
            onInherit.ColSpan=[1,1];

            switch(this.Wizard.UserData.Workflow)
            case 'Simulink'
                onInherit.Visible=true;
            case 'MATLAB System Object'
                onInherit.Visible=false;
            end


            OutPortList=l_CreatePortTable;
            OutPortList.Name='Output Port List';
            OutPortList.Tag='edaOutDetailTable';
            OutPortList.Data=l_CreatePortTableData(this.Wizard.UserData.Workflow,this.Wizard.UserData.UsedOutPortList);
            OutPortList.Size=size(OutPortList.Data);
            OutPortList.ValueChangedCallback=@l_TableValueChangeCb;
            OutPortList.RowSpan=[2,4];
            OutPortList.ColSpan=[1,4];
            OutPortList.ReadOnlyColumns=0;
            OutPortList.ColumnHeaderHeight=2;
            OutPortList.FontFamily='Courier';


            WidgetGroup.LayoutGrid=[4,4];
            WidgetGroup.Items={onInherit,OutPortList};


            this.Wizard.UserData.CurrentStep=6;

        end

        function Description=getDescription(this,~)

            switch(this.Wizard.UserData.Workflow)
            case 'Simulink'
                Description=['Set the sample time and data type for each output port. '...
                ,'You can specify the sample time as -1, which means that it will '...
                ,'be inherited via back propagation in the Simulink model. Back propagation '...
                ,'may fail in certain circumstances; click Help for details.'];
            case 'MATLAB System Object'
                Description='Set the data type and fraction length for each output port.';
            end
        end
        function onBack(this,~)
            this.Wizard.NextStepID=5;
        end
        function EnterStep(~,~)
            return;
        end
        function onNext(this,~)
            for m=1:numel(this.Wizard.UserData.UsedOutPortList)
                sampleT=eval(this.Wizard.UserData.UsedOutPortList{m}.SampleTime);
                assert(~isnan(sampleT),...
                message('HDLLink:CosimWizard:InvalidPortSampleTime',...
                this.Wizard.UserData.UsedOutPortList{m}.Name));

                fracL=eval(this.Wizard.UserData.UsedOutPortList{m}.FractionLength);
                assert(~isnan(fracL),...
                message('HDLLink:CosimWizard:InvalidFracLen',...
                this.Wizard.UserData.UsedOutPortList{m}.Name));
            end

            hasClk=~isempty(this.Wizard.UserData.ClkList);
            hasRst=~isempty(this.Wizard.UserData.RstList);

            if(hasClk||hasRst)
                this.Wizard.NextStepID=7;
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

function widget=l_CreatePortTable
    widget.Type='table';
    widget.HeaderVisibility=[0,1];
    widget.ColHeader={'Port Name','Sample Time','Data Type','Sign','Fraction Length'};
    widget.ColumnCharacterWidth=[15,12,15,19,30];
    widget.RowHeader={};
    widget.Enabled=true;
    widget.Editable=true;
    widget.Mode=1;
    widget.LastColumnStretchable=true;
end

function Data=l_CreatePortTableData(Workflow,UsedOutPortList)
    row=numel(UsedOutPortList);
    Data=cell(row,5);
    switch(Workflow)
    case 'Simulink'
        dataTypeEnum={'Inherit','Fixedpoint','Double','Single'};
    otherwise
        dataTypeEnum={'Fixedpoint','Double','Single'};
    end

    for m=1:row
        Data{m,1}=UsedOutPortList{m}.Name;
        Data{m,2}=l_CreateEditCell(UsedOutPortList{m}.SampleTime,true,'1');
        Data{m,3}=l_CreateComboCell(UsedOutPortList{m}.DataType,true,dataTypeEnum);

        curDataType=dataTypeEnum{UsedOutPortList{m}.DataType+1};
        signEnabled=strcmpi(curDataType,'Fixedpoint');
        Data{m,4}=l_CreateComboCell(UsedOutPortList{m}.Sign,signEnabled,{'Unsigned','Signed'});
        if signEnabled
            defaultFrac='0';
        else
            defaultFrac='Inherit';
        end
        Data{m,5}=l_CreateEditCell(UsedOutPortList{m}.FractionLength,signEnabled,defaultFrac);
    end
end

function widget=l_CreateEditCell(value,isEnabled,default)
    widget.Type='edit';
    widget.Enabled=true;
    widget.Mode=0;
    widget.Enabled=isEnabled;
    if(isEnabled)
        widget.Value=value;
    else
        widget.Value=default;
    end
end

function widget=l_CreateComboCell(value,isEnabled,list)
    widget.Type='combobox';
    widget.Value=value;
    widget.Enabled=isEnabled;
    widget.Mode=0;
    widget.Entries=list;
end

function l_TableValueChangeCb(dlg,row,col,value)
    h=getDialogSource(dlg);
    switch(col)
    case 1
        h.UserData.UsedOutPortList{row+1}.SampleTime=value;
    case 2
        h.UserData.UsedOutPortList{row+1}.DataType=value;
    case 3
        h.UserData.UsedOutPortList{row+1}.Sign=value;
    case 4
        h.UserData.UsedOutPortList{row+1}.FractionLength=value;
    end

    if(col==2)
        dlg.refresh;
    end
end


