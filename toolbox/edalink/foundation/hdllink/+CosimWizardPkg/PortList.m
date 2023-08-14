

classdef PortList<CosimWizardPkg.StepBase
    methods
        function obj=PortList(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end

        function WidgetGroup=getDialogSchema(this)

            InPortList=l_CreatePortTable;
            InPortList.Name='Input Port List';
            InPortList.Tag='edaInPortList';
            InPortList.Data=l_CreatePortTableData(this.Wizard.UserData,1);
            InPortList.Size=size(InPortList.Data);
            InPortList.RowSpan=[1,1];
            InPortList.ColSpan=[1,1];
            InPortList.ReadOnlyColumns=0;
            InPortList.ColumnHeaderHeight=2;
            InPortList.FontFamily='Courier';
            InPortList.ColumnCharacterWidth=[25,10];

            OutPortList=l_CreatePortTable;
            OutPortList.Name='Output Port List';
            OutPortList.Tag='edaOutPortList';
            OutPortList.Data=l_CreatePortTableData(this.Wizard.UserData,2);
            OutPortList.Size=size(OutPortList.Data);
            OutPortList.RowSpan=[1,1];
            OutPortList.ColSpan=[2,2];
            OutPortList.ReadOnlyColumns=0;
            OutPortList.ColumnHeaderHeight=2;
            OutPortList.FontFamily='Courier';
            OutPortList.ColumnCharacterWidth=[25,10];


            WidgetGroup.LayoutGrid=[1,2];
            WidgetGroup.Items={InPortList,OutPortList};


            this.Wizard.UserData.CurrentStep=5;
        end

        function Description=getDescription(this,~)

            switch(this.Wizard.UserData.Workflow)
            case 'Simulink'
                Description=['Specify all input and output port types. Input signals that '...
                ,'are identified as ''Clock'' and ''Reset'' signals will be forced in '...
                ,'the HDL simulator through Tcl commands. You can specify the timing '...
                ,'parameters for forced ''Clock'' and ''Reset'' signals in the next step. If '...
                ,'you want to drive your HDL clock and reset signals with Simulink signals, mark them as ''Input''.'];
            case 'MATLAB System Object'
                Description=['Specify all input and output port types. Input signals that '...
                ,'are identified as ''Clock'' and ''Reset'' signals will be forced in '...
                ,'the HDL simulator through Tcl commands. You can specify the timing '...
                ,'parameters for forced ''Clock'' and ''Reset'' signals in the next step. If '...
                ,'you want to drive your HDL clock and reset signals with MATLAB variables, mark them as ''Input''.'];
            end
        end
        function onBack(this,~)
            this.Wizard.NextStepID=4;
        end
        function EnterStep(~,~)
            return;
        end
        function onNext(this,dlg)
            numInPorts=numel(this.Wizard.UserData.InPortList);
            InPortTypes=zeros(1,numInPorts);
            for m=1:numInPorts
                Type=getTableItemValue(this.Wizard,dlg,'edaInPortList',m-1,1);
                switch(Type)
                case 'Input'
                    InPortTypes(m)=0;
                    this.Wizard.UserData.InPortList{m}.Type=0;
                case 'Clock'
                    InPortTypes(m)=1;
                    this.Wizard.UserData.InPortList{m}.Type=1;
                case 'Reset'
                    InPortTypes(m)=2;
                    this.Wizard.UserData.InPortList{m}.Type=2;
                otherwise
                    InPortTypes(m)=3;
                    this.Wizard.UserData.InPortList{m}.Type=3;
                end
            end

            numOutPorts=numel(this.Wizard.UserData.OutPortList);
            OutPortTypes=zeros(1,numOutPorts);
            for m=1:numOutPorts
                Type=getTableItemValue(this.Wizard,dlg,'edaOutPortList',m-1,1);
                switch(Type)
                case 'Output'
                    OutPortTypes(m)=0;
                    this.Wizard.UserData.OutPortList{m}.Type=0;
                otherwise
                    OutPortTypes(m)=1;
                    this.Wizard.UserData.OutPortList{m}.Type=1;
                end
            end


            this.Wizard.UserData.UsedInPortList=l_BuildUsedPortList(this.Wizard.UserData.InPortList,InPortTypes,0);
            this.Wizard.UserData.UsedOutPortList=l_BuildUsedPortList(this.Wizard.UserData.OutPortList,OutPortTypes,0);
            this.Wizard.UserData.ClkList=l_BuildUsedPortList(this.Wizard.UserData.InPortList,InPortTypes,1);
            this.Wizard.UserData.RstList=l_BuildUsedPortList(this.Wizard.UserData.InPortList,InPortTypes,2);

            hasInput=~isempty(this.Wizard.UserData.UsedInPortList);
            hasOutput=~isempty(this.Wizard.UserData.UsedOutPortList);
            hasClk=~isempty(this.Wizard.UserData.ClkList);
            hasRst=~isempty(this.Wizard.UserData.RstList);

            hasIO=hasInput||hasOutput;
            assert(hasIO,message('HDLLink:CosimWizard:NoIOPort'));
            if(hasOutput)
                this.Wizard.NextStepID=6;
            elseif(hasClk||hasRst)
                this.Wizard.NextStepID=7;
            else
                this.Wizard.NextStepID=9;
            end
        end

    end
end

function widget=l_CreatePortTable
    widget.Type='table';
    widget.HeaderVisibility=[0,1];
    widget.ColHeader={'Port Name','Port Type'};
    widget.RowHeader={};
    widget.Enabled=true;
    widget.Editable=true;
    widget.Mode=1;
    widget.LastColumnStretchable=true;
end

function Data=l_CreatePortTableData(UserData,ioMode)
    switch(ioMode)
    case 1
        entries={'Input','Clock','Reset','Unused'};
    case 2
        entries={'Output','Unused'};
    otherwise
        error(message('HDLLink:CosimWizard:InvalidMode'));
    end

    row=GetNumPorts(UserData,ioMode);
    col=2;
    Data=cell(row,col);
    for m=1:row
        port=getPort(UserData,m,ioMode);
        Data{m,1}=port.Name;
        Data{m,2}=l_CreateTableCell(entries,port.Type);
    end
end

function widget=l_CreateTableCell(entries,Type)
    widget.Type='combobox';
    widget.Entries=entries;
    widget.Enabled=true;
    widget.Value=Type;
end

function UsedPortList=l_BuildUsedPortList(FullPortList,TypeIndx,type)
    indx=(TypeIndx==type);
    UsedPortList=FullPortList(indx);
end




