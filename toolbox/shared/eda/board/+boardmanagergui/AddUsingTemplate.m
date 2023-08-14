classdef AddUsingTemplate<handle














    properties(SetObservable)

        Interface{matlab.internal.validation.mustBeASCIICharRowVector(Interface,'Interface')}='';

        ParentDlg=[];

        ParentSrc=[];
    end

    methods
        function this=AddUsingTemplate(varargin)

        end
    end

    methods
        function set.Interface(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','Interface')
            obj.Interface=value;
        end
    end

    methods

        function dlgStruct=getDialogSchema(this,~)

            InterfaceBox.Type='combobox';
            InterfaceBox.Name='I/O:';
            InterfaceBox.Tag='fpgaInterface';
            InterfaceBox.ObjectProperty='Interface';
            InterfaceBox.Entries={'UART','LED','GPIO','DIP Switch'};
            InterfaceBox.Mode=true;
            InterfaceBox.RowSpan=[1,1];
            InterfaceBox.ColSpan=[1,4];
            InterfaceBox.DialogRefresh=true;
            if~ismember(this.Interface,InterfaceBox.Entries)
                this.Interface=InterfaceBox.Entries{1};
            end

            DescTxt.Type='text';
            DescTxt.Tag='fpgaDescText';
            switch this.Interface
            case 'UART'
                DescTxt.Name='Universal asynchronous receiver/transmitter';
            case 'LED'
                DescTxt.Name='User-defined LED output';
            case 'DIP Switch'
                DescTxt.Name='User-defined DIP switch input';
            case 'GPIO'
                DescTxt.Name='User-defined general purpose I/O pins';
            otherwise
                DescTxt.Name='';
            end
            DescTxt.Visible=true;
            DescTxt.RowSpan=[2,2];
            DescTxt.ColSpan=[1,6];
            DescTxt.Mode=1;
            DescTxt.WordWrap=true;

            buttonWidgets=l_getButtonSet;
            buttonWidgets.RowSpan=[3,3];
            buttonWidgets.ColSpan=[4,6];


            dlgStruct.DialogTitle='Add FPGA I/O Pins Using Template';
            dlgStruct.Items={InterfaceBox,DescTxt,buttonWidgets};

            dlgStruct.LayoutGrid=[3,6];


            dlgStruct.ShowGrid=false;
            dlgStruct.PreApplyMethod='preApplyCallback';
            dlgStruct.PreApplyArgs={'%dialog'};
            dlgStruct.PreApplyArgsDT={'handle'};
            dlgStruct.Sticky=true;


            dlgStruct.StandaloneButtonSet={''};


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end
    end

    methods(Hidden)

        function onCancel(~,dlg)
            delete(dlg);
        end

        function onOK(this,dlg)
            source=this.ParentSrc;
            switch this.Interface
            case 'UART'
                l_addSignal(source,'UART_Tx','UART transmit signal','out','1');
                l_addSignal(source,'UART_Rx','UART receive signal','in','1');
            case 'LED'
                l_addSignal(source,'LED','User-defined LED','out','');
            case 'GPIO'
                l_addSignal(source,'GPIO','General purpose I/O pins','in','');
            case 'DIP Switch'
                l_addSignal(source,'DIP','General purpose DIP switch','in','');
            otherwise
                error(message('EDALink:boardmanager:UnknownInterface',this.Interface));
            end
            this.ParentDlg.refresh;
            delete(dlg);
        end
    end
end

function button=l_getPushButton(Name,ObjectMethod,RowSpan,ColSpan)
    button.Name=Name;
    button.Tag=['eda',Name];

    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=RowSpan;
    button.ColSpan=ColSpan;
    button.Visible=true;
end

function ButtonSet=l_getButtonSet
    BtnHelp=l_getPushButton('OK','onOK',[1,1],[1,1]);
    BtnClose=l_getPushButton('Cancel','onCancel',[1,1],[2,2]);

    ButtonSet.Type='panel';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,2];
    ButtonSet.RowStretch=1;
    ButtonSet.Items={BtnHelp,BtnClose};
end

function l_addSignal(source,name,desc,direction,bitwidth)
    edit1=l_CreateEditCell(name);
    edit2=l_CreateEditCell(desc);
    combobox1=l_CreateDirectionBox(direction);
    edit3=l_CreateEditCell(bitwidth);
    edit4=l_CreateEditCell('');
    edit5=l_CreateEditCell('');
    source.SignalCell=[source.SignalCell;{edit1,edit2,combobox1,edit3,edit4,edit5}];
end

function widget=l_CreateEditCell(value)
    widget.Type='edit';
    widget.Value=value;
    widget.Enabled=true;
end

function widget=l_CreateDirectionBox(value)
    widget.Type='combobox';
    if strcmpi(value,'out')
        widget.Value=1;
    else
        widget.Value=0;
    end
    widget.Entries=eda.internal.boardmanager.Signal.DirectionEnum;
end
