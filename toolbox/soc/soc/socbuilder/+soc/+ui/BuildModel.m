classdef BuildModel<soc.ui.TemplateWithValidation




    properties(Access=private)
InternalStep
TimingFailed
TimerH
    end

    methods
        function this=BuildModel(varargin)
            this@soc.ui.TemplateWithValidation(varargin{:});

            this.TimerH=timer;


            this.setCurrentStep(3);
            this.Title.Text=message('soc:workflow:BuildModel_Title').getString();

            this.Description.Text='';

            this.StatusTable.Steps=getListOfBuild(this);
            this.clearStatusTable();

            this.ValidationResult.Steps={message('soc:workflow:BuildModel_Description').getString()};

            this.ValidationAction.Text='Build';
            this.ValidationAction.ButtonPushedFcn=@this.startBuildCB;

            if strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)
                this.HelpText.WhatToConsider='';
            else
                this.HelpText.WhatToConsider=message('soc:workflow:BuildModel_WhatToConsider').getString();
            end

            this.HelpText.AboutSelection='';
        end

        function delete(this)
            if isvalid(this.TimerH)
                stop(this.TimerH);
                delete(this.TimerH);
            end
        end

        function screen=getNextScreenID(this)
            if(this.Workflow.BuildAction==2)

                screen='soc.ui.LoadAndRun';
            elseif this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                screen='soc.ui.LoadAndRun';
            elseif strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                if soc.internal.hasProcessor(this.Workflow.sys)||...
                    (this.Workflow.HasReferenceDesign&&this.Workflow.ReferenceDesignInfo.HasProcessingSystem)


                    screen='soc.ui.ConnectHardware';
                else

                    screen='soc.ui.LoadAndRun';
                end
            else

                screen='soc.ui.ConnectHardware';
            end
        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.ValidateModel';
        end

        function buildTestCB(this)
            this.startBuildCB
        end

        function buildStatusTestCB(this,step)
            this.getBuildStatus(step)
        end

    end

    methods(Access=private)
        function steps=getListOfBuild(this)
            steps={};
            if strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)

                if this.Workflow.BuildAction==3
                    steps{end+1}=message('soc:workflow:BuildModel_ExternalModeModel').getString();
                else
                    steps{end+1}=message('soc:workflow:BuildModel_SoftwareApp').getString();
                end
            elseif this.Workflow.HasReferenceDesign
                hbuild=this.Workflow.hbuild;
                duts=get_param(hbuild.DUTName,'name');

                if strcmpi(this.Workflow.ModelType,this.Workflow.SocFpga)
                    if this.Workflow.BuildAction==3
                        steps{end+1}=message('soc:workflow:BuildModel_ExternalModeModel').getString();
                    else
                        steps{end+1}=message('soc:workflow:BuildModel_SoftwareApp').getString();
                    end
                end
                steps{end+1}=[message('soc:workflow:BuildModel_DUT',duts{1}).getString(),', '...
                ,message('soc:workflow:BuildModel_CreateProject').getString()...
                ,' and ',message('soc:workflow:BuildModel_BuildProject').getString()];
            else
                hbuild=this.Workflow.hbuild;
                duts=hbuild.DUTName;

                if strcmpi(this.Workflow.ModelType,this.Workflow.SocFpga)
                    if this.Workflow.BuildAction==3
                        steps{end+1}=message('soc:workflow:BuildModel_ExternalModeModel').getString();
                    else
                        steps{end+1}=message('soc:workflow:BuildModel_SoftwareApp').getString();
                    end
                end

                for i=1:numel(duts)
                    steps{end+1}=message('soc:workflow:BuildModel_DUT',duts{i}).getString();%#ok<AGROW> % gen dut
                end
                steps{end+1}=message('soc:workflow:BuildModel_CreateProject').getString();
                steps{end+1}=message('soc:workflow:BuildModel_BuildProject').getString();
                steps{end+1}=message('soc:workflow:BuildModel_Synthesis').getString();
                steps{end+1}=message('soc:workflow:BuildModel_Implementation').getString();
                steps{end+1}=message('soc:workflow:BuildModel_BitGen').getString();
            end
        end


        function getBuildStatus(this,step)


            this.setBusy(step);
            this.InternalStep=step;

            if isvalid(this.TimerH)
                stop(this.TimerH);
                delete(this.TimerH);
            end
            timerName=['BuildStatusTimer_',this.Workflow.sys];
            this.TimerH=timer('Name',timerName,...
            'Period',30,...
            'StartDelay',15,...
            'TasksToExecute',inf,...
            'ExecutionMode','fixedSpacing',...
            'TimerFcn',{@this.parseProjectLog});
            start(this.TimerH);
        end

        function parseProjectLog(this,TimerH,event)
            stopTimer=false;
            if isvalid(this)&&isvalid(this.NextButton)
                listOfSteps=this.getListOfBuild;
                statusNames=soc.internal.getStringsForBuildStatus(this.Workflow.hbuild.Vendor);

                logFile=fileread(fullfile(this.Workflow.ProjectDir,statusNames.logName));

                synthMatch=regexp(logFile,['[^\n]*',statusNames.synthesis,'[^\n]*'],'match');

                if~isempty(synthMatch)&&~contains(synthMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_Synthesis').getString())
                    this.setSuccess(this.InternalStep);
                    this.InternalStep=this.InternalStep+1;
                    this.setBusy(this.InternalStep);
                end


                synthFailMatch=regexp(logFile,['[^\n]*',statusNames.synthesisFail,'[^\n]*'],'match');

                if~isempty(synthFailMatch)&&~contains(synthFailMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_Synthesis').getString())
                    this.setFailure(this.InternalStep);
                    this.setValidationStatus('fail',message('soc:workflow:BuildModel_Status_SynthesisFail',fullfile(this.Workflow.ProjectDir,statusNames.logName)).getString());
                    this.InternalStep=this.InternalStep+1;
                    stopTimer=true;
                end


                timingFailMatch=regexp(logFile,['[^\n]*',statusNames.timingFail,'[^\n]*'],'match');

                timingPassMatch=regexp(logFile,['[^\n]*',statusNames.timingPass,'[^\n]*'],'match');

                implMatch=regexp(logFile,['[^\n]*',statusNames.implementation,'[^\n]*'],'match');

                if~isempty(implMatch)&&~contains(implMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_Implementation').getString())
                    if~isempty(timingFailMatch)&&~contains(timingFailMatch{1,end},'#')
                        this.TimingFailed=true;
                        this.setWarn(this.InternalStep);
                        this.InternalStep=this.InternalStep+1;
                        this.setBusy(this.InternalStep);
                    elseif~isempty(timingPassMatch)&&~contains(timingPassMatch{1,end},'#')
                        this.TimingFailed=false;
                        this.setSuccess(this.InternalStep);
                        this.InternalStep=this.InternalStep+1;
                        this.setBusy(this.InternalStep);
                    end
                end

                implFailMatch=regexp(logFile,['[^\n]*',statusNames.implementationFail,'[^\n]*'],'match');

                if~isempty(implFailMatch)&&~contains(implFailMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_Implementation').getString())
                    this.setFailure(this.InternalStep);
                    this.setValidationStatus('fail',message('soc:workflow:BuildModel_Status_ImplementFail',fullfile(this.Workflow.ProjectDir,statusNames.logName)).getString());
                    this.InternalStep=this.InternalStep+1;
                    stopTimer=true;
                end

                bitMatch=regexp(logFile,['[^\n]*',statusNames.bitPass,'[^\n]*'],'match');

                if~isempty(bitMatch)&&~contains(bitMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_BitGen').getString())
                    this.setSuccess(this.InternalStep);
                    if this.TimingFailed
                        this.setValidationStatus('warn',[message('soc:workflow:BuildModel_Status_TimingFail',...
                        fullfile(this.Workflow.ProjectDir,statusNames.timeReport)).getString()...
                        ,' ',message('soc:workflow:BuildModel_Status_BitGenPass').getString()]);
                    else
                        this.setValidationStatus('pass',message('soc:workflow:BuildModel_Status_BitGenPass').getString());
                    end
                    this.InternalStep=this.InternalStep+1;
                    stopTimer=true;
                end

                bitFailMatch=regexp(logFile,['[^\n]*',statusNames.bitFail,'[^\n]*'],'match');

                if~isempty(bitFailMatch)&&~contains(bitFailMatch{1,end},'#')&&strcmp(listOfSteps{this.InternalStep},message('soc:workflow:BuildModel_BitGen').getString())
                    this.setFailure(this.InternalStep);
                    this.setValidationStatus('fail',message('soc:workflow:BuildModel_Status_BitGenFail',fullfile(this.Workflow.ProjectDir,statusNames.logName)).getString());
                    this.InternalStep=this.InternalStep+1;
                    stopTimer=true;
                end
            else
                stopTimer=true;
            end
            if stopTimer
                if isvalid(TimerH)
                    stop(TimerH);
                    delete(TimerH);
                end
            end
        end

        function CleanupFun(this)
            if isprop(this,'Workflow')&&(this.Workflow.isvalid)
                busyStatusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(5);
                if strcmp(busyStatusIcon.dispIcon(),this.ValidationResult.Status{1})
                    this.BackButton.Enable='on';
                    this.CancelButton.Enable='on';
                    this.ValidationResult.Steps={message('soc:workflow:BuildModel_Description').getString()};
                    this.ValidationResult.Status={''};
                    this.ValidationAction.Enable='on';
                end
            end
        end

        function startBuildCB(this,~,~)
            this.clearStatusTable();
            this.NextButton.Enable='off';
            this.BackButton.Enable='off';
            this.CancelButton.Enable='off';
            cleanup=onCleanup(@()this.CleanupFun);
            this.setValidationStatus('busy',message('soc:workflow:BuildModel_Status_Busy').getString());
            if strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)
                this.HelpText.WhatToConsider='';
            else
                this.HelpText.WhatToConsider=message('soc:workflow:BuildModel_WhatToConsider').getString();
            end
            step=1;
            try
                if strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)
                    this.setBusy(step);
                    if~this.Workflow.isModelMultiCPU(this.Workflow.sys)
                        generateESWSLModel(this.Workflow);
                        if this.Workflow.BuildAction~=3
                            buildESWSLModel(this.Workflow);
                        end
                        close_system(this.Workflow.SWModel,0)
                    else

                        generateESWSLModel(this.Workflow);
                        UnusedSwCpuMdls=generateModelsForUnusedCPUs(this.Workflow);
                        buildESWSLModel(this.Workflow);
                        buildModelsForUnusedCPUs(this.Workflow,UnusedSwCpuMdls);
                    end

                    this.setSuccess(step);
                    step=step+1;

                    this.setValidationStatus('pass',message('soc:workflow:BuildModel_Status_Pass_ARM').getString());
                else
                    hbuild=this.Workflow.hbuild;
                    duts=hbuild.DUTName;

                    if strcmpi(this.Workflow.ModelType,this.Workflow.SocFpga)&&this.Workflow.EnableSWMdlGen
                        this.setBusy(step);
                        generateESWSLModel(this.Workflow);
                        if this.Workflow.BuildAction~=3
                            buildESWSLModel(this.Workflow);
                        end
                        this.setSuccess(step);
                        step=step+1;
                    end
                    if~this.Workflow.HasReferenceDesign

                        for i=1:numel(duts)
                            this.setBusy(step);
                            soc.setIOInterface(hbuild.SystemName,duts{i},hbuild.IntfInfo,0);
                            if this.Workflow.EnablePrjGen
                                soc.internal.genIPCore(hbuild,duts{i});
                            end
                            this.setSuccess(step);
                            step=step+1;
                        end

                        this.setBusy(step);
                        soc.internal.genDesignTcl(hbuild);
                        soc.internal.genDesignConstraint(hbuild);
                        if this.Workflow.EnablePrjGen

                            soc.internal.createProject(hbuild,'ADIHDLDir',this.Workflow.ADIHDLDir);
                        end
                        if this.Workflow.ExportRD
                            fprintf('---------- Exporting Reference Design ----------\n');
                            restore=pwd;
                            cd(fullfile(this.Workflow.exportDirectory));
                            [pluginrdInfo]=soc.internal.createPluginrdInfo(hbuild,this.Workflow);
                            pluginrdInfo.exportDirectory=this.Workflow.exportDirectory;
                            pluginrdInfo.exportBoardDir=this.Workflow.exportBoardDir;
                            pluginrdInfo.Vendor=hbuild.Vendor;
                            pluginrdInfo.ToolVersion=soc.internal.getSupportedToolVersion(hbuild.Vendor);
                            cd(hbuild.ProjectDir);
                            if(strcmp(hbuild.Vendor,'Xilinx'))
                                pluginrdInfo=soc.internal.readPluginrd(pluginrdInfo);
                                copyfile('constr.xdc',fullfile(this.Workflow.exportDirectory),'f');
                                copyfile('hsb_xil.tcl',fullfile(this.Workflow.exportDirectory),'f');
                                copyfile('ipcore',fullfile(this.Workflow.exportDirectory,'ipcore'),'f');
                                ipDir=fullfile(this.Workflow.exportDirectory,'ipcore');

                                vivadoToolExe=soc.util.getVivadoPath();
                                [err,~]=system([vivadoToolExe,' -log vivado_rde_info.log -mode batch -source createpluginInfo_hw.tcl']);
                                if err
                                    vivadoCreatePrjLogDir=fullfile(pwd,'vivado_rde_info.log');
                                    vivadoCreatePrjLogName='vivado_rde_info.log';
                                    vivadoCreatePrjLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',vivadoCreatePrjLogDir,vivadoCreatePrjLogName);
                                    error(message('soc:msgs:createVivadoPrjError',vivadoCreatePrjLink));
                                end
                                pluginrdInfo=XilinxPluginInfoHW(pluginrdInfo);
                            else
                                [~,quartusPath]=soc.util.which('quartus');
                                qsysScriptPath=fullfile(quartusPath,'..','sopc_builder','bin','qsys-script');
                                [err,log]=system([qsysScriptPath,' --script=','createpluginInfo_hw.tcl']);
                                fid=fopen(fullfile(hbuild.ProjectDir,'qsys_rde_info.log'),'w');
                                fprintf(fid,'%s',log);
                                fclose(fid);
                                if err
                                    qsysCreateLocation=fullfile(hbuild.ProjectDir,'qsys_rde_info.log');
                                    qsysCreateName='qsys_rde_info.log';
                                    qsysCreateLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',qsysCreateLocation,qsysCreateName);
                                    error(message('soc:msgs:executingQsysError','qsys-script',qsysCreateLink));
                                end
                                pluginrdInfo=IntelPluginInfoHW(pluginrdInfo);
                                copyfile('timing_constr.sdc',fullfile(this.Workflow.exportDirectory),'f');
                                copyfile('pin_constr.tcl',fullfile(this.Workflow.exportDirectory),'f');
                                copyfile('ipcore',fullfile(this.Workflow.exportDirectory,'ip'),'f');
                                ipDir=fullfile(this.Workflow.exportDirectory,'ip');
                            end


                            cd(fullfile(this.Workflow.exportBoardDir));
                            soc.internal.genPluginboard(pluginrdInfo,hbuild);

                            cd(fullfile(this.Workflow.exportDirectory));
                            soc.internal.genPluginrd(pluginrdInfo,hbuild);
                            if(strcmp(hbuild.Vendor,'Xilinx'))
                                if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))||...
                                    any(cellfun(@(x)isa(x,'hsb.xilcomp.HDMITx'),hbuild.FMCIO))||...
                                    any(cellfun(@(x)isa(x,'soc.xilcomp.AD9361'),hbuild.FMCIO))
                                    soc.internal.genList3pFiles(hbuild);
                                    soc.internal.gencopy3pFiles(pluginrdInfo);
                                end
                            end
                            dutIdx=cellfun(@(x)~isempty(x.BlkName)&&contains(x.BlkName,this.Workflow.dutName),hbuild.ComponentList);
                            cd(ipDir);
                            rmdir([hbuild.ComponentList{dutIdx}.Name,'*'],'s');
                            cd(restore);
                        end
                        this.setSuccess(step);
                        step=step+1;

                        this.setBusy(step);
                        if(this.Workflow.EnableBitGen&&this.Workflow.EnablePrjGen)

                            soc.internal.buildProject(hbuild,this.Workflow.ExternalBuild);
                            bitGenMsg=message('soc:workflow:BuildModel_Status_Pass').getString;
                        else
                            bitGenMsg=message('soc:workflow:BuildModel_PassBitGenDisabled').getString;
                        end
                        this.setSuccess(step);
                        step=step+1;
                        this.setValidationStatus('pass',bitGenMsg);
                        if(this.Workflow.EnableBitGen&&this.Workflow.EnablePrjGen)
                            this.getBuildStatus(step);
                        end
                    else
                        this.setBusy(step);
                        generateSWMdlsInHDLWA=this.Workflow.EnableSWMdlGen;
                        if this.Workflow.HasESW
                            generateSWMdlsInHDLWA=false;
                        end
                        soc.setIOInterface(bdroot(duts{1}),get_param(duts{1},'name'),hbuild.IntfInfo,0,false);
                        soc.internal.runHDLWACLI(duts{1},this.Workflow.ProjectDir,...
                        generateSWMdlsInHDLWA,this.Workflow.EnablePrjGen,...
                        this.Workflow.EnableBitGen,this.Workflow.ExternalBuild);
                        bitGenMsg=message('soc:workflow:BuildModel_Status_Pass').getString;
                        this.setSuccess(step);
                        this.setValidationStatus('pass',bitGenMsg);
                    end
                end
                this.NextButton.Enable='on';
                this.BackButton.Enable='on';
                this.CancelButton.Enable='on';
                savesocsysinfo(this.Workflow);
            catch ME
                try
                    this.BackButton.Enable='on';
                    this.CancelButton.Enable='on';
                    this.setFailure(step);
                    this.setValidationStatus('fail',ME.message);
                    this.HelpText.WhatToConsider=message('soc:workflow:BuildModel_WhatToConsider_Failed').getString();
                    if this.Workflow.Debug
                        rethrow(ME);
                    end
                catch
                    rethrow(ME);
                end
            end
        end
    end
end



