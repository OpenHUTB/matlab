classdef HDLNFPStatistics<handle


















































































































































































    properties

mdlNames
dutNames


summary


parseResultsOnly



loadFromMAT
    end

    properties(Access=private)
userDeviceConfig
preModelLoadBaseWorkspace
    end

    methods



        function this=HDLNFPStatistics(varargin)
            if(nargin<2)
                this.dutNames={};
            else
                this.dutNames=varargin{2};
            end

            if(nargin<1)
                this.mdlNames={};
            else
                this.mdlNames=varargin{1};
            end

            numMdls=numel(this.mdlNames);
            numDuts=numel(this.dutNames);
            if numMdls==1&&numDuts>1
                this.mdlNames=repmat(this.mdlNames,1,numDuts);
            elseif numMdls~=numDuts
                this.mdlNames={};
                this.dutNames={};
                error('The number of models and DUTs must match, or there must be exactly one model.')
            end

            mNames=this.mdlNames;
            dNames=this.dutNames;
            if ischar(mNames)
                mNames=cell(this.mdlNames);
            end
            if ischar(dNames)
                dNames=cell(this.dutNames);
            end
            if iscell(mNames)&&numel(mNames)==1
                this.mdlNames=mNames;
                for ii=1:(numel(dNames)-1)
                    this.mdlNames{end+1}=this.mdlNames{1};
                end
            end

            if length(this.dutNames)~=length(this.mdlNames)
                error('Invalid MDL and DUT name specification');
            end

            this.clearXilinxSynthesisResults;
            this.clearAlteraSynthesisResults;
            this.clearLiberoSynthesisResults;

            this.parseResultsOnly=false;
            this.loadFromMAT=false;

            this.userDeviceConfig=struct('Tool','','ChipFamily','','DeviceName','','PackageName','','SpeedValue','','LatencyStrategy','','MantissaMultiplyStrategy','','TargetFrequency',[],'ResetType','');
        end





        function NFP_Stats_Xilinx=doX(this,varargin)

            this.clearXilinxSynthesisResults;

            if~this.parseResultsOnly&&~this.loadFromMAT&&~isempty(which('-all','hsetupvivadoenv'))

                hsetupvivadoenv;
            end

            NFP_Stats_Xilinx=cell(1,length(this.mdlNames));

            for ii=1:length(this.mdlNames)
                mdlName=this.mdlNames{ii};
                dutName=this.dutNames{ii};
                openModel(this,mdlName);
                setupFPMode(this,mdlName,varargin{:});
                NFP_Stats_Xilinx{ii}=this.runXilinxFlow(mdlName,dutName);
                closeModel(this,mdlName);
            end
        end


        function NFP_Stats_Altera=doA(this,varargin)

            this.clearAlteraSynthesisResults;

            if~this.parseResultsOnly&&~this.loadFromMAT&&~isempty(which('-all','hsetupquartusenv'))

                hsetupquartusenv;
            end

            NFP_Stats_Altera=cell(1,length(this.mdlNames));

            for ii=1:length(this.mdlNames)
                mdlName=this.mdlNames{ii};
                dutName=this.dutNames{ii};
                openModel(this,mdlName);
                setupFPMode(this,mdlName,varargin{:});
                NFP_Stats_Altera{ii}=this.runAlteraFlow(mdlName,dutName);
                closeModel(this,mdlName);
            end
        end


        function NFP_Stats_SmartFusion2=doLibero(this,varargin)

            this.clearLiberoSynthesisResults;

            NFP_Stats_SmartFusion2=cell(1,length(this.mdlNames));

            for ii=1:length(this.mdlNames)
                mdlName=this.mdlNames{ii};
                dutName=this.dutNames{ii};
                openModel(this,mdlName);
                setupFPMode(this,mdlName,varargin{:});
                NFP_Stats_SmartFusion2{ii}=this.runLiberoSoCFlow(mdlName,dutName);
                closeModel(this,mdlName);
            end
        end

        function[NFP_Stats_Xilinx,NFP_Stats_Altera]=doXandA(this,varargin)

            NFP_Stats_Xilinx=doX(this,varargin{:});
            NFP_Stats_Altera=doA(this,varargin{:});
        end





        function useCustom(this,customTarget,varargin)
            this.assignPV(varargin);

            if~isfield(this.userDeviceConfig,'Tool')||~isfield(this.userDeviceConfig,'ChipFamily')||~isfield(this.userDeviceConfig,'DeviceName')||~isfield(this.userDeviceConfig,'PackageName')||~isfield(this.userDeviceConfig,'SpeedValue')
                error(['Please ensure that the "customerTarget" structure is of the following form:',newline,...
                'customTarget.Tool = ''<name-of-tool>'';',newline,...
                'customTarget.ChipFamily = ''<chip-family>'';',newline,...
                'customTarget.DeviceName = ''<device-name>'';',newline,...
                'customTarget.PackageName = ''<package-name>'';',newline,...
                'customTarget.SpeedValue = ''<speed-value>'';']);
            end

            this.userDeviceConfig.Tool=customTarget.Tool;
            this.userDeviceConfig.ChipFamily=customTarget.ChipFamily;
            this.userDeviceConfig.DeviceName=customTarget.DeviceName;
            this.userDeviceConfig.PackageName=customTarget.PackageName;
            this.userDeviceConfig.SpeedValue=customTarget.SpeedValue;
        end

        function useVirtex7(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Xilinx Vivado';
            this.userDeviceConfig.ChipFamily='Virtex7';
            this.userDeviceConfig.DeviceName='xc7v2000t';
            this.userDeviceConfig.PackageName='fhg1761';
            this.userDeviceConfig.SpeedValue='-2';
        end

        function useKintex7(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Xilinx Vivado';
            this.userDeviceConfig.ChipFamily='Kintex7';
            this.userDeviceConfig.DeviceName='xc7k160t';
            this.userDeviceConfig.PackageName='fbg484';
            this.userDeviceConfig.SpeedValue='-3';
        end

        function useStratixV(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Altera QUARTUS II';
            this.userDeviceConfig.ChipFamily='Stratix V';
            this.userDeviceConfig.DeviceName='5SEE9F45C2';
            this.userDeviceConfig.PackageName='';
            this.userDeviceConfig.SpeedValue='';
        end

        function useCycloneV(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Altera QUARTUS II';
            this.userDeviceConfig.ChipFamily='Cyclone V';
            this.userDeviceConfig.DeviceName='5CSXFC4C6U23I7';
            this.userDeviceConfig.PackageName='';
            this.userDeviceConfig.SpeedValue='';
        end

        function useArria10(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Altera QUARTUS II';
            this.userDeviceConfig.ChipFamily='Arria 10';
            this.userDeviceConfig.DeviceName='10AS016C3U19E2LG';
            this.userDeviceConfig.PackageName='';
            this.userDeviceConfig.SpeedValue='';
        end

        function useZedboard(this,varargin)
            this.assignPV(varargin);

            this.userDeviceConfig.Tool='Xilinx Vivado';
            this.userDeviceConfig.ChipFamily='Zynq';
            this.userDeviceConfig.DeviceName='xa7z020';
            this.userDeviceConfig.PackageName='clg484';
            this.userDeviceConfig.SpeedValue='';
        end

    end

    methods(Access=private)




        function assignPV(this,varargin)

            while iscell(varargin{1})
                if isempty(varargin{1})
                    return
                end
                varargin=varargin{1};
            end

            if mod(length(varargin),2)~=0
                error('PV count do not match. Please note that every property must have a corresponding value.');
            end


            for ii=1:2:length(varargin)


                if isempty(varargin{ii})||isempty(varargin{ii+1})
                    continue
                end


                if~isa(varargin{ii},'char')
                    error(['Expected entry #',num2str(ii),' in the PV pair to be of type ''char''.']);
                end

                switch varargin{ii}
                case 'TargetFrequency'
                    if~(isa(varargin{ii+1},'double')&&isscalar(varargin{ii+1}))
                        error('''TargetFrequency'' value must be a scalar of the type ''double''.');
                    end

                    this.userDeviceConfig.TargetFrequency=varargin{ii+1};

                case 'MantissaMultiplyStrategy'
                    if~isa(varargin{ii+1},'char')
                        error('''MantissaMultiplyStrategy'' value must be of the type ''char''.');
                    end

                    this.userDeviceConfig.MantissaMultiplyStrategy=varargin{ii+1};

                case 'LatencyStrategy'
                    if~isa(varargin{ii+1},'char')
                        error('''LatencyStrategy'' value must be of the type ''char''.');
                    end

                    this.userDeviceConfig.LatencyStrategy=varargin{ii+1};

                case 'ResetType'
                    if~isa(varargin{ii+1},'char')
                        error('''ResetType'' value must be of the type ''char''.');
                    end

                    this.userDeviceConfig.ResetType=varargin{ii+1};

                otherwise
                    error(['Invalid property name: ',varargin{ii},'. Valid property names are: ''TargetFrequency'', ''MantissaMultiplyStrategy'', ''ResetType'' or ''LatencyStrategy''.']);
                end
            end
        end





        function clearXilinxSynthesisResults(this)
            this.summary.Xilinx={};
        end

        function clearAlteraSynthesisResults(this)
            this.summary.Altera={};
        end

        function clearLiberoSynthesisResults(this)
            this.summary.Libero={};
        end





        function openModel(this,mdlName)

            this.preModelLoadBaseWorkspace=evalin('base','whos');


            load_system(mdlName);
        end

        function closeModel(this,mdlName)

            bdclose(mdlName);


            currentWorkspace=evalin('base','whos');
            diff=setdiff({currentWorkspace.name},{this.preModelLoadBaseWorkspace.name});

            for count=1:length(diff)
                evalin('base',['clear ',diff{count}]);
            end
        end




        function chipFamily=setupDevice(this,mdlName,synthesisWorkflow)

            if isempty(mdlName)
                return;
            end



            if isempty(this.userDeviceConfig.Tool)


                setupDefaultDevice(this,synthesisWorkflow);

                if~isempty(hdlget_param(mdlName,'SynthesisTool'))&&~contains(hdlget_param(mdlName,'SynthesisTool'),synthesisWorkflow,'IgnoreCase',true)
                    error('The synthesis tool specified on model does not match with the selected synthesis workflow. Please change ''SynthesisTool'' on Simulink model. ');
                end

                warningFlag=false;

                if isempty(hdlget_param(mdlName,'SynthesisTool'))
                    warningFlag=true;
                else
                    this.userDeviceConfig.Tool=hdlget_param(mdlName,'SynthesisTool');
                end

                if isempty(hdlget_param(mdlName,'SynthesisToolChipFamily'))
                    warningFlag=true;
                else
                    this.userDeviceConfig.ChipFamily=hdlget_param(mdlName,'SynthesisToolChipFamily');
                end

                if isempty(hdlget_param(mdlName,'SynthesisToolDeviceName'))
                    warningFlag=true;
                else
                    this.userDeviceConfig.DeviceName=hdlget_param(mdlName,'SynthesisToolDeviceName');
                end

                if isempty(hdlget_param(mdlName,'SynthesisToolPackageName'))
                    warningFlag=true;
                else
                    this.userDeviceConfig.PackageName=hdlget_param(mdlName,'SynthesisToolPackageName');
                end

                if isempty(hdlget_param(mdlName,'SynthesisToolSpeedValue'))
                    warningFlag=true;
                else
                    this.userDeviceConfig.SpeedValue=hdlget_param(mdlName,'SynthesisToolSpeedValue');
                end

                if warningFlag
                    warning(['Settings for Synthesis Device are empty on the model. Using default settings for ',synthesisWorkflow,' workflow.']);
                end


            else
                if~isempty(hdlget_param(mdlName,'SynthesisTool'))
                    warning('Model settings for Synthesis Device configuration will be over-written by user entered settings.');
                end
                if~contains(this.userDeviceConfig.Tool,synthesisWorkflow,'IgnoreCase',true)
                    error(['User entered Synthesis Device configuration does not match the synthesis workflow chosen. Using default settings for ',synthesisWorkflow,' workflow.']);
                end
            end

            chipFamily=this.userDeviceConfig.ChipFamily;
            chipFamily=chipFamily(~isspace(chipFamily));

            hdlset_param(mdlName,'SynthesisTool',this.userDeviceConfig.Tool);
            hdlset_param(mdlName,'SynthesisToolChipFamily',this.userDeviceConfig.ChipFamily);
            hdlset_param(mdlName,'SynthesisToolDeviceName',this.userDeviceConfig.DeviceName);
            hdlset_param(mdlName,'SynthesisToolPackageName',this.userDeviceConfig.PackageName);
            hdlset_param(mdlName,'SynthesisToolSpeedValue',this.userDeviceConfig.SpeedValue);

        end

        function displayFinalSettings(this,mdlName)

            disp(['The following Synthesis Device configuration will be used for the model: ',mdlName])
            disp(['Synthesis Tool:                    ',this.userDeviceConfig.Tool])
            disp(['Chip Family:                       ',this.userDeviceConfig.ChipFamily])
            disp(['Device Name:                       ',this.userDeviceConfig.DeviceName])
            disp(['Package Name:                      ',this.userDeviceConfig.PackageName])
            disp(['Speed Value:                       ',this.userDeviceConfig.SpeedValue])
            disp(['Target Frequency:                  ',num2str(this.userDeviceConfig.TargetFrequency),' MHz']);
            disp(['Global Latency Strategy:           ',this.userDeviceConfig.LatencyStrategy]);
            disp(['Global Mantissa Multiply Strategy: ',this.userDeviceConfig.MantissaMultiplyStrategy]);
        end

        function setupDefaultDevice(this,synthesisWorkflow)
            if strcmpi(synthesisWorkflow,'xilinx')
                useVirtex7(this);
            else
                useStratixV(this);
            end
        end


        function NFP_Stats_Xilinx=runXilinxFlow(this,mdlName,dutName)

            chipFamily=this.setupDevice(mdlName,'Xilinx');
            this.displayFinalSettings(mdlName);
            ModulePrefix=hdlget_param(mdlName,'ModulePrefix');

            targetDir=['hdl_prj_xilinx_',strrep(chipFamily,' ',''),filesep,strrep(strtrim(mdlName),' ','_'),'_',[strrep(strtrim(ModulePrefix),' ','_'),strrep(strtrim(dutName),' ','_')]];
            synthTool='Xilinx Vivado';

            if~this.parseResultsOnly&&~this.loadFromMAT

                disp('### Xilinx Synthesis Workflow begin')
                if isempty(this.userDeviceConfig.ResetType)
                    this.runSynthesis(mdlName,dutName,targetDir,synthTool,'Synchronous');
                else
                    this.runSynthesis(mdlName,dutName,targetDir,synthTool,this.userDeviceConfig.ResetType);
                end
                disp('### Xilinx Synthesis Workflow completed');
            end

            dutName=[strrep(strtrim(ModulePrefix),' ','_'),strrep(strtrim(dutName),' ','_')];

            disp('### Parsing Xilinx Synthesis Results')
            parseObj=HDLReadStatistics(dutName,'TargetDir',targetDir,'SynthTool',synthTool);
            parseObj.loadFromMAT=this.loadFromMAT;
            NFP_Stats_Xilinx=parseObj.readResults('Implementation',true,'TestMode',true);
        end


        function NFP_Stats_Altera=runAlteraFlow(this,mdlName,dutName)

            chipFamily=this.setupDevice(mdlName,'Altera');
            this.displayFinalSettings(mdlName);
            ModulePrefix=hdlget_param(mdlName,'ModulePrefix');

            targetDir=['hdl_prj_altera_',strrep(chipFamily,' ',''),filesep,strrep(strtrim(mdlName),' ','_'),'_',[strrep(strtrim(ModulePrefix),' ','_'),strrep(strtrim(dutName),' ','_')]];
            synthTool='Altera QUARTUS II';

            if~this.parseResultsOnly&&~this.loadFromMAT

                disp('### Altera Synthesis Workflow begin')
                if isempty(this.userDeviceConfig.ResetType)
                    this.runSynthesis(mdlName,dutName,targetDir,synthTool,'ASynchronous');
                else
                    this.runSynthesis(mdlName,dutName,targetDir,synthTool,this.userDeviceConfig.ResetType);
                end
                disp('### Altera Synthesis Workflow completed')
            end

            dutName=[strrep(strtrim(ModulePrefix),' ','_'),strrep(strtrim(dutName),' ','_')];

            disp('### Parsing Altera Synthesis Results')
            parseObj=HDLReadStatistics(dutName,'TargetDir',targetDir,'SynthTool',synthTool);
            parseObj.loadFromMAT=this.loadFromMAT;
            NFP_Stats_Altera=parseObj.readResults('PAR',true,'TestMode',true);
        end


        function runSynthesis(this,mdlName,dutName,targetDir,synthTool,resetType)

            hdlset_param(mdlName,'HDLSubsystem',[mdlName,'/',dutName]);
            hdlset_param(mdlName,'TargetLanguage','VHDL');
            hdlset_param(mdlName,'ResetType',resetType);
            hdlset_param(mdlName,'TargetDirectory',targetDir);

            hWC=hdlcoder.WorkflowConfig('SynthesisTool',synthTool,'TargetWorkflow','Generic ASIC/FPGA');
            hWC.ProjectFolder=targetDir;
            hWC.RunTaskGenerateRTLCodeAndTestbench=true;
            hWC.RunTaskVerifyWithHDLCosimulation=false;
            hWC.RunTaskCreateProject=true;

            if contains(synthTool,'vivado','IgnoreCase',true)
                hWC.RunTaskRunSynthesis=true;
                hWC.RunTaskRunImplementation=true;
            else
                hWC.RunTaskPerformLogicSynthesis=true;
                hWC.RunTaskPerformMapping=true;
                hWC.RunTaskPerformPlaceAndRoute=true;
            end

            hWC.RunTaskAnnotateModelWithSynthesisResult=false;
            hWC.SkipPreRouteTimingAnalysis=false;
            hWC.IgnorePlaceAndRouteErrors=false;
            hWC.validate;

            hdlcoder.runWorkflow([mdlName,'/',dutName],hWC);
        end


        function NFP_Stats_SmartFusion2=runLiberoSoCFlow(this,mdlName,dutName)

            targetDir=['hdl_prj_libero',filesep,strrep(strtrim(mdlName),' ','_'),'_',strrep(strtrim(dutName),' ','_')];
            synthTool='Libero';

            if~this.parseResultsOnly&&~this.loadFromMAT

                disp('### Libero SoC Synthesis Workflow begin')
                this.runLiberoSynthesis(mdlName,dutName,targetDir,synthTool);
                disp('### Libero SoC Synthesis Workflow completed')
            end

            disp('### Parsing Libero SoC Synthesis Results')
            parseObj=HDLReadStatistics(dutName,'TargetDir',targetDir,'SynthTool',synthTool,'ModelName',mdlName);
            parseObj.loadFromMAT=this.loadFromMAT;
            NFP_Stats_SmartFusion2=parseObj.readResults('',true,'TestMode',true);
        end


        function runLiberoSynthesis(~,mdlName,dutName,targetDir,synthTool)
            disp('### Loading setting on the model')
            rtlTop=[mdlName,'/',dutName];
            hdlset_param(mdlName,'HDLSubsystem',[mdlName,'/',dutName]);
            hdlset_param(mdlName,'TargetDirectory',targetDir);
            hdlset_param(mdlName,'HDLSynthCmd','  -hdl_source %s \\\n');
            hdlset_param(mdlName,'HDLSynthFilePostfix','_libero.tcl');
            hdlset_param(mdlName,'HDLSynthInit','set dutname %s\n\nnew_project \\\n\t-name \t\t$dutname\\\n\t-location \tlibero_prj \\\n\t-hdl \t\t%s \\\n\t-family \tSmartFusion2 \\\n\t-die \t\tM2S150TS \\\n\t-package \t{1152 FC}\n\nimport_files \\\n');
            hdlset_param(mdlName,'HDLSynthTerm',['\nset_root -module $dutname\\::work',newline,...
            'run_tool -name {SYNTHESIZE} ',newline,...
            'run_tool -name {COMPILE} ',newline,...
            'run_tool -name {PLACEROUTE} ',newline,...
            'run_tool -name {VERIFYTIMING} ',newline,...
            'close_project -save 1']);
            hdlset_param(mdlName,'HDLSynthTool',synthTool);


            disp('###++++++++++++++ Task Generate RTL Code and Testbench ++++++++++++++')
            makehdl(rtlTop,'NativeFloatingPoint','on');

            currentDir=pwd;

            liberTcldir=fullfile([targetDir,filesep,mdlName]);

            cd(liberTcldir);
            disp('###++++++++++++++ Task Run Synthesis, Compile and PlaceRoute ++++++++++++++')
            liberoSynthCmd=['!cmd /C C:\Microsemi\Libero_SoC_v11.7\Designer\bin\libero.exe',' ','"SCRIPT:',dutName,'_libero.tcl"',' ','&& exit'];
            disp('This task will take several minutes...')
tic
            eval(liberoSynthCmd);
toc
            disp('### Task "Perform Synthesis, Compile and PlaceRoute" successful.')
            cd(currentDir);
        end




        function setupFPMode(this,nfpMdlName,fpMode,fpConfig)

            if nargin<4
                fpConfig=[];
            end

            if nargin<3
                fpMode='nfp';
            end

            switch lower(fpMode)
            case 'nfp'
                setupNFPMode(this,nfpMdlName,fpConfig);
            case 'custom'
                setupCustomConfig(this,nfpMdlName,fpConfig);
            end
        end

        function setupNFPMode(this,mdlName,fpConfig)

            fpModel=hdlget_param(mdlName,'FloatingPointTargetConfiguration');

            if~isempty(fpConfig)
                if~isa(fpConfig,'hdlcoder.FloatingPointTargetConfig')
                    error('The user specified configuration needs to be a Native Floating Point configuration object');
                end

                if~isempty(fpModel)
                    warning('### Native Floating Point configuration setting on the model will be overwritten with the user specified one');
                end

                hdlset_param(mdlName,'FloatingPointTargetConfiguration',fpConfig);

                this.userDeviceConfig.LatencyStrategy=fpConfig.LibrarySettings.LatencyStrategy;
                this.userDeviceConfig.MantissaMultiplyStrategy=fpConfig.LibrarySettings.MantissaMultiplyStrategy;

            else
                if isempty(fpModel)
                    disp('### Loading default Native Floating Point configuration');
                    fpModel=hdlcoder.createFloatingPointTargetConfig('NATIVEFLOATINGPOINT');
                end

                if~isempty(this.userDeviceConfig.LatencyStrategy)
                    fpModel.LibrarySettings.LatencyStrategy=this.userDeviceConfig.LatencyStrategy;
                else
                    this.userDeviceConfig.LatencyStrategy=fpModel.LibrarySettings.LatencyStrategy;
                end
                if~isempty(this.userDeviceConfig.MantissaMultiplyStrategy)
                    fpModel.LibrarySettings.MantissaMultiplyStrategy=this.userDeviceConfig.MantissaMultiplyStrategy;
                else
                    this.userDeviceConfig.MantissaMultiplyStrategy=fpModel.LibrarySettings.MantissaMultiplyStrategy;
                end

                hdlset_param(mdlName,'FloatingPointTargetConfiguration',fpModel);
            end

            if isempty(this.userDeviceConfig.TargetFrequency)
                if~isempty(hdlget_param(mdlName,'TargetFrequency'))

                    this.userDeviceConfig.TargetFrequency=hdlget_param(mdlName,'TargetFrequency');
                else

                    this.userDeviceConfig.TargetFrequency=500;
                end
            end
            hdlset_param(mdlName,'TargetFrequency',this.userDeviceConfig.TargetFrequency);
        end

        function setupCustomConfig(~,mdlName,fpConfig)
            if~iscell(fpConfig)
                error('The custom configuration options needs to be passed as a cell array of property-value pairs.')
            end

            if~isempty(fpConfig)
                disp('### Setting custom configuration settings to the model')
                for ii=1:2:length(fpConfig)
                    if~isempty(hdlget_param(mdlName,fpConfig{ii}))
                        warning(['### Setting',fpConfig{ii},' on the model will be overwritten with the user specified one']);
                    end
                    hdlset_param(mdlName,fpConfig{ii},fpConfig{ii+1});
                end
            end
        end
    end
end
