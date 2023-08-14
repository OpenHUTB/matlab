



classdef ModuleSelection<CosimWizardPkg.StepBase
    properties
        shutdownHdlObj;
        savedSocketPort;
    end
    methods
        function obj=ModuleSelection(Wizard)
            obj=obj@CosimWizardPkg.StepBase(Wizard);
            if~isempty(Wizard.UserData.TopLevelName)
                Wizard.TopLevelName=Wizard.UserData.TopLevelName;
            end
        end
        function WidgetGroup=getDialogSchema(this)

            currRow=1;
            TopName.Name='Name of HDL module to cosimulate with:';
            TopName.Tag='edaTopName';

            TopName.Type='combobox';
            numEntries=numel(this.Wizard.UserData.ModulesFound);

            if(numEntries<100)
                TopName.Entries=this.Wizard.UserData.ModulesFound;
            else
                TopName.Entries=this.Wizard.UserData.ModulesFound(end-99:end);
            end
            TopName.RowSpan=[1,1];
            TopName.ColSpan=[1,5];
            TopName.ObjectProperty='TopLevelName';
            TopName.Mode=true;
            if strcmp(this.Wizard.Simulator,'Vivado Simulator')
                TopName.Editable=false;
                TopName.Enabled=false;
            else
                TopName.Editable=true;
                TopName.Enabled=true;
            end



            if strcmp(this.Wizard.Simulator,'Vivado Simulator')

                currRow=currRow+1;
                DebugOptions.Name='Debug internal signals:';
                DebugOptions.Tag='edaDebugOptions';
                DebugOptions.Type='combobox';
                DebugOptions.Entries={'off','wave','all'};
                DebugOptions.Editable=false;
                DebugOptions.Value=this.Wizard.UserData.getDebugValue();
                DebugOptions.RowSpan=[currRow,currRow];
                DebugOptions.ColSpan=[1,3];
                DebugOptions.ObjectMethod='onVivadoElabOptionChange';
                DebugOptions.MethodArgs={'%dialog','%value','%tag'};
                DebugOptions.ArgDataTypes={'handle','mxArray','string'};
                DebugOptions.DialogRefresh=true;

                currRow=currRow+1;
                HDLTimePrec.Name='HDL time precision:';
                HDLTimePrec.Tag='edaHDLTimePrec';
                HDLTimePrec.Type='edit';
                HDLTimePrec.RowSpan=[currRow,currRow];
                HDLTimePrec.ColSpan=[1,3];
                HDLTimePrec.ToolTip='For example 1ps, 10ns, 100ms.';
                HDLTimePrec.Value=this.Wizard.UserData.precExpToStr(this.Wizard.UserData.HdlResolution);
                HDLTimePrec.ObjectMethod='onVivadoElabOptionChange';
                HDLTimePrec.MethodArgs={'%dialog','%value','%tag'};
                HDLTimePrec.ArgDataTypes={'handle','mxArray','string'};
                HDLTimePrec.DialogRefresh=true;

                currRow=currRow+1;
                VivadoElabOptions.Name=sprintf('Project elaboration commands:\n%s',this.Wizard.ElabOptions);
                VivadoElabOptions.Tag='edaVivadoElabOptions';
                VivadoElabOptions.Type='text';
                VivadoElabOptions.RowSpan=[currRow,currRow];
                VivadoElabOptions.ColSpan=[1,3];
            else
                currRow=currRow+1;
                EditElabOptions.Name='Elaboration options:';
                EditElabOptions.Tag='edaEditElabOptions';
                EditElabOptions.Type='edit';
                EditElabOptions.RowSpan=[currRow,currRow];
                EditElabOptions.ColSpan=[1,5];
                EditElabOptions.ObjectProperty='ElabOptions';
                EditElabOptions.Mode=true;
                EditElabOptions.Enabled=true;
                switch(this.Wizard.Simulator)
                case{'Xcelium'}
                    EditElabOptions.Visible=true;
                otherwise
                    EditElabOptions.Visible=false;
                    currRow=currRow-1;
                end


                currRow=currRow+1;
                EditLoadOptions.Name='Simulation options: ';
                EditLoadOptions.Tag='edaEditLoadOptions';
                EditLoadOptions.Type='edit';
                EditLoadOptions.RowSpan=[currRow,currRow];
                EditLoadOptions.ColSpan=[1,5];
                EditLoadOptions.ObjectProperty='LoadOptions';
                EditLoadOptions.Mode=true;
                EditLoadOptions.Enabled=true;

                currRow=currRow+1;
                ConnectionMethod.Name='Connection method:';
                ConnectionMethod.Tag='edaConnection';
                ConnectionMethod.Type='combobox';
                ConnectionMethod.Entries={'Socket','Shared Memory'};
                ConnectionMethod.RowSpan=[currRow,currRow];
                ConnectionMethod.ColSpan=[1,3];
                ConnectionMethod.ObjectProperty='Connection';
                ConnectionMethod.Mode=1;
                ConnectionMethod.Source=this.Wizard.UserData;


                currRow=currRow+1;
                ResetLoadOpt.Name='Restore Defaults';
                ResetLoadOpt.Tag='edaResetLoadOpt';
                ResetLoadOpt.Type='pushbutton';
                ResetLoadOpt.RowSpan=[currRow,currRow];
                ResetLoadOpt.ColSpan=[5,5];
                ResetLoadOpt.ObjectMethod='onResetLoadOpt';
                ResetLoadOpt.MethodArgs={'%dialog'};
                ResetLoadOpt.ArgDataTypes={'handle'};
                ResetLoadOpt.Mode=true;
                ResetLoadOpt.Enabled=true;
            end

            currRow=currRow+1;
            Spacer=l_createSpacer([currRow,currRow],[1,5],'edaSpacer.ModuleSelection');


            WidgetGroup.LayoutGrid=[currRow,5];

            if strcmp(this.Wizard.Simulator,'Vivado Simulator')
                WidgetGroup.Items={TopName,DebugOptions,HDLTimePrec,...
                VivadoElabOptions,Spacer};
            else
                WidgetGroup.Items={TopName,EditElabOptions,EditLoadOptions,...
                ConnectionMethod,ResetLoadOpt,Spacer};
            end

            this.Wizard.UserData.CurrentStep=4;

        end
        function onBack(this,~)
            this.Wizard.UserData.TopLevelName=this.Wizard.TopLevelName;
            this.Wizard.UserData.LoadOptions=this.Wizard.LoadOptions;
            this.Wizard.UserData.ElabOptions=this.Wizard.ElabOptions;
            this.Wizard.NextStepID=3;
        end
        function EnterStep(this,~)
            this.shutdownHdlObj=[];
        end
        function onNext(this,dlg)
            this.Wizard.UserData.TopLevelName=this.Wizard.TopLevelName;
            this.Wizard.UserData.LoadOptions=this.Wizard.LoadOptions;
            this.Wizard.UserData.ElabOptions=this.Wizard.ElabOptions;

            assert(isempty(this.Wizard.TopLevelName)==0,...
            sprintf('HDL module name cannot be empty.'));




            ModuleName=regexp(this.Wizard.TopLevelName,'(?<=(\.|^\s{0,}))[^.]+(?=(\s){0,}$)','match','once');
            if(isempty(ModuleName))

                this.Wizard.UserData.ModuleName=this.Wizard.TopLevelName;
            else
                this.Wizard.UserData.ModuleName=ModuleName;
            end


            [~,launchLogFile]=fileparts(tempname);
            launchLogFile=[launchLogFile,'.log'];

            statusmsg='Elaborating and Loading HDL simulation image. Please wait ...';
            displayStatusMessage(this.Wizard,dlg,statusmsg);



            onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);


            launchHdl(this.Wizard.UserData,launchLogFile);



            if(~strcmp(this.Wizard.Simulator,'Vivado Simulator'))
                TimeOut=120;
                m=TimeOut;
                while(1)
                    msg=['Waiting for HDL Simulator to startup ...',char(10)...
                    ,num2str(m),' seconds to time-out ...',char(10)...
                    ,'To stop this process, press Ctrl+C in MATLAB console.'];
                    displayStatusMessage(this.Wizard,dlg,msg);

                    pause(1);


                    if this.Wizard.UserData.useSocket
                        pid=pingHdlSim(0,num2str(this.Wizard.UserData.SocketPort));
                    else
                        pid=pingHdlSim(0);
                    end


                    if(ischar(pid))
                        break;
                    end


                    if(exist(fullfile(pwd,launchLogFile),'file')==2)
                        launchLog=fileread(launchLogFile);
                        r=regexp(launchLog,'(?<!")Loading simulation and HDL Verifier library failed.(?<!")','match','once');
                        if(~isempty(r))

                            if(strcmpi(this.Wizard.Simulator,'Xcelium'))
                                try
                                    launchLog2=fileread('xmsim.log');
                                    launchLog=[launchLog,launchLog2];%#ok<AGROW>
                                catch ME


                                end
                            end



                            this.Wizard.ErrMsg=...
                            ['The HDL simulator launching has failed with the following log message:',launchLog];
                            error(message('HDLLink:CosimWizard:LaunchFailed'));
                        end
                    end

                    m=m-1;
                    if(m==0)
                        answer=questdlg('Time-out occurred. Would you like to wait for HDL simulator to startup or abort operation?',...
                        'Time-out','Wait','Abort','Wait');
                        if(strcmp(answer,'Wait'))
                            m=TimeOut;
                        else
                            error(message('HDLLink:CosimWizard:Timeout'));
                        end
                    end
                end

                this.shutdownHdlObj=onCleanup(@()l_OnCleanupFcn);
                this.savedSocketPort=this.Wizard.UserData.SocketPort;
            else

                this.shutdownHdlObj=onCleanup(@()disp(''));
            end

            try
                switch(this.Wizard.UserData.Workflow)
                case{'Simulink','MATLAB System Object'}
                    this.Wizard.UserData.autoFill;
                    this.Wizard.UserData.autoFillAllModulesParameters;
                    this.Wizard.UserData.genParameterConfigFile;
                    delete(this.shutdownHdlObj);
                    this.Wizard.NextStepID=5;
                case 'MATLAB'
                    populateHdlHierarchy(this.Wizard.UserData);
                    this.Wizard.NextStepID=10;
                end
            catch ME



                delete(onCleanupObj);

                rethrow(ME);
            end

            delete(onCleanupObj);
        end

        function ResetOptions(this)
            this.Wizard.LoadOptions=this.Wizard.UserData.LoadOptions;
            this.Wizard.ElabOptions=this.Wizard.UserData.ElabOptions;
            if~isempty(this.Wizard.UserData.TopLevelName)

                this.Wizard.TopLevelName=this.Wizard.UserData.TopLevelName;
            elseif(~isempty(this.Wizard.UserData.ModulesFound))

                this.Wizard.TopLevelName=this.Wizard.UserData.ModulesFound{end};
            else
                this.Wizard.TopLevelName='';
            end
        end

        function Description=getDescription(this)


            if(strcmpi(this.Wizard.UserData.Workflow,'MATLAB'))
                Description=['Specify the name of the HDL module for cosimulation. '...
                ,'The Cosimulation Wizard will launch the HDL simulator and '...
                ,'load the specified module in the next step.'];
            else
                Description=['Specify the name of the HDL module for cosimulation. '...
                ,'The Cosimulation Wizard will launch the HDL simulator, '...
                ,'load the specified module, and populate the port list of that '...
                ,'HDL module before the next step.'];
            end
            if~strcmp(this.Wizard.Simulator,'Vivado Simulator')
                Description=[Description,...
' Use "Shared Memory" communication method if your firewall policy does not allow '...
                ,' TCP/IP socket communication.'];
            end
        end
    end
end
function l_OnCleanupFcn
    try
        if this.Wizard.UserData.useSocket
            breakHdlSim(num2str(this.savedSocketPort));
        else
            breakHdlSim;
        end
    catch ME
    end
end
function widget=l_createSpacer(rowSpan,colSpan,Tag)
    widget.Type='panel';
    widget.Tag=Tag;
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
end



