classdef ConnectHardware<soc.ui.TemplateBaseWithSteps

    properties
Description
DetailsContainer
IPAddressLabel
IPAddressOctet1
IPAddressOctet2
IPAddressOctet3
IPAddressOctet4
UsernameLabel
Username
PasswordLabel
Password
PortLabel
Port
TestConnectionLabel
TestConnection
    end

    methods
        function this=ConnectHardware(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.DetailsContainer=matlab.hwmgr.internal.hwsetup.Panel.getInstance(this.ContentPanel);
            this.IPAddressLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.IPAddressOctet1=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.IPAddressOctet2=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.IPAddressOctet3=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.IPAddressOctet4=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.UsernameLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.Username=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.PasswordLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.Password=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.PortLabel=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.Port=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
            this.TestConnectionLabel=matlab.hwmgr.internal.hwsetup.HTMLText.getInstance(this.ContentPanel);
            this.TestConnection=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);
            this.setCurrentStep(4);
            [usr,passw,ipaddr]=getBoardParametersFromTopModel(this);
            ipaddrOctets=regexp(ipaddr,'\.','split');

            this.Title.Text=message('soc:workflow:ConnectHardware_Title').getString();

            this.Description.Text=message('soc:workflow:ConnectHardware_Description').getString();
            this.Description.shiftVertically(220);
            this.Description.addWidth(350);
            this.Description.addHeight(50);

            this.DetailsContainer.Title='';
            this.DetailsContainer.TitlePosition='lefttop';
            this.DetailsContainer.Position=[20,170,435,145];

            this.IPAddressLabel.Text=message('soc:workflow:ConnectHardware_IPAddress').getString();
            this.IPAddressLabel.Position(1)=30;
            this.IPAddressLabel.Position(2)=this.Description.Position(2)-10;
            this.IPAddressLabel.addWidth(50);

            this.IPAddressOctet1.Text=ipaddrOctets{1};
            this.IPAddressOctet1.Position=[120,this.Description.Position(2)-10,35,20];
            this.IPAddressOctet1.TextAlignment='center';

            this.IPAddressOctet2.Text=ipaddrOctets{2};
            this.IPAddressOctet2.Position=[165,this.Description.Position(2)-10,35,20];
            this.IPAddressOctet2.TextAlignment='center';

            this.IPAddressOctet3.Text=ipaddrOctets{3};
            this.IPAddressOctet3.Position=[205,this.Description.Position(2)-10,35,20];
            this.IPAddressOctet3.TextAlignment='center';

            this.IPAddressOctet4.Text=ipaddrOctets{4};
            this.IPAddressOctet4.Position=[245,this.Description.Position(2)-10,35,20];
            this.IPAddressOctet4.TextAlignment='center';

            this.UsernameLabel.Text=message('soc:workflow:ConnectHardware_Username').getString();
            this.UsernameLabel.Position(1)=30;
            this.UsernameLabel.Position(2)=this.IPAddressLabel.Position(2)-30;
            this.UsernameLabel.addWidth(50);

            this.Username.Text=usr;
            this.Username.Position=[120,this.IPAddressOctet4.Position(2)-30,105,20];

            this.PasswordLabel.Text=message('soc:workflow:ConnectHardware_Password').getString();
            this.PasswordLabel.Position(1)=30;
            this.PasswordLabel.Position(2)=this.UsernameLabel.Position(2)-30;
            this.PasswordLabel.addWidth(50);

            this.Password.Text=passw;
            this.Password.Position=[120,this.Username.Position(2)-30,105,20];

            this.PortLabel.Text=message('soc:workflow:ConnectHardware_Port').getString();
            this.PortLabel.Position(1)=30;
            this.PortLabel.Position(2)=this.PasswordLabel.Position(2)-30;
            this.PortLabel.addWidth(50);

            this.Port.Text='22';
            this.Port.Position=[120,this.Password.Position(2)-30,50,20];

            this.TestConnectionLabel.Text=message('soc:workflow:ConnectHardware_TestConnectionLabel').getString();
            this.TestConnectionLabel.Position=[20,10,320,100];
            this.TestConnection.ButtonPushedFcn=@this.testConnectionCB;

            this.TestConnection.Text='Test Connection';
            this.TestConnection.Position(2)=this.Port.Position(2)-75;
            this.TestConnection.addHeight(2);
            this.TestConnection.addWidth(20);
            this.TestConnection.Position(1)=335;
            this.TestConnection.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.TestConnection.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;

            this.NextButton.Enable='off';
            this.HelpText.WhatToConsider=message('soc:workflow:ConnectHardware_WhatToConsider').getString();
            this.HelpText.AboutSelection='';
            this.HelpText.Additional=message('soc:workflow:ConnectHardware_Additional').getString();
        end
        function screen=getPreviousScreenID(this)
            if this.Workflow.LoadExisting
                screen='soc.ui.SelectProjectFolder';
            else
                if strcmpi(this.Workflow.ModelType,'arm')&&this.Workflow.BuildAction==this.Workflow.OpenExternalModeModel
                    screen='soc.ui.ValidateModel';
                else
                    screen='soc.ui.BuildModel';
                end
            end
        end

        function screen=getNextScreenID(~)
            screen='soc.ui.LoadAndRun';
        end

        function resetScreen(this)
            this.TestConnection.Enable='on';
            statusIconBusy=matlab.hwmgr.internal.hwsetup.StatusIcon(5).dispIcon;
            statusIconFail=matlab.hwmgr.internal.hwsetup.StatusIcon(0).dispIcon;
            if contains(this.TestConnectionLabel.Text,statusIconBusy)
                this.TestConnectionLabel.Text=strrep(this.TestConnectionLabel.Text,statusIconBusy,statusIconFail);
            end
        end
    end

    methods(Access=private)
        function[usr,pass,ipaddr]=getBoardParametersFromTopModel(this)
            hw=codertarget.targethardware.getTargetHardwareFromName(...
            this.Workflow.HardwareBoard);
            boardPrefName=hw.getPreferenceName;
            if~isempty(boardPrefName)
                hwBoard=remotetarget.util.BoardParameters(boardPrefName);
                if ispref(strcat(hwBoard.GROUP,'_',boardPrefName))



                    [ipaddr,usr,pass,~]=hwBoard.getBoardParameters();
                    return
                end
            end



            hCS=getActiveConfigSet(this.Workflow.sys);
            usr=codertarget.data.getParameterValue(hCS,...
            'BoardParameters.Username');
            pass=codertarget.data.getParameterValue(hCS,...
            'BoardParameters.Password');
            ipaddr=codertarget.data.getParameterValue(hCS,...
            'BoardParameters.DeviceAddress');
        end

        function testConnectionCB(this,~,~)
            this.NextButton.Enable='off';
            this.TestConnection.Enable='off';
            turnOnTestConn=onCleanup(@()resetScreen(this));
            statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(5);
            progressIcon=statusIcon.dispIcon();
            devAddr=this.getDeviceAddress();
            usrn=this.Username.Text;
            passw=this.Password.Text;
            sshPort=this.Port.Text;
            this.TestConnectionLabel.Text=[progressIcon,'&nbsp;&nbsp;',message('soc:os:Pinging').getString];
            hwInterface=this.Workflow.HWInterfaceObj;
            success=pingHardware(hwInterface,devAddr);
            if~success
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(0);
                failureIcon=statusIcon.dispIcon();
                progressText=message('soc:os:PingFailure',devAddr).getString;
                this.TestConnectionLabel.Text=[failureIcon,'&nbsp;&nbsp;',progressText];
                return;
            end
            this.TestConnectionLabel.Text=[progressIcon,'&nbsp;&nbsp;',message('soc:os:SSHConnect').getString];
            success=connectHardware(hwInterface,devAddr,usrn,passw,'SSHPort',uint32(str2double(sshPort)));
            if~success
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(0);
                failureIcon=statusIcon.dispIcon();
                progressText=message('soc:os:SSHFailure',devAddr).getString;
                this.TestConnectionLabel.Text=[failureIcon,'&nbsp;&nbsp;',progressText];
                return;
            end
            if any(ismember(ioplayback.util.getValidBoards,this.Workflow.HardwareBoard))
                try
                    setHardwareObject(this.Workflow.SysDeployer,this.Workflow.HardwareBoard,devAddr,usrn,passw);
                catch ME
                    if~this.Workflow.HWInterfaceObj.InTestEnvironment
                        statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(0);
                        failureIcon=statusIcon.dispIcon();
                        progressText=ME.message;
                        this.TestConnectionLabel.Text=[failureIcon,'&nbsp;&nbsp;',progressText];
                        return;
                    end
                end
            end
            statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(1);
            progressIcon=statusIcon.dispIcon();
            progressText=message('soc:os:ConnectHardwareSuccess',this.getDeviceAddress()).getString;
            this.NextButton.Enable='on';
            this.TestConnectionLabel.Text=[progressIcon,'&nbsp;&nbsp;',progressText];
        end
    end

    methods(Access={?hwsetuptest.util.TemplateBaseTester})
        function ret=getDeviceAddress(this)
            ret=[this.IPAddressOctet1.Text,'.',this.IPAddressOctet2.Text,'.',this.IPAddressOctet3.Text,'.',this.IPAddressOctet4.Text];
        end
    end
end
