classdef NewBoardWizard<handle
































    properties(SetObservable)

        Version{matlab.internal.validation.mustBeASCIICharRowVector(Version,'Version')}='';

        BoardName{matlab.internal.validation.mustBeASCIICharRowVector(BoardName,'BoardName')}='';

        BoardFile{matlab.internal.validation.mustBeASCIICharRowVector(BoardFile,'BoardFile')}='';

        ParentDlg=[];

        StepID=0;

        WidgetStackItems=[];

        hasFILIO(1,1)logical=false;

        HasUserIO(1,1)logical=false;

        EthType(1,1)int16{mustBeReal}=0;

        hBoardPropertyDlg=[];

        hInterfaceDlgs=[];

        hUserIoDlg=[];

        hValidationDlg=[];

        hManager=[];

        FirstTimeIn(1,1)logical=false;

        IsDialogFinished(1,1)logical=false;

        BoardObj=[];

        LastError=[];
    end

    properties(Hidden)
        RMIIDeprecationDlgDisplayed=false;
    end

    methods

        function this=NewBoardWizard(varargin)

            eda.internal.boardmanager.checkHDLProduct;
            eda.internal.boardmanager.checkFixedPointToolbox;
            this.ParentDlg=varargin{1};
            this.hManager=eda.internal.boardmanager.BoardManager.getInstance;

            if nargin==1
                this.BoardObj=eda.internal.boardmanager.FPGABoard;

                for m=1:20
                    newBoardName=['My New Board ',num2str(m)];
                    newBoardFile=fullfile(pwd,['newboard',num2str(m),'.xml']);
                    isBoardName=this.hManager.isBoard(newBoardName);
                    isBoardFile=this.hManager.isBoardFile(newBoardFile);
                    if~isBoardName&&~isBoardFile
                        break;
                    end
                end
                this.BoardName=newBoardName;
                this.BoardFile=newBoardFile;
            else
                this.BoardObj=varargin{2};
            end

            this.hBoardPropertyDlg=boardmanagergui.FPGABoardEditor(this.BoardObj);
            this.EthType=0;

            this.hInterfaceDlgs=containers.Map;

            userio=eda.internal.boardmanager.UserdefinedInterface;
            this.hUserIoDlg=boardmanagergui.InterfaceEditor(userio);

            this.hValidationDlg=boardmanagergui.BoardValidation;
            this.hValidationDlg.setBoardObj(this.BoardObj);


            tmp=ver('MATLAB');
            this.Version=tmp.Version;


            if ispref('FPGA','NewBoardWizardState')
                restoredState=getpref('FPGA','NewBoardWizardState');

                if~isempty(restoredState)
                    restore=false;

                    if isfield(restoredState,'Version')
                        if strcmpi(restoredState.Version,this.Version)

                            Question='Would you like to restore the saved session?';
                            answer=questdlg(Question,'Save session','Yes','No','Yes');
                            restore=strcmpi(answer,'Yes');
                        end
                    end

                    if restore
                        f=fields(restoredState);
                        for m=1:numel(f)
                            if~isstruct(restoredState.(f{m}))
                                this.(f{m})=restoredState.(f{m});
                            else
                                f2=fields(restoredState.(f{m}));
                                for n=1:numel(f2)
                                    this.(f{m}).(f2{n})=restoredState.(f{m}).(f2{n});
                                end
                            end
                        end
                        this.hValidationDlg.setBoardObj(this.BoardObj);
                    else
                        setpref('FPGA','NewBoardWizardState',[])
                    end
                end
            end


            this.StepID=1;
            this.FirstTimeIn=true;
            this.IsDialogFinished=false;
            this.LastError=[];
        end
    end

    methods

        function set.Version(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','Version')
            obj.Version=value;
        end

        function set.BoardName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.BoardName=value;
        end

        function set.BoardFile(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.BoardFile=value;
        end

        function set.StepID(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','StepID')
            value=round(value);
            obj.StepID=value;
        end

        function set.hasFILIO(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','hasFILIO')
            value=logical(value);
            obj.hasFILIO=value;
        end

        function set.HasUserIO(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','HasUserIO')
            value=logical(value);
            obj.HasUserIO=value;
        end

        function set.EthType(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','EthType')
            value=round(value);
            obj.EthType=value;
        end

        function set.hBoardPropertyDlg(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','hBoardPropertyDlg')
            obj.hBoardPropertyDlg=value;
        end

        function set.hUserIoDlg(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','hUserIoDlg')
            obj.hUserIoDlg=value;
        end

        function set.hValidationDlg(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','hValidationDlg')
            obj.hValidationDlg=value;
        end

        function set.FirstTimeIn(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','FirstTimeIn')
            value=logical(value);
            obj.FirstTimeIn=value;
        end

        function set.IsDialogFinished(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsDialogFinished')
            value=logical(value);
            obj.IsDialogFinished=value;
        end
    end

    methods

        function onCancel(~,dlg)

            delete(dlg);
        end

        function onHelp(this,~)

            switch(this.StepID)
            case 1
                eda.internal.boardmanager.helpview('FPGABoard_BasicInfo');
            case 2
                eda.internal.boardmanager.helpview('FPGABoard_Interfaces');
            case 3
                eda.internal.boardmanager.helpview('FPGABoard_FILIO');
            case 4
                eda.internal.boardmanager.helpview('FPGABoard_TurnkeyIO');
            case 5
                eda.internal.boardmanager.helpview('FPGABoard_Validation');
            end

        end


        function onNext(this,dlg)

            try
                switch(this.StepID)
                case 1
                    l_ValidateStep1(this);
                case 2
                    l_ValidateStep2(this);
                case 3
                    l_ValidateStep3(this,dlg);
                case 4
                    l_ValidateStep4(this,dlg);
                case 5


                    onCleanupObj=onCleanup(@()dlg.showNormal);

                    [filename,pathname]=uiputfile('untitled.xml','Save FPGA Board File');

                    if filename~=0
                        filename=fullfile(pathname,filename);
                        this.hManager.validateNewBoardFile(filename);
                        this.BoardObj.BoardFile=filename;
                    else
                        return;
                    end

                    this.hManager.saveBoard(this.BoardObj,'','');

                    boardmanagergui.updateParentGUI(this.ParentDlg);


                    this.IsDialogFinished=true;
                    delete(onCleanupObj);
                    delete(dlg);
                    return;
                end


                if this.StepID==5
                    this.hValidationDlg.setBoardObj(this.BoardObj);
                end

            catch ME
                this.LastError=ME;
                rethrow(ME);
            end
            dlg.refresh;
        end

    end


    methods(Hidden)

        function dlgStruct=getDialogSchema(this,~)
            if this.FirstTimeIn
                this.WidgetStackItems{1}=l_getBasicInfoWidgets(this);
                this.WidgetStackItems{2}=l_getInterfaceList(this);
                this.WidgetStackItems{3}=l_getEthernetWidgets(this);
                this.WidgetStackItems{4}=l_getUserIoWidgets(this);
                this.WidgetStackItems{5}=this.hValidationDlg.getValidationWidgets;
                this.FirstTimeIn=false;
            end


            switch(this.StepID)
            case 1
                this.WidgetStackItems{this.StepID}=l_getBasicInfoWidgets(this);
                Description=DAStudio.message('EDALink:boardmanagergui:Wizard_Step1_Desc');
            case 2
                if strcmpi(this.hBoardPropertyDlg.ClockType,'Single-Ended')
                    Description=DAStudio.message('EDALink:boardmanagergui:Wizard_Step2_Single_Desc');
                else
                    Description=DAStudio.message('EDALink:boardmanagergui:Wizard_Step2_Diff_Desc');
                end
                this.WidgetStackItems{this.StepID}=l_getInterfaceList(this);
                if~this.RMIIDeprecationDlgDisplayed&&isa(this.getFILInterfaceInst,'eda.internal.boardmanager.RMII')
                    warndlg(DAStudio.message('EDALink:boardmanagergui:XilinxRMIIPHYDeprecate'),'New FPGA Board Wizard');
                    this.RMIIDeprecationDlgDisplayed=true;
                end
            case 3
                Description=this.getFILInterfaceInst.getFormInstruction;
                this.WidgetStackItems{this.StepID}=l_getEthernetWidgets(this);
            case 4
                Description=DAStudio.message('EDALink:boardmanagergui:UserIO_Table_Instruction');
                this.WidgetStackItems{this.StepID}=l_getUserIoWidgets(this);
            case 5
                Description=[DAStudio.message('EDALink:boardmanagergui:Validation_Instruction')...
                ,' ',DAStudio.message('EDALink:boardmanagergui:SkipValidation')];
                this.WidgetStackItems{this.StepID}=this.hValidationDlg.getValidationWidgets;
            end
            this.WidgetStackItems{this.StepID}.Enabled=true;
            WidgetStack.Type='widgetstack';
            WidgetStack.Tag='fpgaWidgetStack';
            WidgetStack.ActiveWidget=this.StepID-1;
            WidgetStack.Items=this.WidgetStackItems;
            WidgetStack.RowSpan=[2,5];
            WidgetStack.ColSpan=[2,10];


            WorkflowSteps={'Basic Information','Interfaces','FIL I/O','Turnkey I/O','Validation'};

            NavigatorItems={};
            row=1;
            for m=1:numel(WorkflowSteps)

                if this.StepID>2
                    if~this.hasFILIO&&m==3
                        continue;
                    elseif~this.HasUserIO&&m==4
                        continue;
                    elseif m==3
                        interfaceName=this.getFILInterfaceName;
                        interfaceInst=eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(interfaceName);
                        if~isa(interfaceInst,'eda.internal.boardmanager.EthInterface')
                            continue;
                        end
                    end
                end
                Status.Type='text';
                if(m==this.StepID)
                    Status.Name='->';
                else
                    Status.Name='';
                end
                Status.RowSpan=[row,row];
                Status.ColSpan=[1,1];
                Status.Tag=sprintf('fpgaStep%d',row);


                Step.Type='text';
                Step.Name=WorkflowSteps{m};
                Step.RowSpan=[row,row];
                Step.ColSpan=[2,5];

                NavigatorItems{end+1}=Status;%#ok<AGROW>
                NavigatorItems{end+1}=Step;%#ok<AGROW>

                row=row+1;
            end

            Navigator.Name='Steps';
            Navigator.Type='group';
            Navigator.Tag='fpgaNavigator';
            Navigator.RowSpan=[1,2];
            Navigator.ColSpan=[1,1];
            Navigator.Items=NavigatorItems;
            Navigator.LayoutGrid=[9,5];

            Text.Type='text';
            Text.Tag='fpgaDescription';
            Text.Name=Description;
            Text.RowSpan=[1,1];
            Text.ColSpan=[1,1];
            Text.WordWrap=true;

            TextGroup.Type='group';
            TextGroup.Tag='fpgaActionGroup';
            TextGroup.Name='Actions';
            TextGroup.RowSpan=[1,1];
            TextGroup.ColSpan=[2,10];
            TextGroup.Items={Text};


            switch this.StepID
            case 1
                Buttons={'Help','Cancel','Next'};
            case{2,3,4}
                Buttons={'Help','Cancel','Back','Next'};
            otherwise
                Buttons={'Help','Cancel','Back','Finish'};
            end
            buttonWidgets=l_getButtonSet(Buttons);

            if this.StepID==5
                for m=1:numel(buttonWidgets.Items)
                    buttonWidgets.Items{m}.Enabled=this.hValidationDlg.EnableButtons;
                end
            end

            buttonWidgets.Enabled=true;
            buttonWidgets.RowSpan=[6,6];
            buttonWidgets.ColSpan=[2,10];


            dlgStruct.DialogTitle='New FPGA Board Wizard';
            dlgStruct.Items=[{Navigator},{TextGroup},WidgetStack,buttonWidgets];
            dlgStruct.LayoutGrid=[6,10];
            dlgStruct.RowStretch=[0,1,1,1,1,0];
            dlgStruct.ColStretch=[0,1,1,1,1,1,1,1,1,1];
            dlgStruct.ShowGrid=false;
            dlgStruct.CloseMethod='saveState';
            dlgStruct.CloseMethodArgs={'%dialog'};
            dlgStruct.CloseMethodArgsDT={'handle'};

            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.Sticky=true;


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end

        function interfaceObj=getFILInterfaceInst(this)
            interfaceObj={};
            FilInterfaceList=eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(...
            this.BoardObj.FPGA.Vendor,this.BoardObj.FPGA.Family);

            if this.EthType<0||this.EthType>numel(FilInterfaceList)-1

                this.EthType=0;
            end
            if~isempty(FilInterfaceList)
                interfaceObj=FilInterfaceList{this.EthType+1};
            end
        end


        function interfaceName=getFILInterfaceName(this)
            interfaceObj=this.getFILInterfaceInst;
            interfaceName=interfaceObj.Name;
        end


        function WidgetGroup=getWidgetGroup(~)
            WidgetGroup.Type='panel';
            WidgetGroup.Name='';
            WidgetGroup.Flat=true;
        end


        function onBack(this,dlg)
            this.StepID=this.StepID-1;


            if(this.StepID==1)
                this.HasUserIO=0;
            end

            if(this.StepID==4)
                if~this.HasUserIO
                    this.StepID=this.StepID-1;
                end
            end

            if(this.StepID==3)
                if~isempty(eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(...
                    this.BoardObj.FPGA.Vendor,this.BoardObj.FPGA.Family))
                    interfaceName=this.getFILInterfaceName;
                    interfaceInst=eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(interfaceName);
                else
                    interfaceInst={};
                end
                if~this.hasFILIO||isa(interfaceInst,'eda.internal.boardmanager.AltJTAG')
                    this.StepID=this.StepID-1;
                end
            end
            dlg.refresh;
        end


        function onBrowse(this,dlg)
            [filename,pathname]=uiputfile('untitled.xml','FPGA Board File');
            if filename~=0
                filename=fullfile(pathname,filename);
                this.BoardFile=filename;
                dlg.refresh;
            end
        end


        function saveState(this,dlg)
            dlg.apply;
            if~this.IsDialogFinished
                Question='Would you like to save the current session so it can be restored later?';
                answer=questdlg(Question,'Save session','Yes','No','Yes');
                if strcmpi(answer,'Yes')
                    mystruct=l_covertDlgToStruct(this,false);
                    setpref('FPGA','NewBoardWizardState',mystruct);
                else
                    setpref('FPGA','NewBoardWizardState',[]);
                end
            end
        end
    end
end

function button=l_getPushButton(Name,ObjectMethod,Position)
    button.Name=Name;
    button.Tag=['fpga',Name,'Btn'];
    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=[1,1];
    button.ColSpan=[Position,Position];
    button.Visible=false;
end

function ButtonSet=l_getButtonSet(buttonNames)
    BtnHelp=l_getPushButton('Help','onHelp',1);
    BtnCancel=l_getPushButton('Cancel','onCancel',2);
    BtnBack=l_getPushButton('< Back','onBack',6);
    BtnNext=l_getPushButton('Next >','onNext',7);
    BtnFinish=l_getPushButton('Finish','onNext',7);

    for m=1:numel(buttonNames)
        switch buttonNames{m}
        case 'Help'
            BtnHelp.Visible=true;
        case 'Cancel'
            BtnCancel.Visible=true;
        case 'Back'
            BtnBack.Visible=true;
        case 'Next'
            BtnNext.Visible=true;
        case 'Finish'
            BtnFinish.Visible=true;
        end
    end

    ButtonSet.Type='panel';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,7];
    ButtonSet.RowStretch=1;
    ButtonSet.ColStretch=[0,0,1,1,1,0,0];
    ButtonSet.Items={BtnHelp,BtnCancel,BtnBack,BtnNext,BtnFinish};
end

function WidgetGroup=l_getBasicInfoWidgets(this)
    rowIndx=1;
    BoardNameEdt.Type='edit';
    BoardNameEdt.Name=[DAStudio.message('EDALink:boardmanagergui:BoardName'),':'];
    BoardNameEdt.Tag='fpgaBoardNameEdt';
    BoardNameEdt.ObjectProperty='BoardName';
    BoardNameEdt.RowSpan=[rowIndx,rowIndx];
    BoardNameEdt.ColSpan=[1,10];
    BoardNameEdt.Mode=true;
    rowIndx=rowIndx+1;
    rowSpan=2;






    DeviceGrp=this.hBoardPropertyDlg.getDeviceWidgets;
    DeviceGrp.ColSpan=[1,10];
    DeviceGrp.RowSpan=[rowIndx,rowIndx+rowSpan];
    rowIndx=rowIndx+rowSpan+1;

    Spacer.Type='text';
    Spacer.Name='';
    Spacer.RowSpan=[rowIndx,10];
    Spacer.ColSpan=[1,10];


    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='fpgaGroupNewBoard';
    WidgetGroup.LayoutGrid=[10,10];
    WidgetGroup.Items={BoardNameEdt,DeviceGrp,Spacer};
end

function WidgetGroup=l_getInterfaceList(this)
    InterfaceList=eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(...
    this.BoardObj.FPGA.Vendor,this.BoardObj.FPGA.Family);
    isTunnkeyEnabled=eda.internal.boardmanager.InterfaceManager.isTurnkeyInterfaceSupported(...
    this.BoardObj.FPGA.Vendor,this.BoardObj.FPGA.Family);
    FilInterfaceList=cellfun(@(x)x.Name,InterfaceList,'uniformoutput',false);
    EthernetChk.Type='checkbox';
    EthernetChk.Name=DAStudio.message('EDALink:boardmanagergui:FILInterface');
    EthernetChk.Tag='fpgaEthernet';
    EthernetChk.RowSpan=[1,1];
    EthernetChk.ColSpan=[1,10];
    EthernetChk.Mode=true;
    EthernetChk.ObjectProperty='hasFILIO';
    EthernetChk.DialogRefresh=true;
    EthernetChk.Enabled=~isempty(FilInterfaceList);

    EthTypeSel.Type='radiobutton';
    EthTypeSel.Name='PHY Interface type:';
    EthTypeSel.Tag='fpgaEthTypeSel';
    EthTypeSel.RowSpan=[2,2];
    EthTypeSel.ColSpan=[2,5];
    EthTypeSel.ObjectProperty='EthType';
    EthTypeSel.Mode=true;
    EthTypeSel.DialogRefresh=true;
    EthTypeSel.Entries=FilInterfaceList;
    EthTypeSel.Visible=~isempty(FilInterfaceList);
    EthTypeSel.Enabled=this.hasFILIO;
    if this.StepID==2&&(this.EthType<0||this.EthType>numel(FilInterfaceList)-1)
        this.EthType=0;
    end

    EthernetNote.Type='text';
    if~isempty(FilInterfaceList)
        EthernetNote.Name=DAStudio.message('EDALink:boardmanagergui:FILNote');
    else
        this.hasFILIO=false;
        EthernetNote.Name=DAStudio.message('EDALink:boardmanager:FamilyNotSupportedByFIL',this.BoardObj.FPGA.Family);
    end
    EthernetNote.RowSpan=[3,3];
    EthernetNote.ColSpan=[1,10];
    EthernetNote.WordWrap=true;

    FilGrp.Type='group';
    FilGrp.Name='FPGA-in-the-Loop Interface';
    FilGrp.RowSpan=[1,4];
    FilGrp.ColSpan=[1,10];
    FilGrp.LayoutGrid=[3,10];
    FilGrp.Items={EthernetChk,EthTypeSel,EthernetNote};

    UserIoChk.Type='checkbox';
    UserIoChk.Name='User-defined I/O';
    UserIoChk.RowSpan=[1,1];
    UserIoChk.ColSpan=[1,10];
    UserIoChk.Mode=true;
    UserIoChk.ObjectProperty='HasUserIO';
    UserIoChk.Enabled=isTunnkeyEnabled;

    UserIoNote.Type='text';
    UserIoNote.Name=DAStudio.message('EDALink:boardmanagergui:TurnkeyNote');
    UserIoNote.RowSpan=[2,2];
    UserIoNote.ColSpan=[1,10];
    UserIoNote.WordWrap=true;

    TurnkeyGrp.Type='group';
    TurnkeyGrp.Name='FPGA Turnkey Interface';
    TurnkeyGrp.RowSpan=[5,6];
    TurnkeyGrp.ColSpan=[1,10];
    TurnkeyGrp.LayoutGrid=[1,10];
    TurnkeyGrp.Items={UserIoChk,UserIoNote};

    PinAssignGrp=this.hBoardPropertyDlg.getPinAssignWidgets;
    PinAssignGrp.RowSpan=[7,9];
    PinAssignGrp.ColSpan=[1,10];



    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='fpgaGroupNewBoard';
    WidgetGroup.LayoutGrid=[9,10];
    WidgetGroup.RowStretch=ones(1,9);
    WidgetGroup.ColStretch=[0,ones(1,9)];
    WidgetGroup.Items={FilGrp,TurnkeyGrp,PinAssignGrp};
end

function WidgetGroup=l_getEthernetWidgets(this)
    interfaceObj=this.getFILInterfaceInst;
    if this.hInterfaceDlgs.isKey(class(interfaceObj))
        ethDlg=this.hInterfaceDlgs(class(interfaceObj));
    else
        ethDlg=boardmanagergui.InterfaceEditor(interfaceObj);
        this.hInterfaceDlgs(class(interfaceObj))=ethDlg;
    end
    EthSignals=ethDlg.getSignalTableWidgets;

    EthSignals.RowSpan=[1,9];
    EthSignals.ColSpan=[1,10];

    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.LayoutGrid=[9,10];
    WidgetGroup.RowStretch=[1,ones(1,8)];
    WidgetGroup.ColStretch=[0,ones(1,9)];
    WidgetGroup.Items={EthSignals};

end

function WidgetGroup=l_getUserIoWidgets(this)
    UserIO=this.hUserIoDlg.getSignalTableWidgets;
    UserIO.RowSpan=[1,9];
    UserIO.ColSpan=[1,10];

    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.LayoutGrid=[9,10];
    WidgetGroup.RowStretch=[1,ones(1,8)];
    WidgetGroup.ColStretch=[0,ones(1,9)];
    WidgetGroup.Items={UserIO};
end


function l_ValidateStep1(this)
    this.hManager.validateNewBoardName(this.BoardName);
    this.BoardObj.BoardName=this.BoardName;

    this.BoardObj.FPGA.Vendor=this.hBoardPropertyDlg.Vendor;
    this.BoardObj.FPGA.Family=this.hBoardPropertyDlg.Family;
    this.BoardObj.FPGA.Device=this.hBoardPropertyDlg.Device;
    this.BoardObj.FPGA.Package=this.hBoardPropertyDlg.Package;
    this.BoardObj.FPGA.Speed=this.hBoardPropertyDlg.Speed;
    this.BoardObj.FPGA.JTAGChainPosition=round(str2double(this.hBoardPropertyDlg.ChainPos));


    this.StepID=2;
end

function l_ValidateStep2(this)
    if~this.hasFILIO&&~this.HasUserIO
        error(message('EDALink:boardmanagergui:NoSelectedInterface'));
    end

    this.hBoardPropertyDlg.saveBasicInfo(true);

    if this.hasFILIO
        this.hBoardPropertyDlg.BoardObj.FPGA.removeFILInterface;

        FilInterfaceList=eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(...
        this.BoardObj.FPGA.Vendor,this.BoardObj.FPGA.Family);
        selectedInterfaceObj=FilInterfaceList{this.EthType+1};
        this.hBoardPropertyDlg.BoardObj.FPGA.addInterface(selectedInterfaceObj);
        this.hBoardPropertyDlg.BoardObj.FPGA.validateFPGAFamilyForFIL;
        if isa(selectedInterfaceObj,'eda.internal.boardmanager.EthInterface')
            if selectedInterfaceObj.isGigaEthInterface
                this.hBoardPropertyDlg.BoardObj.FPGA.getClock.validateGigaEthFreq;
            end
            this.StepID=3;
        elseif isa(selectedInterfaceObj,'eda.internal.boardmanager.DigilentJTAG')
            this.StepID=3;
        else
            if this.HasUserIO
                this.StepID=4;
            else
                this.StepID=5;
            end
        end
    else
        this.hBoardPropertyDlg.BoardObj.FPGA.removeFILInterface;
        this.StepID=4;
    end

    if~this.HasUserIO
        this.hBoardPropertyDlg.BoardObj.FPGA.removeTurnkeyInterface;
    end
end

function l_ValidateStep3(this,dlg)
    interfaceName=class(this.getFILInterfaceInst);
    ethDlg=this.hInterfaceDlgs(interfaceName);
    newInterface=ethDlg.getNewInterfaceFromTable(dlg);
    this.BoardObj.FPGA.setInterface(newInterface);
    if this.HasUserIO
        this.StepID=4;
    else
        this.StepID=5;
    end
end

function l_ValidateStep4(this,dlg)
    newInterface=this.hUserIoDlg.getNewInterfaceFromTable(dlg);
    this.BoardObj.FPGA.setInterface(newInterface);
    this.StepID=5;
end


function r=l_covertDlgToStruct(this,final)
    pkg=findpackage('boardmanagergui');
    tmp=textscan(class(this),'boardmanagergui.%s');
    cls=findclass(pkg,tmp{1}{1});
    props=cls.Properties;

    for m=1:numel(props)
        propname=props(m).Name;

        if final==true&&strcmp(propname,'SignalCell')
            r.(propname)=this.(propname);
            continue;
        end
        switch props(m).DataType
        case{'int','string','bool'}
            if strcmpi(props(m).AccessFlags.PublicSet,'on')
                r.(propname)=this.(propname);
            end
        case 'handle'
            if~final
                classname=class(this.(propname));
                if any(strcmpi(classname,...
                    {'boardmanagergui.FPGABoardEditor','boardmanagergui.InterfaceEditor','boardmanagergui.BoardValidation'}))
                    r.(propname)=l_covertDlgToStruct(this.(propname),true);
                end
            end
        end
    end
end

