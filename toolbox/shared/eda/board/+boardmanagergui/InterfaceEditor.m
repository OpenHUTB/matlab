classdef InterfaceEditor<handle
























    properties(SetObservable)

        Interface=[];

        SignalCell=[];

        ParentDlg=[];

        isReadOnly(1,1)logical=false;

        GenerateMDIOModule(1,1)logical=false;

        PhyAddr{matlab.internal.validation.mustBeASCIICharRowVector(PhyAddr,'PhyAddr')}='';

        User1Cmd{matlab.internal.validation.mustBeASCIICharRowVector(User1Cmd,'User1Cmd')}='';

        User2Cmd{matlab.internal.validation.mustBeASCIICharRowVector(User2Cmd,'User2Cmd')}='';

        User3Cmd{matlab.internal.validation.mustBeASCIICharRowVector(User3Cmd,'User3Cmd')}='';

        User4Cmd{matlab.internal.validation.mustBeASCIICharRowVector(User4Cmd,'User4Cmd')}='';

        InstrRegLenBefore=0;

        InstrRegLenAfter=0;

        TckFrequency=0;
    end


    methods
        function this=InterfaceEditor(varargin)
            this.Interface=varargin{1};
            if nargin>=2
                this.isReadOnly=varargin{2};
            else
                this.isReadOnly=false;
            end
            isUserDefined=isa(this.Interface,'eda.internal.boardmanager.UserdefinedInterface');
            signalNames=this.Interface.getSignalNames;
            numSig=numel(signalNames);
            this.SignalCell=cell(numSig,6);
            for m=1:numSig
                signalName=signalNames{m};
                if isUserDefined
                    indx=this.Interface.getSignalOrder(signalName);
                else
                    indx=m;
                end
                this.SignalCell{indx,1}=l_CreateEditCell(signalName,isUserDefined);
                this.SignalCell{indx,2}=l_CreateEditCell(this.Interface.getDescription(signalName),isUserDefined);
                this.SignalCell{indx,3}=l_CreateDirectionBox(this.Interface.getDirection(signalName),isUserDefined);
                this.SignalCell{indx,4}=l_CreateEditCell(this.Interface.getBitWidth(signalName),isUserDefined);
                this.SignalCell{indx,5}=l_CreateEditCell(this.Interface.getFPGAPin(signalName),true);
                this.SignalCell{indx,6}=l_CreateEditCell(this.Interface.getIOStandard(signalName),true);
            end

            if isa(this.Interface,'eda.internal.boardmanager.DigilentJTAG')
                this.User1Cmd=this.Interface.User1Cmd;
                this.User2Cmd=this.Interface.User2Cmd;
                this.User3Cmd=this.Interface.User3Cmd;
                this.User4Cmd=this.Interface.User4Cmd;
                this.InstrRegLenBefore=this.Interface.InstrRegLenBefore;
                this.InstrRegLenAfter=this.Interface.InstrRegLenAfter;
                this.TckFrequency=this.Interface.TckFrequency;
            elseif isa(this.Interface,'eda.internal.boardmanager.EthInterface')
                this.GenerateMDIOModule=this.Interface.isMDIOModuleEnabled;
                this.PhyAddr=this.Interface.getPhyAddr;
            else
                this.GenerateMDIOModule=false;
                this.PhyAddr='0';
            end
        end
    end

    methods
        function set.isReadOnly(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isReadOnly')
            value=logical(value);
            obj.isReadOnly=value;
        end

        function set.GenerateMDIOModule(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateMDIOModule')
            value=logical(value);
            obj.GenerateMDIOModule=value;
        end

        function set.PhyAddr(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','PhyAddr')
            obj.PhyAddr=value;
        end

        function set.User1Cmd(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','User1Cmd')
            obj.User1Cmd=value;
        end

        function set.User2Cmd(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','User2Cmd')
            obj.User2Cmd=value;
        end

        function set.User3Cmd(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','User3Cmd')
            obj.User3Cmd=value;
        end

        function set.User4Cmd(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','User4Cmd')
            obj.User4Cmd=value;
        end

        function set.InstrRegLenBefore(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','InstrRegLenBefore')
            value=double(value);
            obj.InstrRegLenBefore=value;
        end

        function set.InstrRegLenAfter(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','InstrRegLenAfter')
            value=double(value);
            obj.InstrRegLenAfter=value;
        end

        function set.TckFrequency(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','TckFrequency')
            value=double(value);
            obj.TckFrequency=value;
        end
    end

    methods(Hidden)

        function dlgStruct=getDialogSchema(this,~)
            DescTxt.Type='text';
            DescTxt.Tag='edaText';
            DescTxt.Name=this.Interface.getFormInstruction;
            DescTxt.RowSpan=[1,1];
            DescTxt.ColSpan=[1,1];
            DescTxt.WordWrap=true;

            TextGroup.Type='group';
            TextGroup.Tag='fpgaTextGroup';
            TextGroup.Name='Action';
            TextGroup.LayoutGrid=[1,1];
            TextGroup.RowSpan=[1,1];
            TextGroup.ColSpan=[1,10];
            TextGroup.Items={DescTxt};

            SignalGroup=this.getSignalTableWidgets;

            buttonWidgets=l_getButtonSet(this);
            buttonWidgets.RowSpan=[10,10];
            buttonWidgets.ColSpan=[8,10];


            dlgStruct.DialogTitle=this.Interface.Name;
            dlgStruct.Items={TextGroup,SignalGroup};

            dlgStruct.LayoutGrid=[10,10];
            dlgStruct.RowStretch=[0,1,1,1,1,1,1,1,1,0];
            dlgStruct.ColStretch=[1,1,1,1,1,1,1,1,0,0];
            dlgStruct.PreApplyMethod='preApplyCallback';
            dlgStruct.PreApplyArgs={'%dialog'};
            dlgStruct.PreApplyArgsDT={'handle'};
            dlgStruct.Sticky=true;


            dlgStruct.HelpMethod='eda.internal.boardmanager.helpview';
            if isa(this.Interface,'eda.internal.boardmanager.UserdefinedInterface')
                dlgStruct.HelpArgs={'FPGABoard_TurnkeyIO'};
            else
                dlgStruct.HelpArgs={'FPGABoard_FILIO'};
            end


            dlgStruct.StandaloneButtonSet={'OK','Help','Cancel','Apply'};


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end


        function newInterface=getNewInterfaceFromTable(this,dlg)
            tableTag=['fpgaSignalTbl',class(this.Interface)];

            newInterface=eval(class(this.Interface));
            if isa(this.Interface,'eda.internal.boardmanager.DigilentJTAG')
                newInterface.User1Cmd=this.User1Cmd;
                newInterface.User2Cmd=this.User2Cmd;
                newInterface.User3Cmd=this.User3Cmd;
                newInterface.User4Cmd=this.User4Cmd;
                newInterface.InstrRegLenBefore=this.InstrRegLenBefore;
                newInterface.InstrRegLenAfter=this.InstrRegLenAfter;
                newInterface.TckFrequency=this.TckFrequency;
            elseif isa(this.Interface,'eda.internal.boardmanager.EthInterface')


                signalNames=this.Interface.getSignalNames;
                numSig=numel(signalNames);
                for m=1:numSig
                    signalName=signalNames{m};
                    signal=newInterface.getSignal(signalName);
                    signal.FPGAPin=dlg.getTableItemValue(tableTag,m-1,4);
                    signal.IOStandard=dlg.getTableItemValue(tableTag,m-1,5);
                    signal.validate;
                end

                if isa(newInterface,'eda.internal.boardmanager.EthInterface')
                    newInterface.setGenerateMDIOModule(this.GenerateMDIOModule);
                    if this.GenerateMDIOModule
                        newInterface.setPhyAddr(this.PhyAddr);
                    end
                end
            else
                [numSignal,~]=size(this.SignalCell);
                for m=1:numSignal
                    name=dlg.getTableItemValue(tableTag,m-1,0);
                    signal=newInterface.addSignal(name);
                    signal.Description=dlg.getTableItemValue(tableTag,m-1,1);
                    signal.Direction=dlg.getTableItemValue(tableTag,m-1,2);
                    signal.BitWidth=round(str2double(dlg.getTableItemValue(tableTag,m-1,3)));
                    signal.FPGAPin=dlg.getTableItemValue(tableTag,m-1,4);
                    signal.IOStandard=dlg.getTableItemValue(tableTag,m-1,5);
                    signal.validate;
                end
                newInterface.validate;
            end


        end


        function SignalGroup=getSignalTableWidgets(this)
            isPredefinedInterf=isa(this.Interface,'eda.internal.boardmanager.PredefinedInterface');
            isBtnVisible=~isPredefinedInterf&&~this.isReadOnly;

            SignalTbl.Type='table';
            tableTag=['fpgaSignalTbl',class(this.Interface)];
            SignalTbl.Tag=tableTag;
            SignalTbl.Name='';

            SignalTbl.ColHeader={DAStudio.message('EDALink:boardmanagergui:SignalName'),...
            DAStudio.message('EDALink:boardmanagergui:Description'),...
            DAStudio.message('EDALink:boardmanagergui:Direction'),...
            DAStudio.message('EDALink:boardmanagergui:BitWidth'),...
            DAStudio.message('EDALink:boardmanagergui:FPGAPinNumber'),...
            DAStudio.message('EDALink:boardmanagergui:FPGAIOStandard')};

            SignalTbl.Size=size(this.SignalCell);
            SignalTbl.RowSpan=[1,10];
            if isBtnVisible
                SignalTbl.ColSpan=[1,8];
            else
                SignalTbl.ColSpan=[1,10];
            end
            SignalTbl.HeaderVisibility=[0,1];
            SignalTbl.Data=this.SignalCell;
            SignalTbl.ValueChangedCallback=@l_tableValueChangeCb;
            SignalTbl.Source=this;
            SignalTbl.Editable=~this.isReadOnly;
            SignalTbl.LastColumnStretchable=true;
            SignalTbl.ColumnCharacterWidth=[12,20,10,10,25];

            AddBtn=l_getPushButton(this,DAStudio.message('EDALink:boardmanagergui:AddNew'),'onNew',[1,1],[9,10]);
            AddTemplateBtn=l_getPushButton(this,DAStudio.message('EDALink:boardmanagergui:AddUsingTemplate'),'onAddTemplate',[2,2],[9,10]);
            DeleteBtn=l_getPushButton(this,DAStudio.message('EDALink:boardmanagergui:Delete'),'onDelete',[3,3],[9,10]);

            AddBtn.Visible=isBtnVisible;
            AddTemplateBtn.Visible=isBtnVisible;
            DeleteBtn.Visible=isBtnVisible;

            SignalGroup.Type='group';
            SignalGroup.Tag='fpgaSignalGroup';
            SignalGroup.Name=DAStudio.message('EDALink:boardmanagergui:SignalList');
            SignalGroup.RowSpan=[2,9];
            SignalGroup.ColSpan=[1,10];


            if isa(this.Interface,'eda.internal.boardmanager.EthInterface')
                GenerateMDIO.Type='checkbox';
                GenerateMDIO.Tag='fpgaMdio';
                GenerateMDIO.Name=DAStudio.message('EDALink:boardmanagergui:GenerateMDIO');
                GenerateMDIO.ObjectProperty='GenerateMDIOModule';
                GenerateMDIO.RowSpan=[1,1];
                GenerateMDIO.ColSpan=[1,5];
                GenerateMDIO.Source=this;
                GenerateMDIO.ObjectMethod='onChangeMDIO';
                GenerateMDIO.MethodArgs={'%dialog','%value'};
                GenerateMDIO.ArgDataTypes={'handle','bool'};
                GenerateMDIO.Mode=true;
                GenerateMDIO.Enabled=~this.isReadOnly;

                WhatsThis.Type='hyperlink';
                WhatsThis.Tag='fpgaMdioWhatsThis';
                WhatsThis.Name=DAStudio.message('EDALink:boardmanagergui:WhatsThis');
                WhatsThis.RowSpan=[1,1];
                WhatsThis.ColSpan=[6,7];
                WhatsThis.ObjectMethod='onWhatsThis';
                WhatsThis.Source=this;

                PhyAddrField.Type='edit';
                PhyAddrField.Tag='fpgaPhyAddr';
                PhyAddrField.Name=DAStudio.message('EDALink:boardmanagergui:PhyAddr');
                PhyAddrField.ObjectProperty='PhyAddr';
                PhyAddrField.Source=this;
                PhyAddrField.RowSpan=[2,2];
                PhyAddrField.ColSpan=[2,7];
                PhyAddrField.Enabled=this.GenerateMDIOModule&&~this.isReadOnly;
                PhyAddrField.Mode=true;

                AdvOptions.Type='togglepanel';
                AdvOptions.Name=DAStudio.message('EDALink:boardmanagergui:AdvOpt');
                AdvOptions.Tag='fpgaAdvOpt';
                AdvOptions.RowSpan=[11,12];
                AdvOptions.ColSpan=[1,6];
                AdvOptions.LayoutGrid=[2,6];
                AdvOptions.Items={GenerateMDIO,PhyAddrField,WhatsThis};

                SignalGroup.LayoutGrid=[9,10];
                SignalGroup.Items={SignalTbl,...
                AddBtn,AddTemplateBtn,DeleteBtn,AdvOptions};
            elseif isa(this.Interface,'eda.internal.boardmanager.DigilentJTAG')
                InstrPre=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:InstrBefore'),'InstrRegLenBefore',1);
                InstrAft=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:InstrAfter'),'InstrRegLenAfter',2);

                Image.Type='image';
                Image.Name='Example:';
                Image.FilePath=fullfile(matlabroot,'toolbox','shared','eda','board','resources','jtagchain.png');
                Image.RowSpan=[1,1];
                Image.ColSpan=[1,10];

                Instruction.Type='text';
                Instruction.Name=DAStudio.message('EDALink:boardmanagergui:XJTAG_Detailed_Instruction');
                Instruction.WordWrap=true;
                Instruction.RowSpan=[2,2];
                Instruction.ColSpan=[1,10];
                Example.Type='group';
                Example.Name=DAStudio.message('EDALink:boardmanagergui:Example');
                Example.RowSpan=[3,6];
                Example.ColSpan=[1,10];
                Example.LayoutGrid=[2,10];
                Example.Items={Image,Instruction};

                User1=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:User1Instr'),'User1Cmd',1);
                User2=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:User2Instr'),'User2Cmd',2);
                User3=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:User3Instr'),'User3Cmd',3);
                User4=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:User4Instr'),'User4Cmd',4);
                Tck=l_getEditBox(this,DAStudio.message('EDALink:boardmanagergui:JTAGClkFreq'),'TckFrequency',6);
                AdvOptions.Type='togglepanel';
                AdvOptions.Name=DAStudio.message('EDALink:boardmanagergui:AdvOpt');
                AdvOptions.Tag='fpgaAdvOpt';
                AdvOptions.RowSpan=[7,8];
                AdvOptions.ColSpan=[1,6];
                AdvOptions.LayoutGrid=[2,6];
                AdvOptions.Items={User1,User2,User3,User4,Tck};

                SignalGroup.LayoutGrid=[6,10];
                SignalGroup.Items={InstrPre,InstrAft,Example,AdvOptions};
            else
                SignalGroup.LayoutGrid=[10,10];
                SignalGroup.Items={SignalTbl,...
                AddBtn,AddTemplateBtn,DeleteBtn};
            end

            function l_tableValueChangeCb(dlg,row,col,value)
                this=dlg.getWidgetSource(tableTag);
                this.SignalCell{row+1,col+1}.Value=value;
            end
        end


        function onAddTemplate(this,dlg)
            newDlg=boardmanagergui.AddUsingTemplate;
            newDlg.ParentDlg=dlg;
            newDlg.ParentSrc=this;
            DAStudio.Dialog(newDlg);
        end


        function onChangeMDIO(~,dlg,value)
            dlg.setEnabled('fpgaPhyAddr',value);
        end


        function onDelete(this,dlg)
            tableTag=['fpgaSignalTbl',class(this.Interface)];
            rows=dlg.getSelectedTableRows(tableTag);
            if isempty(rows)
                return;
            end

            for m=length(rows):-1:1
                this.SignalCell(rows(m)+1,:)=[];
            end

            dlg.refresh;
        end


        function onNew(this,dlg)
            edit=l_CreateEditCellNew;
            box=l_CreateDirectionBoxNew;
            this.SignalCell=[this.SignalCell;{edit,edit,box,edit,edit,edit}];
            dlg.refresh;
        end


        function onWhatsThis(~)
            eda.internal.boardmanager.helpview('FPGABoard_MDIO');
        end


        function preApplyCallback(this,dlg)
            if this.isReadOnly

                return;
            end
            newInterface=this.getNewInterfaceFromTable(dlg);
            boardObj=this.ParentDlg.getSource.BoardObj;
            boardObj.FPGA.setInterface(newInterface);


            this.ParentDlg.enableApplyButton(true);
            this.ParentDlg.refresh;
        end
    end
end

function widget=l_CreateEditCell(value,isEnabled)
    widget.Type='edit';
    widget.Enabled=isEnabled;
    widget.Value=value;
end

function widget=l_CreateDirectionBox(value,isEnabled)
    if isEnabled
        widget.Type='combobox';
        if strcmpi(value,'out')
            widget.Value=1;
        elseif strcmpi(value,'inout')
            widget.Value=2;
        else
            widget.Value=0;
        end
        widget.Enabled=isEnabled;
        widget.Entries={'in','out','inout'};
    else
        widget.Type='edit';
        widget.Enabled=false;
        widget.Value=value;
    end
end














function ButtonSet=l_getButtonSet(this)
    BtnHelp=l_getPushButton(this,'Help','onHelp',[1,1],[1,1]);
    BtnClose=l_getPushButton(this,'Cancel','onCancel',[1,1],[2,2]);
    ButtonSet.Type='panel';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,2];
    ButtonSet.RowStretch=1;
    ButtonSet.Items={BtnHelp,BtnClose};
end



function button=l_getPushButton(this,Name,ObjectMethod,RowSpan,ColSpan)
    button.Name=Name;
    button.Tag=['eda',Name];
    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=RowSpan;
    button.ColSpan=ColSpan;
    button.Source=this;
end

function box=l_getEditBox(this,Name,Prop,Row)
    box.Type='edit';
    box.Tag=['fpga',Prop];
    box.Name=Name;
    box.ObjectProperty=Prop;
    box.RowSpan=[Row,Row];
    box.ColSpan=[2,7];
    box.Source=this;
    box.Mode=true;
end



function widget=l_CreateEditCellNew
    widget.Type='edit';
    widget.Value='';
end

function widget=l_CreateDirectionBoxNew
    widget.Type='combobox';
    widget.Value='in';
    widget.Entries=eda.internal.boardmanager.Signal.DirectionEnum;
end
