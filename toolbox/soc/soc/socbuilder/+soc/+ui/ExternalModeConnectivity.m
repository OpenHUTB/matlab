classdef ExternalModeConnectivity<soc.ui.TemplateBaseWithSteps

    properties
Description
TaskManagerBlocks
ExtConnectivityPanel
CommInterfaceDesc
CommInterface

ConnectivityDesc
Connectivity

Connectivity1Desc
Connectivity1
Verbose
    end


    methods
        function this=ExternalModeConnectivity(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});
            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);


            this.setCurrentStep(1);
            this.Title.Text='External Mode Connectivity';
            this.Description.shiftVertically(260);
            this.Description.addWidth(350);
            this.Description.addHeight(20);
            this.Description.Text=message('soc:workflow:ExtModeConnectivity_Description').getString();
            TaskMgrBlocks=soc.internal.connectivity.getTaskManagerBlock(this.Workflow.sys);

            if~iscell(TaskMgrBlocks)
                this.TaskManagerBlocks={TaskMgrBlocks};
            else
                this.TaskManagerBlocks=TaskMgrBlocks;
            end

            ref_mdls=cellfun(@(x)soc.internal.connectivity.getModelConnectedToTaskManager(x),this.TaskManagerBlocks,'UniformOutput',false);
            ref_mdls=cellfun(@(x)get_param(x,'ModelName'),ref_mdls,'UniformOutput',false);
            enabledExternalMode=zeros(1,numel(ref_mdls));
            for i=1:numel(ref_mdls)
                ref_cpu=codertarget.targethardware.getProcessingUnitName(ref_mdls{i});
                ExtInfo=this.Workflow.ExtModelInfo(ref_cpu);
                enabledExternalMode(i)=ExtInfo.EnableExtMode;
            end
            ref_mdls(~enabledExternalMode)=[];

            startPanelPosition=[20,200,400,140];
            startWidgetPosition=[40,290,185,20];
            offsetVerticalPosition=135;
            offsetHorizontalPosition=150;
            for i=1:numel(ref_mdls)
                selectedCpu=codertarget.targethardware.getProcessingUnitName(ref_mdls{i});
                ExtIfNames=this.getExternalModeCommIfNames(ref_mdls{i});
                IfNameSelected=this.getModelExternalModeIfName(ref_mdls{i});
                if isempty(IfNameSelected)
                    IfNameSelected=ExtIfNames{1};
                end
                mdlExtInfo=this.getModelExternalModeInfo(ref_mdls{i},IfNameSelected);
                if this.isExternalModeCommSerial(ref_mdls{i},IfNameSelected)
                    ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnSerial').getString();
                    Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1Baudrate').getString();
                    if isempty(mdlExtInfo)
                        if ispc
                            Connectivity=['COM',num2str(i)];
                        else
                            Connectivity=['/dev/ttyACM0',num2str(i)];
                        end
                        Connectivity1='115200';
                    else
                        Connectivity=mdlExtInfo.Connectivity;
                        Connectivity1=mdlExtInfo.Connectivity1;
                    end
                else
                    ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnIpAddress').getString();
                    Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1IpPort').getString();
                    if isempty(mdlExtInfo)
                        Connectivity='192.168.1.1';
                        Connectivity1='17725';
                    else
                        Connectivity=mdlExtInfo.Connectivity;
                        Connectivity1=mdlExtInfo.Connectivity1;
                    end
                end
                if i==1
                    this.ExtConnectivityPanel=matlab.hwmgr.internal.hwsetup.Panel.getInstance(this.ContentPanel);
                    this.ExtConnectivityPanel.Position=startPanelPosition;
                    this.ExtConnectivityPanel.Title=message('soc:workflow:ExtModeConnectivity_ConnDetailsPanel',selectedCpu).getString();
                    this.ExtConnectivityPanel.TitlePosition='lefttop';

                    this.CommInterfaceDesc=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.CommInterfaceDesc.Text=message('soc:workflow:ExtModeConnectivity_CommInterface').getString();
                    this.CommInterfaceDesc.Position=startWidgetPosition;

                    this.CommInterface=matlab.hwmgr.internal.hwsetup.DropDown.getInstance(this.ContentPanel);
                    this.CommInterface.Items=ExtIfNames;
                    this.CommInterface.Position=this.CommInterfaceDesc.Position;
                    this.CommInterface.shiftHorizontally(offsetHorizontalPosition);
                    this.CommInterface.shiftVertically(2);
                    this.CommInterface.ValueChangedFcn=@(a,b)this.commInterfaceChangedCB(a,b,1,selectedCpu,ref_mdls{i});

                    this.ConnectivityDesc=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.ConnectivityDesc.Text=ConnectivityDesc;
                    this.ConnectivityDesc.Position=this.CommInterfaceDesc.Position;
                    this.ConnectivityDesc.shiftVertically(-30);

                    this.Connectivity=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
                    this.Connectivity.Text=Connectivity;

                    this.Connectivity.TextAlignment='left';
                    this.Connectivity.Position=this.ConnectivityDesc.Position;
                    this.Connectivity.shiftVertically(1);
                    this.Connectivity.shiftHorizontally(offsetHorizontalPosition);
                    this.Connectivity.addHeight(2);
                    this.Connectivity.ValueChangedFcn=@(a,b)this.ipaddressOrComPortChangedCB(a,b,1,selectedCpu);

                    this.Connectivity1Desc=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.Connectivity1Desc.Text=Connectivity1Desc;
                    this.Connectivity1Desc.Position=this.ConnectivityDesc.Position;
                    this.Connectivity1Desc.shiftVertically(-30);

                    this.Connectivity1=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
                    this.Connectivity1.Text=Connectivity1;
                    this.Connectivity1.TextAlignment='left';
                    this.Connectivity1.Position=this.Connectivity1Desc.Position;
                    this.Connectivity1.shiftHorizontally(offsetHorizontalPosition);
                    this.Connectivity1.shiftVertically(5);
                    this.Connectivity1.ValueChangedFcn=@(a,b)this.ipportOrBaudrateChangedCB(a,b,1,selectedCpu);

                    this.Verbose=matlab.hwmgr.internal.hwsetup.CheckBox.getInstance(this.ContentPanel);
                    this.Verbose.Position=this.Connectivity1Desc.Position;
                    this.Verbose.shiftVertically(-25);
                    this.Verbose.Text=message('soc:workflow:ExtModeConnectivity_Verbose').getString();
                    this.Verbose.Value=true;
                    this.Verbose.ValueChangedFcn=@(a,b)this.verboseChangedCB(a,b,1,selectedCpu);
                else
                    this.ExtConnectivityPanel(end+1)=matlab.hwmgr.internal.hwsetup.Panel.getInstance(this.ContentPanel);
                    this.ExtConnectivityPanel(i).Position=this.ExtConnectivityPanel(i-1).Position;
                    this.ExtConnectivityPanel(i).Position(2)=this.ExtConnectivityPanel(i).Position(2)-offsetVerticalPosition;
                    this.ExtConnectivityPanel(i).Title=message('soc:workflow:ExtModeConnectivity_ConnDetailsPanel',selectedCpu).getString();
                    this.ExtConnectivityPanel(i).TitlePosition='lefttop';

                    this.CommInterfaceDesc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.CommInterfaceDesc(i).Text=message('soc:workflow:ExtModeConnectivity_CommInterface').getString();
                    this.CommInterfaceDesc(i).Position=this.CommInterfaceDesc(i-1).Position;
                    this.CommInterfaceDesc(i).Position(2)=this.CommInterfaceDesc(i).Position(2)-offsetVerticalPosition;

                    this.CommInterface(end+1)=matlab.hwmgr.internal.hwsetup.DropDown.getInstance(this.ContentPanel);
                    this.CommInterface(i).Items=ExtIfNames;
                    this.CommInterface(i).Position=this.CommInterface(i-1).Position;
                    this.CommInterface(i).Position(2)=this.CommInterface(i).Position(2)-offsetVerticalPosition;
                    this.CommInterface(i).ValueChangedFcn=@(a,b)this.commInterfaceChangedCB(a,b,i,selectedCpu,ref_mdls{i});

                    this.ConnectivityDesc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.ConnectivityDesc(i).Text=ConnectivityDesc;
                    this.ConnectivityDesc(i).Position=this.ConnectivityDesc(i-1).Position;
                    this.ConnectivityDesc(i).Position(2)=this.ConnectivityDesc(i).Position(2)-offsetVerticalPosition;

                    this.Connectivity(end+1)=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
                    this.Connectivity(i).Text=Connectivity;
                    this.Connectivity(i).TextAlignment='left';
                    this.Connectivity(i).Position=this.Connectivity(i-1).Position;
                    this.Connectivity(i).Position(2)=this.Connectivity(i).Position(2)-offsetVerticalPosition;
                    this.Connectivity(i).ValueChangedFcn=@(a,b)this.ipaddressOrComPortChangedCB(a,b,i,selectedCpu);

                    this.Connectivity1Desc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
                    this.Connectivity1Desc(i).Text=Connectivity1Desc;
                    this.Connectivity1Desc(i).Position=this.Connectivity1Desc(i-1).Position;
                    this.Connectivity1Desc(i).Position(2)=this.Connectivity1Desc(i).Position(2)-offsetVerticalPosition;

                    this.Connectivity1(end+1)=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);
                    this.Connectivity1(i).Text=Connectivity1;
                    this.Connectivity1(i).TextAlignment='left';
                    this.Connectivity1(i).Position=this.Connectivity1(i-1).Position;
                    this.Connectivity1(i).Position(2)=this.Connectivity1(i).Position(2)-offsetVerticalPosition;
                    this.Connectivity1(i).ValueChangedFcn=@(a,b)this.ipportOrBaudrateChangedCB(a,b,i,selectedCpu);

                    this.Verbose(end+1)=matlab.hwmgr.internal.hwsetup.CheckBox.getInstance(this.ContentPanel);
                    this.Verbose(i).Position=this.Verbose(i-1).Position;
                    this.Verbose(i).Position(2)=this.Verbose(i).Position(2)-offsetVerticalPosition;
                    this.Verbose(i).Text=message('soc:workflow:ExtModeConnectivity_Verbose').getString();
                    this.Verbose(i).Value=true;
                    this.Verbose(i).ValueChangedFcn=@(a,b)this.verboseChangedCB(a,b,i,selectedCpu);
                end


                extstr=this.Workflow.ExtModelInfo(selectedCpu);
                extstr.Interface=this.CommInterface(i).Value;
                extstr.Connectivity=this.Connectivity(i).Text;
                extstr.Connectivity1=this.Connectivity1(i).Text;
                extstr.Verbose=this.Verbose(i).Value;
                this.Workflow.ExtModelInfo(selectedCpu)=extstr;

                this.HelpText.WhatToConsider=message('soc:workflow:ExtModeConnectivity_WhatToConsider').getString();
                this.HelpText.AboutSelection=message('soc:workflow:ExtModeConnectivity_AboutSelection').getString();
                this.HelpText.Additional='';
            end
        end

        function screen=getNextScreenID(~)
            screen='soc.ui.ValidateModel';
        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.SelectCpuForExternalMode';
        end

        function reinit(this)

            ref_mdls=cellfun(@(x)soc.internal.connectivity.getModelConnectedToTaskManager(x),this.TaskManagerBlocks,'UniformOutput',false);
            ref_mdls=cellfun(@(x)get_param(x,'ModelName'),ref_mdls,'UniformOutput',false);
            enabledExternalMode=zeros(1,numel(ref_mdls));
            for i=1:numel(ref_mdls)
                ref_cpu=codertarget.targethardware.getProcessingUnitName(ref_mdls{i});
                ExtInfo=this.Workflow.ExtModelInfo(ref_cpu);
                enabledExternalMode(i)=ExtInfo.EnableExtMode;
            end
            ref_mdls(~enabledExternalMode)=[];

            if numel(ref_mdls)>numel(this.ExtConnectivityPanel)
                for i=1:numel(ref_mdls)-numel(this.ExtConnectivityPanel)

                    this.ExtConnectivityPanel(end+1)=matlab.hwmgr.internal.hwsetup.Panel.getInstance(this.ContentPanel);

                    this.CommInterfaceDesc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);

                    this.CommInterface(end+1)=matlab.hwmgr.internal.hwsetup.DropDown.getInstance(this.ContentPanel);

                    this.ConnectivityDesc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);

                    this.Connectivity(end+1)=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);

                    this.Connectivity1Desc(end+1)=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);

                    this.Connectivity1(end+1)=matlab.hwmgr.internal.hwsetup.EditText.getInstance(this.ContentPanel);

                    this.Verbose(end+1)=matlab.hwmgr.internal.hwsetup.CheckBox.getInstance(this.ContentPanel);
                end
            elseif numel(ref_mdls)<numel(this.ExtConnectivityPanel)

                toRemove=numel(this.ExtConnectivityPanel)-numel(ref_mdls);
                for i=toRemove+1:numel(this.ExtConnectivityPanel)
                    delete(this.ExtConnectivityPanel(i));this.ExtConnectivityPanel(i)=[];

                    delete(this.CommInterfaceDesc(i));this.CommInterfaceDesc(i)=[];

                    delete(this.CommInterface(i));this.CommInterface(i)=[];

                    delete(this.ConnectivityDesc(i));this.ConnectivityDesc(i)=[];

                    delete(this.Connectivity(i));this.Connectivity(i)=[];

                    delete(this.Connectivity1Desc(i));this.Connectivity1Desc(i)=[];

                    delete(this.Connectivity1(i));this.Connectivity1(i)=[];

                    delete(this.Verbose(i));this.Verbose(i)=[];
                end
            else

            end

            startPanelPosition=[20,200,400,140];
            startWidgetPosition=[40,290,185,20];
            offsetVerticalPosition=135;
            offsetHorizontalPosition=150;
            for i=1:numel(ref_mdls)
                selectedCpu=codertarget.targethardware.getProcessingUnitName(ref_mdls{i});
                ExtInfo=this.Workflow.ExtModelInfo(selectedCpu);
                ExtIfNames=this.getExternalModeCommIfNames(ref_mdls{i});
                if this.isExternalModeCommSerial(ref_mdls{i},ExtIfNames{1})
                    ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnSerial').getString();%#ok<PROP>
                    if isempty(ExtInfo.Connectivity)
                        if ispc
                            Connectivity=['COM',num2str(i)];%#ok<PROP>
                        else
                            Connectivity=['/dev/ttyACM0',num2str(i)];%#ok<PROP>
                        end
                    else
                        Connectivity=ExtInfo.Connectivity;%#ok<PROP>
                    end
                    Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1Baudrate').getString();%#ok<PROP>
                    if isempty(ExtInfo.Connectivity1)
                        Connectivity1='115200';%#ok<PROP>
                    else
                        Connectivity1=ExtInfo.Connectivity1;%#ok<PROP>
                    end
                else
                    ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnIpAddress').getString();%#ok<PROP>
                    if isempty(ExtInfo.Connectivity)
                        Connectivity='192.168.1.1';%#ok<PROP>
                    else
                        Connectivity=ExtInfo.Connectivity;%#ok<PROP>
                    end
                    Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1IpPort').getString();%#ok<PROP>
                    if isempty(ExtInfo.Connectivity1)
                        Connectivity1='17725';%#ok<PROP>
                    else
                        Connectivity1=ExtInfo.Connectivity1;%#ok<PROP>
                    end
                end

                if i==1
                    this.ExtConnectivityPanel(i).Position=startPanelPosition;

                    this.CommInterfaceDesc(i).Position=startWidgetPosition;

                    this.CommInterface(i).Position=this.CommInterfaceDesc.Position;
                    this.CommInterface(i).shiftHorizontally(offsetHorizontalPosition);
                    this.CommInterface(i).shiftVertically(2);

                    this.ConnectivityDesc(i).Position=this.CommInterfaceDesc.Position;
                    this.ConnectivityDesc(i).shiftVertically(-30);

                    this.Connectivity(i).Position=this.ConnectivityDesc.Position;
                    this.Connectivity(i).shiftVertically(1);
                    this.Connectivity(i).shiftHorizontally(offsetHorizontalPosition);
                    this.Connectivity(i).addHeight(2);

                    this.Connectivity1Desc(i).Position=this.ConnectivityDesc.Position;
                    this.Connectivity1Desc(i).shiftVertically(-30);

                    this.Connectivity1(i).Position=this.Connectivity1Desc.Position;
                    this.Connectivity1(i).shiftHorizontally(offsetHorizontalPosition);
                    this.Connectivity1(i).shiftVertically(5);

                    this.Verbose(i).Position=this.Connectivity1Desc.Position;
                    this.Verbose(i).shiftVertically(-25);
                else
                    this.ExtConnectivityPanel(i).Position=this.ExtConnectivityPanel(i-1).Position;
                    this.ExtConnectivityPanel(i).Position(2)=this.ExtConnectivityPanel(i).Position(2)-offsetVerticalPosition;

                    this.CommInterfaceDesc(i).Position=this.CommInterfaceDesc(i-1).Position;
                    this.CommInterfaceDesc(i).Position(2)=this.CommInterfaceDesc(i).Position(2)-offsetVerticalPosition;

                    this.CommInterface(i).Position=this.CommInterface(i-1).Position;
                    this.CommInterface(i).Position(2)=this.CommInterface(i).Position(2)-offsetVerticalPosition;

                    this.ConnectivityDesc(i).Position=this.ConnectivityDesc(i-1).Position;
                    this.ConnectivityDesc(i).Position(2)=this.ConnectivityDesc(i).Position(2)-offsetVerticalPosition;

                    this.Connectivity(i).Position=this.Connectivity(i-1).Position;
                    this.Connectivity(i).Position(2)=this.Connectivity(i).Position(2)-offsetVerticalPosition;

                    this.Connectivity1Desc(i).Position=this.Connectivity1Desc(i-1).Position;
                    this.Connectivity1Desc(i).Position(2)=this.Connectivity1Desc(i).Position(2)-offsetVerticalPosition;

                    this.Connectivity1(i).Position=this.Connectivity1(i-1).Position;
                    this.Connectivity1(i).Position(2)=this.Connectivity1(i).Position(2)-offsetVerticalPosition;

                    this.Verbose(i).Position=this.Verbose(i-1).Position;
                    this.Verbose(i).Position(2)=this.Verbose(i).Position(2)-offsetVerticalPosition;
                end
                this.ExtConnectivityPanel(i).Title=message('soc:workflow:ExtModeConnectivity_ConnDetailsPanel',selectedCpu).getString();
                this.ExtConnectivityPanel(i).TitlePosition='lefttop';

                this.CommInterfaceDesc(i).Text=message('soc:workflow:ExtModeConnectivity_CommInterface').getString();

                this.CommInterface(i).ValueChangedFcn=@(a,b)this.commInterfaceChangedCB(a,b,i,selectedCpu,ref_mdls{i});
                this.CommInterface(i).Items=ExtIfNames;
                this.CommInterface(i).ValueIndex=find(contains(ExtIfNames,ExtInfo.Interface));

                this.ConnectivityDesc(i).Text=ConnectivityDesc;%#ok<PROP>

                this.Connectivity(i).ValueChangedFcn=@(a,b)this.ipaddressOrComPortChangedCB(a,b,i,selectedCpu);
                this.Connectivity(i).Text=Connectivity;%#ok<PROP>
                this.Connectivity(i).TextAlignment='left';

                this.Connectivity1Desc(i).Text=Connectivity1Desc;%#ok<PROP>

                this.Connectivity1(i).ValueChangedFcn=@(a,b)this.ipportOrBaudrateChangedCB(a,b,i,selectedCpu);
                this.Connectivity1(i).Text=Connectivity1;%#ok<PROP>
                this.Connectivity1(i).TextAlignment='left';

                this.Verbose(i).ValueChangedFcn=@(a,b)this.verboseChangedCB(a,b,i,selectedCpu);
                this.Verbose(i).Text=message('soc:workflow:ExtModeConnectivity_Verbose').getString();
                this.Verbose(i).Value=ExtInfo.Verbose;
            end
        end
    end

    methods(Access=private)
        function commInterfaceChangedCB(this,~,~,idx,selectedCpu,ref_mdl)
            IfName=this.CommInterface(idx).Value;
            isTcpExt=this.isExternalModeCommTCP(ref_mdl,IfName);


            Connectivity=num2str(this.Connectivity(idx).Text);%#ok<PROPLC>

            Connectivity1=num2str(this.Connectivity1(idx).Text);%#ok<PROPLC>
            if isTcpExt

                val=str2double(this.Connectivity1(idx).Text);
                if(val>65535)||(val<=0)
                    Connectivity1='17725';%#ok<PROPLC>
                    Connectivity='192.168.1.1';%#ok<PROPLC> 
                end
                ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnIpAddress').getString();%#ok<PROPLC>
                Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1IpPort').getString();%#ok<PROPLC>
            else


                Connectivity=this.Connectivity(idx).Text;%#ok<PROPLC>
                if ispc
                    if isempty(regexp(Connectivity,'^\s*COM\d+\s*$','match'))%#ok<PROPLC>
                        Connectivity=['COM',num2str(idx)];%#ok<PROPLC>
                    end
                else
                    if isempty(regexp(Connectivity,'^\s*\/dev\/tty(\w+|\d+)\s*$','match'))%#ok<PROPLC>
                        Connectivity=['/dev/ttyACM',num2str(idx)];%#ok<PROPLC>
                    end
                end

                Connectivity1='115200';%#ok<PROPLC>
                ConnectivityDesc=message('soc:workflow:ExtModeConnectivity_ConnSerial').getString();%#ok<PROPLC>
                Connectivity1Desc=message('soc:workflow:ExtModeConnectivity_Conn1Baudrate').getString();%#ok<PROPLC>
            end

            if~isequal(ConnectivityDesc,this.ConnectivityDesc(idx).Text)%#ok<PROPLC>
                this.ConnectivityDesc(idx).Text=ConnectivityDesc;%#ok<PROPLC>
                this.Connectivity(idx).Text=Connectivity;%#ok<PROPLC>
            end
            if~isequal(Connectivity1Desc,this.Connectivity1Desc(idx).Text)%#ok<PROPLC>
                this.Connectivity1Desc(idx).Text=Connectivity1Desc;%#ok<PROPLC>
                this.Connectivity1(idx).Text=Connectivity1;%#ok<PROPLC>
            end


            extstr=this.Workflow.ExtModelInfo(selectedCpu);
            extstr.Interface=IfName;
            this.Workflow.ExtModelInfo(selectedCpu)=extstr;
        end

        function ipaddressOrComPortChangedCB(this,~,~,idx,selectedCpu)

            extstr=this.Workflow.ExtModelInfo(selectedCpu);
            extstr.Connectivity=this.Connectivity(idx).Text;
            this.Workflow.ExtModelInfo(selectedCpu)=extstr;
        end

        function ipportOrBaudrateChangedCB(this,~,~,idx,selectedCpu)

            extstr=this.Workflow.ExtModelInfo(selectedCpu);
            extstr.Connectivity1=this.Connectivity1(idx).Text;
            this.Workflow.ExtModelInfo(selectedCpu)=extstr;
        end

        function verboseChangedCB(this,~,~,idx,selectedCpu)
            extstr=this.Workflow.ExtModelInfo(selectedCpu);
            extstr.Verbose=this.Verbose(idx).Value;
            this.Workflow.ExtModelInfo(selectedCpu)=extstr;
        end
    end

    methods(Static,Hidden)
        function IONames=getExternalModeCommIfNames(MdlName)
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(getActiveConfigSet(MdlName));
            IONames=targetInfo.ExternalModeInfo.getIOInterfaceNames;
        end

        function isTcpExt=isExternalModeCommTCP(MdlName,IfName)
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(getActiveConfigSet(MdlName));
            IONames=targetInfo.ExternalModeInfo.getIOInterfaceNames;
            ExtIfInfo=targetInfo.ExternalModeInfo(strcmp(IONames,IfName));
            isTcpExt=isequal(ExtIfInfo.Transport.Type,'tcp/ip');
        end

        function isSerialExt=isExternalModeCommSerial(MdlName,IfName)
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(getActiveConfigSet(MdlName));
            IONames=targetInfo.ExternalModeInfo.getIOInterfaceNames;
            ExtIfInfo=targetInfo.ExternalModeInfo(strcmp(IONames,IfName));
            isSerialExt=isequal(ExtIfInfo.Transport.Type,'serial');
        end

        function mdlExtInfo=getModelExternalModeInfo(MdlName,IfName)
            mdlExtInfo=[];
            hCS=getActiveConfigSet(MdlName);
            connectionInfoParam=regexprep(IfName,'\W','');
            if codertarget.data.isValidParameter(hCS,['ConnectionInfo.',connectionInfoParam])
                mdlExtData=codertarget.data.getParameterValue(hCS,['ConnectionInfo.',connectionInfoParam]);
                if isfield(mdlExtData,'Baudrate')
                    mdlExtInfo.Connectivity=mdlExtData.COMPort;
                    mdlExtInfo.Connectivity1=mdlExtData.Baudrate;
                    mdlExtInfo.Verbose=mdlExtData.Verbose;
                elseif isfield(mdlExtData,'Port')
                    mdlExtInfo.Connectivity=mdlExtData.Address;
                    mdlExtInfo.Connectivity1=mdlExtData.Port;
                    mdlExtInfo.Verbose=mdlExtData.Verbose;
                end
            end
        end

        function IfNameSelected=getModelExternalModeIfName(MdlName)

            IfNameSelected='';
            hCS=getActiveConfigSet(MdlName);
            if codertarget.data.isParameterInitialized(hCS,'ExtMode.Configuration')
                IfNameSelected=codertarget.data.getParameterValue(hCS,'ExtMode.Configuration');
            end
        end
    end
end


