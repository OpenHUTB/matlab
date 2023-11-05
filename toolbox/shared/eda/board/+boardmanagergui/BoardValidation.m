classdef BoardValidation<handle
    properties(SetAccess=protected,SetObservable)

        BoardObj=[];
    end

    properties(SetObservable)

        TurnkeyBoardObj=[];

        ParentDlg=[];

        LastError=[];

        IsFirstRun(1,1)logical=false;

        RunFilTest(1,1)logical=false;

        RunTurnkeyTest(1,1)logical=false;

        FilTestStatus{matlab.internal.validation.mustBeASCIICharRowVector(FilTestStatus,'FilTestStatus')}='';

        TurnkeyTestStatus{matlab.internal.validation.mustBeASCIICharRowVector(TurnkeyTestStatus,'TurnkeyTestStatus')}='';

        EnableFILTest(1,1)logical=false;

        EnableTurnkeyTest(1,1)logical=false;

        TestLog{matlab.internal.validation.mustBeCharRowVector(TestLog,'TestLog')}='';

        EnableButtons(1,1)logical=false;

        RunFILProgramming(1,1)logical=false;

        LEDSelect{matlab.internal.validation.mustBeASCIICharRowVector(LEDSelect,'LEDSelect')}='';

        ConnectionSelection(1,1)int8{mustBeReal}=0;

        IpAddrByte1{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte1,'IpAddrByte1')}='';

        IpAddrByte2{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte2,'IpAddrByte2')}='';

        IpAddrByte3{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte3,'IpAddrByte3')}='';

        IpAddrByte4{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte4,'IpAddrByte4')}='';

        WorkDir{matlab.internal.validation.mustBeASCIICharRowVector(WorkDir,'WorkDir')}='';
    end


    methods
        function this=BoardValidation(varargin)

            this.FilTestStatus='notrun';
            this.TurnkeyTestStatus='notrun';
            this.RunFILProgramming=false;
            this.IpAddrByte1='192';
            this.IpAddrByte2='168';
            this.IpAddrByte3='0';
            this.IpAddrByte4='2';
            this.EnableButtons=true;
            this.EnableFILTest=true;
            this.EnableTurnkeyTest=true;
            this.IsFirstRun=true;
            this.WorkDir='';
        end
    end

    methods
        function set.IsFirstRun(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsFirstRun')
            value=logical(value);
            obj.IsFirstRun=value;
        end

        function set.RunFilTest(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','RunFilTest')
            value=logical(value);
            obj.RunFilTest=value;
        end

        function set.RunTurnkeyTest(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','RunTurnkeyTest')
            value=logical(value);
            obj.RunTurnkeyTest=value;
        end

        function set.FilTestStatus(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','FilTestStatus')
            obj.FilTestStatus=value;
        end

        function set.TurnkeyTestStatus(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','TurnkeyTestStatus')
            obj.TurnkeyTestStatus=value;
        end

        function set.EnableFILTest(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','EnableFILTest')
            value=logical(value);
            obj.EnableFILTest=value;
        end

        function set.EnableTurnkeyTest(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','EnableTurnkeyTest')
            value=logical(value);
            obj.EnableTurnkeyTest=value;
        end

        function set.TestLog(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','TestLog')
            obj.TestLog=value;
        end

        function set.EnableButtons(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','EnableButtons')
            value=logical(value);
            obj.EnableButtons=value;
        end

        function set.RunFILProgramming(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','RunFILProgramming')
            value=logical(value);
            obj.RunFILProgramming=value;
        end

        function set.LEDSelect(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','LEDSelect')
            obj.LEDSelect=value;
        end

        function set.ConnectionSelection(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','ConnectionSelection')
            value=round(value);
            obj.ConnectionSelection=value;
        end

        function set.IpAddrByte1(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','IpAddrByte1')
            obj.IpAddrByte1=value;
        end

        function set.IpAddrByte2(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','IpAddrByte2')
            obj.IpAddrByte2=value;
        end

        function set.IpAddrByte3(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','IpAddrByte3')
            obj.IpAddrByte3=value;
        end

        function set.IpAddrByte4(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','IpAddrByte4')
            obj.IpAddrByte4=value;
        end

        function set.WorkDir(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.WorkDir=value;
        end
    end

    methods(Hidden)

        function dlgStruct=getDialogSchema(this,~)
            Text.Type='text';
            Text.Tag='edaText';

            Text.Name=DAStudio.message('EDALink:boardmanagergui:Validation_Instruction');
            Text.Visible=true;
            Text.RowSpan=[1,1];
            Text.ColSpan=[1,1];
            Text.Mode=1;
            Text.WordWrap=true;

            TextGroup.Type='group';
            TextGroup.Tag='fpgaTextGroup';
            TextGroup.Name='Actions';
            TextGroup.Visible=true;
            TextGroup.RowSpan=[1,1];
            TextGroup.ColSpan=[1,8];
            TextGroup.Items={Text};

            WidgetGroup=this.getValidationWidgets(false);
            WidgetGroup.RowSpan=[2,9];
            WidgetGroup.ColSpan=[1,8];

            OkBtn=l_getPushButton('OK','fpgaOK','onOK',[10,10],[7,7],this.EnableButtons);
            HelpBtn=l_getPushButton('Help','fpgaHelp','onHelp',[10,10],[8,8],this.EnableButtons);


            dlgStruct.DialogTitle=sprintf('Validate FPGA Board - %s',...
            this.BoardObj.BoardName);
            dlgStruct.Items={TextGroup,WidgetGroup,OkBtn,HelpBtn};
            dlgStruct.LayoutGrid=[10,8];
            dlgStruct.RowStretch=[ones(1,9),0];
            dlgStruct.ColStretch=ones(1,8);
            dlgStruct.ShowGrid=false;

            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.Sticky=true;


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end


        function WidgetGroup=getValidationWidgets(this,~)
            [FilStatus,FilIcon]=getStatusIconTxt(this.FilTestStatus);

            FilTestChk.Type='checkbox';
            FilTestChk.Name=DAStudio.message('EDALink:boardmanagergui:RunFILTest');
            FilTestChk.Tag='fpgaRunFILTest';
            FilTestChk.ObjectProperty='RunFilTest';
            FilTestChk.Mode=true;
            FilTestChk.RowSpan=[1,1];
            FilTestChk.ColSpan=[1,10];
            FilTestChk.Source=this;
            FilTestChk.Enabled=this.EnableButtons;
            FilTestChk.DialogRefresh=true;




            Connection=this.BoardObj.getFILConnectionOptions;
            ConnComboBox.Type='combobox';
            ConnComboBox.Tag='fpgaConnection';
            ConnComboBox.Mode=true;
            ConnComboBox.Name='Connection:';
            ConnComboBox.Entries=cellfun(@(x)x.Name,Connection,'UniformOutput',false);
            ConnComboBox.RowSpan=[2,2];
            ConnComboBox.ColSpan=[2,5];
            ConnComboBox.Enabled=FilTestChk.Enabled;
            ConnComboBox.DialogRefresh=true;
            ConnComboBox.ObjectProperty='ConnectionSelection';

            if isempty(Connection)
                showIPWidget=true;
            else
                showIPWidget=strcmpi(Connection{this.ConnectionSelection+1}.RTIOStreamLibName,'mwrtiostreamtcpip');
                ConnectionSel=Connection{this.ConnectionSelection+1};
            end
            Step234Chk.Type='checkbox';
            Step234Chk.Tag='fpgaFILTestStep234Chk';
            Step234Chk.Name='';
            Step234Chk.RowSpan=[3,3];
            Step234Chk.ColSpan=[2,2];
            Step234Chk.ObjectProperty='RunFILProgramming';
            Step234Chk.Source=this;
            Step234Chk.Mode=true;
            Step234Chk.Enabled=this.EnableButtons&&this.RunFilTest;



            Step234Chk.DialogRefresh=true;

            Step234Desc.Type='text';
            if isempty(Connection)
                Step234Desc.Name=DAStudio.message('EDALink:boardmanagergui:FILTest_Step234_Desc','JTAG');
            else
                Step234Desc.Name=DAStudio.message('EDALink:boardmanagergui:FILTest_Step234_Desc',ConnectionSel.Name);
            end
            Step234Desc.RowSpan=[3,3];
            Step234Desc.ColSpan=[3,20];
            Step234Desc.WordWrap=true;

            IpAddrTxt.Type='text';
            IpAddrTxt.Tag='fpgaIpAddrTxt';
            IpAddrTxt.Name=DAStudio.message('EDALink:boardmanagergui:BoardIPAddress');
            IpAddrTxt.RowSpan=[4,4];
            IpAddrTxt.ColSpan=[3,4];

            IpAddrWidget=l_getIpAddrWidget(this);
            IpAddrWidget.RowSpan=[4,4];
            IpAddrWidget.ColSpan=[5,8];
            IpAddrWidget.Enabled=this.RunFILProgramming&&this.EnableButtons&&this.RunFilTest&&showIPWidget;

            FilTestImg.Type='image';
            FilTestImg.Name='Status:';
            FilTestImg.FilePath=FilIcon;
            FilTestImg.RowSpan=[5,5];
            FilTestImg.ColSpan=[1,1];

            FilTestStatus.Type='text';
            FilTestStatus.Name=['Result: ',FilStatus];
            FilTestStatus.RowSpan=[6,6];
            FilTestStatus.ColSpan=[2,20];
            FilTestStatus.WordWrap=true;

            FilTestGroup.Type='group';
            FilTestGroup.Name=DAStudio.message('EDALink:boardmanagergui:FILTest');
            FilTestGroup.RowSpan=[2,2];
            FilTestGroup.ColSpan=[1,10];
            FilTestGroup.LayoutGrid=[5,20];

            if isempty(Connection)||strcmpi(ConnectionSel.Name,'JTAG')
                FilTestGroup.Items={FilTestChk,ConnComboBox,FilTestImg,...
                Step234Chk,Step234Desc,FilTestStatus};
            else
                FilTestGroup.Items={FilTestChk,ConnComboBox,FilTestImg,...
                Step234Chk,Step234Desc,IpAddrTxt,IpAddrWidget,FilTestStatus};
            end

            FilTestGroup.Enabled=this.EnableFILTest;


            [TurnkeyStatus,TurnkeyIcon]=getStatusIconTxt(this.TurnkeyTestStatus);

            TurnkeyTestChk.Type='checkbox';
            TurnkeyTestChk.Name=DAStudio.message('EDALink:boardmanagergui:RunTurnkeyTest');
            TurnkeyTestChk.RowSpan=[1,1];
            TurnkeyTestChk.ColSpan=[1,10];
            TurnkeyTestChk.ObjectProperty='RunTurnkeyTest';
            TurnkeyTestChk.Mode=true;
            TurnkeyTestChk.Tag='fpgaRunTurnkeyTest';
            TurnkeyTestChk.Source=this;
            TurnkeyTestChk.Enabled=this.EnableButtons;



            TurnkeyTestChk.DialogRefresh=true;

            TurnkeyTestDesc.Type='text';
            TurnkeyTestDesc.Name=DAStudio.message('EDALink:boardmanagergui:Turnkey_Test_Desc');
            TurnkeyTestDesc.RowSpan=[2,2];
            TurnkeyTestDesc.ColSpan=[1,10];
            TurnkeyTestDesc.WordWrap=true;

            TurnkeyLedSelect.Type='combobox';
            TurnkeyLedSelect.Tag='fpgaTurnkeyLEDSelect';
            TurnkeyLedSelect.Name=DAStudio.message('EDALink:boardmanagergui:SelectOutputLed');
            TurnkeyLedSelect.RowSpan=[3,3];
            TurnkeyLedSelect.ColSpan=[3,5];
            if this.EnableTurnkeyTest

                this.TurnkeyBoardObj.populateRAWINOUTInterfaceIDList;
                list=this.TurnkeyBoardObj.getOutputInterfaceIDList;
                TurnkeyLedSelect.Entries=list(1:end);
                if~ismember(this.LEDSelect,TurnkeyLedSelect.Entries)
                    this.LEDSelect=TurnkeyLedSelect.Entries{1};
                end
            else
                TurnkeyLedSelect.Entries={''};
            end
            TurnkeyLedSelect.Enabled=this.EnableButtons&&this.RunTurnkeyTest;
            TurnkeyLedSelect.ObjectProperty='LEDSelect';
            TurnkeyLedSelect.Mode=true;


            TurnkeyTestImg.Type='image';
            TurnkeyTestImg.FilePath=TurnkeyIcon;
            TurnkeyTestImg.RowSpan=[4,4];
            TurnkeyTestImg.ColSpan=[1,1];

            TurnkeyTestStatus.Type='text';
            TurnkeyTestStatus.Name=['Result: ',TurnkeyStatus];
            TurnkeyTestStatus.RowSpan=[4,4];
            TurnkeyTestStatus.ColSpan=[2,10];

            TurnkeyTestGroup.Type='group';
            TurnkeyTestGroup.Name=DAStudio.message('EDALink:boardmanagergui:TurnkeyTest');
            TurnkeyTestGroup.RowSpan=[3,3];
            TurnkeyTestGroup.ColSpan=[1,10];
            TurnkeyTestGroup.LayoutGrid=[3,10];
            TurnkeyTestGroup.Items={TurnkeyTestChk,TurnkeyTestDesc,TurnkeyLedSelect,TurnkeyTestImg,TurnkeyTestStatus};
            TurnkeyTestGroup.ColStretch=zeros(1,10);
            TurnkeyTestGroup.Enabled=this.EnableTurnkeyTest;

            RunBtn.Type='pushbutton';
            RunBtn.Tag='fpgaRunSelectedTest';
            RunBtn.Name=DAStudio.message('EDALink:boardmanagergui:RunSelectedTest');
            RunBtn.RowSpan=[4,4];
            RunBtn.ColSpan=[9,10];
            RunBtn.ObjectMethod='onValidate';
            RunBtn.MethodArgs={'%dialog'};
            RunBtn.ArgDataTypes={'handle'};
            RunBtn.Source=this;
            RunBtn.Enabled=this.EnableButtons;

            LogBrowser.Type='textbrowser';
            LogBrowser.Tag='fpgaLogBrowser';
            LogBrowser.RowSpan=[5,5];
            LogBrowser.ColSpan=[1,10];
            LogBrowser.Visible=true;
            LogBrowser.Enabled=true;
            LogBrowser.Text=this.TestLog;

            WidgetGroup.Type='panel';
            WidgetGroup.Name='';
            WidgetGroup.Items={FilTestGroup,TurnkeyTestGroup,RunBtn,LogBrowser};
            WidgetGroup.LayoutGrid=[5,10];
            WidgetGroup.RowStretch=[0,1,1,0,1];
            WidgetGroup.ColStretch=ones(1,10);
        end


        function onHelp(~,~)
            eda.internal.boardmanager.helpview('FPGABoard_Validation');
        end

        function onOK(~,dlg)
            delete(dlg);
        end


        function onValidate(this,dlg)
            this.TestLog=[DAStudio.message('EDALink:boardmanagergui:ValidationStop'),'<br>'];
            try
                this.EnableButtons=false;
                onCleanupObj=onCleanup(@()l_onCleanupFcn(this,dlg));

                if~this.RunFilTest&&~this.RunTurnkeyTest
                    error(message('EDALink:boardmanagergui:NoTestSelected'));
                end

                if this.IsFirstRun
                    answer=questdlg(DAStudio.message('EDALink:boardmanagergui:Validation_Confirmation'),...
                    DAStudio.message('EDALink:boardmanagergui:Confirmation'),...
                    DAStudio.message('EDALink:boardmanagergui:Yes'),...
                    DAStudio.message('EDALink:boardmanagergui:No'),...
                    DAStudio.message('EDALink:boardmanagergui:No'));
                    if~strcmpi(answer,DAStudio.message('EDALink:boardmanagergui:Yes'))
                        return;
                    else

                        this.IsFirstRun=false;
                    end
                end

                if this.RunFilTest
                    l_runFilTest(this,dlg);
                end
                if this.RunTurnkeyTest
                    l_runTurnkeyTest(this,dlg);
                end
                delete(onCleanupObj);

            catch ME
                this.LastError=ME;
                msg=strrep(ME.message,char(10),'<br>');
                this.TestLog=[this.TestLog,'Error:',msg];
                dlg.refresh;
            end
        end


        function setBoardObj(this,boardObj)
            this.BoardObj=boardObj;
            [this.EnableFILTest,status]=l_isFILTestSupported(this.BoardObj);

            if~this.EnableFILTest
                this.FilTestStatus=['Not available (',status,')'];
            else
                this.FilTestStatus='notrun';
            end

            [this.EnableTurnkeyTest,status]=l_isTurnkeyTestSupported(boardObj);

            if~this.EnableTurnkeyTest
                this.TurnkeyTestStatus=['Not available (',status,')'];
            else
                if isempty(boardObj.TurnkeyBoardClass)
                    this.TurnkeyBoardObj=...
                    eda.internal.boardmanager.convertToTurnkeyObject(this.BoardObj);
                else
                    this.TurnkeyBoardObj=eval(boardObj.TurnkeyBoardClass);
                end
                this.TurnkeyTestStatus='notrun';
            end
        end
    end
end

function button=l_getPushButton(Name,Tag,ObjectMethod,RowSpan,ColSpan,isEnabled)
    button.Name=Name;
    button.Tag=Tag;

    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=RowSpan;
    button.ColSpan=ColSpan;
    button.Enabled=isEnabled;
end
function IpAddrWidget=l_getIpAddrWidget(this)
    IpAddrByte=cell(1,4);
    Dot=cell(1,3);
    NumCols=11;
    ColSpan=1;
    ColStretch=ones(1,NumCols);
    pf=getpixunit;
    for m=1:4
        IpAddrByte{m}.Type='edit';
        IpAddrByte{m}.Tag=['fpgaIpAddrByte',num2str(m)];
        IpAddrByte{m}.RowSpan=[1,1];
        IpAddrByte{m}.ColSpan=[ColSpan,ColSpan];
        IpAddrByte{m}.Mode=1;
        IpAddrByte{m}.ObjectProperty=['IpAddrByte',num2str(m)];
        IpAddrByte{m}.Source=this;

        IpAddrByte{m}.MaximumSize=[80,60]*pf;
        IpAddrByte{m}.Tag=['fpgaIpAddrByte',num2str(m)];
        ColSpan=ColSpan+1;
        if(m~=4)
            Dot{m}.Type='text';
            Dot{m}.Tag=['fpgaIpDotTxt',num2str(m)];
            Dot{m}.Name='.';
            Dot{m}.FontPointSize=8;
            Dot{m}.RowSpan=[1,1];
            Dot{m}.ColSpan=[ColSpan,ColSpan]*pf;
            Dot{m}.MaximumSize=[15,15]*pf;
            ColStretch(ColSpan)=0;
            ColSpan=ColSpan+1;
        end
    end

    IpAddrWidget.Type='panel';
    IpAddrWidget.Tag='fpgaIpAddrPanel';
    IpAddrWidget.LayoutGrid=[1,NumCols];
    IpAddrWidget.ColStretch=ColStretch;
    IpAddrWidget.Items=[IpAddrByte,Dot];
end

function pf=getpixunit

    if isunix
        pf=1;
    else
        pf=get(0,'screenpixelsperinch')/96;
    end
end

function[StatusTxt,StatusIcon]=getStatusIconTxt(status)
    BaseResourcePath=fullfile(matlabroot,'toolbox','shared','eda','board','resources');
    IconNotRun=fullfile(BaseResourcePath,'check_notrun.png');
    IconFailed=fullfile(BaseResourcePath,'check_failed.png');
    IconDisabled=fullfile(BaseResourcePath,'check_disabled.png');
    IconPassed=fullfile(BaseResourcePath,'check_passed.png');

    switch status
    case 'passed'
        StatusTxt='Passed';
        StatusIcon=IconPassed;
    case 'failed'
        StatusTxt='Failed';
        StatusIcon=IconFailed;
    case 'running'
        StatusTxt='Running';
        StatusIcon=IconNotRun;
    case 'notrun'
        StatusTxt='Not Run';
        StatusIcon=IconNotRun;
    otherwise
        StatusTxt=status;
        StatusIcon=IconDisabled;
    end
end



function l_onCleanupFcn(this,dlg)
    this.EnableButtons=true;
    dlg.refresh;
end

function l_runTurnkeyTest(this,dlg)
    try
        this.TestLog=[this.TestLog,DAStudio.message('EDALink:boardmanagergui:ValidationStartingTurnkeyTest'),'<br>'];
        this.TurnkeyTestStatus='running';

        l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationCompilation'));

        turnkeyTest=eda.internal.boardmanager.TurnkeyUnitTest(this.TurnkeyBoardObj,this.LEDSelect);
        turnkeyTest.generateProgrammingFile;
        l_addPassedStr(this);

        l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationProgram'));
        turnkeyTest.programFPGA;
        l_addPassedStr(this);

    catch ME
        l_addFailedStr(this);
        this.TurnkeyTestStatus='failed';
        rethrow(ME);
    end
    this.TurnkeyTestStatus='passed';
    dlg.refresh;
end

function l_runFilTest(this,dlg)

    if~this.RunFILProgramming
        ipAddress='192.168.0.2';
    else
        ipAddress=sprintf('%s.%s.%s.%s',...
        this.IpAddrByte1,this.IpAddrByte2,this.IpAddrByte3,this.IpAddrByte4);
    end

    Connection=this.BoardObj.getFILConnectionOptions;
    ConnectionSel=Connection{this.ConnectionSelection+1};
    filTest=eda.internal.boardmanager.FILUnitTest(this.BoardObj,ConnectionSel,ipAddress);

    try
        this.TestLog=[this.TestLog,DAStudio.message('EDALink:boardmanagergui:ValidationStartingFILTest'),'<br>'];
        this.FilTestStatus='running';
        l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationCompilation'))
        dlg.refresh;
        filTest.generateProgrammingFile(this.WorkDir);
        l_addPassedStr(this);

        if this.RunFILProgramming
            l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationProgram'));
            filTest.programFPGA;
            l_addPassedStr(this);

            if filTest.isEthernet
                l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationCheckConnection'));
                filTest.checkConnection;
                l_addPassedStr(this);
            end

            l_addLog(this,dlg,DAStudio.message('EDALink:boardmanagergui:ValidationFILSimulation'));
            filTest.runSimulation;
            l_addPassedStr(this);
        end

    catch ME
        l_addFailedStr(this);
        this.FilTestStatus='failed';
        rethrow(ME);
    end

    this.FilTestStatus='passed';
    dlg.refresh;
end

function l_addLog(this,dlg,msg)
    this.TestLog=[this.TestLog,msg];
    dlg.refresh;
end

function l_addPassedStr(this)
    this.TestLog=[this.TestLog,DAStudio.message('EDALink:boardmanagergui:Passed'),'<br>'];
end

function l_addFailedStr(this)
    this.TestLog=[this.TestLog,DAStudio.message('EDALink:boardmanagergui:Failed'),'<br>'];
end

function[isSupported,desc]=l_isFILTestSupported(boardObj)
    isSupported=true;
    desc='';
    if~boardObj.isFILCompatible
        desc=[desc,'No defined FIL communication interface.'];
        isSupported=false;
    end

    if~eda.internal.boardmanager.isHDLVerifierAvailable
        desc=[desc,'HDL Verifier is not available.'];
        isSupported=false;
    end
end

function[isSupported,desc]=l_isTurnkeyTestSupported(boardObj)
    isSupported=true;
    desc='';
    if~boardObj.isTurnkeyCompatible
        desc=[desc,'No user-defined interface.'];
        isSupported=false;
    end

    if~eda.internal.boardmanager.isHDLCoderAvailable
        desc=[desc,'HDL Coder is not available.'];
        isSupported=false;
    end
end


