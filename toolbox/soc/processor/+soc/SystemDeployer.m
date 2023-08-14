classdef(Hidden)SystemDeployer<handle&matlab.mixin.CustomDisplay
























    properties(Dependent)
        HardwareBoard;
        HDLSystem;
        HDLIPCores;
    end

    properties(Access={?soc.ui.SoCGenWorkflow})
        TopModel=[];

        HWObj=[];
    end

    properties(SetAccess=private,GetAccess=public,Hidden)
        HDLSystemInfo=[];
        DeployerOptions=[];
        ChecksumFile=[];
        HDLPrjDir=[];
        BuildStruct=[];
        BitStreamFile=[];
        SoftwareSystemModel={};
    end

    properties(Access=private)
        Debug=false;
        DeviceTreeCompiler=[];
        ModelConfigurationFcn='';
    end

    methods
        function setHardwareObject(obj,hwName,addr,username,password)










            obj.HWObj=createHardwareObject(hwName,'hostname',addr,'username',username,'password',password);
        end


        function ret=get.HardwareBoard(obj)
            load_system(obj.TopModel);
            ret=get_param(obj.TopModel,'HardwareBoard');
        end

        function ret=get.BitStreamFile(obj)
            ret=obj.HDLSystemInfo.projectinfo.bit_file;
        end

        function ret=get.HDLSystem(obj)

            ret=soc.util.getHSBSubsystem(obj.TopModel);
            if~isempty(ret)
                ret=get_param(ret,'ModelName');
            end
        end

        function set.SoftwareSystemModel(obj,value)
            obj.SoftwareSystemModel=value;
        end

        function obj=SystemDeployer(modelName,varargin)







            p=inputParser();
            validateModelFcn=@(x)isequal(exist(x,'file'),4);
            addRequired(p,'TopModel',validateModelFcn);
            validateFcnHandle=@(x)validateattributes(x,{'function_handle'},{'nonempty'},'ModelConfigurationFcn','Model configuration function');
            addParameter(p,'ModelConfigurationFcn',@ischar,validateFcnHandle);
            addParameter(p,'ConnectHardware',true,@islogical);
            parse(p,modelName,varargin{:});
            if isequal(get_param(modelName,'HardwareBoard'),'None')
                error(message('soc:scheduler:HWBoardNone',modelName));
            end
            obj.ModelConfigurationFcn=p.Results.ModelConfigurationFcn;

            if ispref(soc.internal.getPrefName)&&ispref(soc.internal.getPrefName,'esbhsbdebug')
                dbg=getpref(soc.internal.getPrefName,'esbhsbdebug');
                if~isempty(dbg)
                    obj.Debug=dbg;
                end
            end

            if obj.Debug&&ispref(soc.internal.getPrefName,'DeviceTreeCompiler')
                dtcExe=getpref(soc.internal.getPrefName,'DeviceTreeCompiler');
                if~isempty(dtcExe)&&exist(dtcExe,'file')
                    obj.DeviceTreeCompiler=dtcExe;
                end
            end
            [~,obj.TopModel,~]=fileparts(p.Results.TopModel);
            if obj.Debug&&exist('matlabshared.internal.testssh2','class')

                obj.HWObj=matlabshared.internal.testssh2(matlab.lang.makeValidName(obj.HardwareBoard),'root','root');
            else
                if p.Results.ConnectHardware
                    obj.HWObj=createHardwareObject(obj.HardwareBoard);
                else
                    obj.HWObj=[];
                end
            end


            if codertarget.utils.isESBProcessorOnly(modelName)&&codertarget.utils.isBaremetal(modelName)
                [~,refModels]=soc.util.getESWRefModel(modelName);
                if~iscell(refModels)
                    obj.SoftwareSystemModel=sprintf('%s_sw_%s',obj.TopModel,codertarget.targethardware.getProcessingUnitName(refModels));
                else
                    obj.SoftwareSystemModel={};
                    for i=1:numel(refModels)
                        thisMdl=refModels{i};
                        cs=getActiveConfigSet(thisMdl);
                        pu=codertarget.targethardware.getProcessingUnitInfo(cs);
                        if~isempty(pu.PUAttachedTo),continue;end
                        obj.SoftwareSystemModel{end+1}=...
                        sprintf('%s_sw_%s',obj.TopModel,pu.Name);
                    end
                    if isequal(numel(obj.SoftwareSystemModel),1)
                        obj.SoftwareSystemModel=obj.SoftwareSystemModel{1};
                    end
                end
            else
                obj.SoftwareSystemModel=[obj.TopModel,'_sw'];
            end
        end

        function loadProjectInfo(obj,projectFolder)
            if~isfolder(projectFolder)||~isfile(fullfile(projectFolder,'socsysinfo.mat'))
                error(message('soc:utils:SoCSysInfoEmpty'));
            end
            SoCSysFile=fullfile(projectFolder,'socsysinfo.mat');
            disp(message('soc:utils:SoCSysInfoFile',SoCSysFile).getString);
            socInfo=load(SoCSysFile);
            obj.HDLSystemInfo=socInfo.socsysinfo;

            obj.HDLPrjDir=obj.HDLSystemInfo.projectinfo.prj_dir;
        end

        function generatesocdesign(obj,varargin)











            p=inputParser;

            addParameter(p,'ExternalBuild',true,@islogical);
            addParameter(p,'EnablePrjGen',true,@islogical);
            addParameter(p,'EnableIPCoreGen',true,@islogical);
            addParameter(p,'EnableBitGen',true,@islogical);

            addParameter(p,'SkipHDLCodeGen',false,@islogical);
            addParameter(p,'FPGAPrjDir','',@ischar);
            parse(p,varargin{:});
            obj.DeployerOptions=p.Results;
            rtw_checkdir;
            load_system(obj.TopModel);
            validateProcessingSystem(obj);
            obj.BuildStruct=RTW.getBuildDir(obj.TopModel);
            obj.ChecksumFile=fullfile(obj.BuildStruct.CodeGenFolder,obj.BuildStruct.ModelRefRelativeBuildDir,'model_checksum.mat');
            obj.HDLPrjDir=fullfile(obj.BuildStruct.CodeGenFolder,[obj.HDLSystem,'_prj']);
            set_param(obj.TopModel,'SimulationCommand','Update');

            if obj.DeployerOptions.SkipHDLCodeGen
                disp(message('soc:utils:SkipHDLCodeGen').getString);
                loadProjectInfo(obj,obj.DeployerOptions.FPGAPrjDir);
            else
                disp(message('soc:utils:GenHDLCode',obj.HDLPrjDir).getString);
                generateFPGABitstream(obj);
                socInfo=load(fullfile(obj.HDLPrjDir,'socsysinfo.mat'));
                obj.HDLSystemInfo=socInfo.socsysinfo;
            end
            disp(message('soc:utils:GenSWCode',obj.SoftwareSystemModel).getString);
            generateSoftwareSystem(obj);
            disp(message('soc:utils:GenDevTree').getString);
            generateDeviceTree(obj);
            disp(message('soc:utils:SystemDTB',fullfile(obj.HDLSystemInfo.dtb_file),obj.HDLPrjDir).getString);
            savesocsysinfo(obj);
            open_system(obj.SoftwareSystemModel);
        end

        function deploy(obj,varargin)











            generatesocdesign(obj,varargin{:});
            loadBitstream(obj.HWObj,obj.HDLSystemInfo.projectinfo.bit_file,obj.HDLSystemInfo.dtb_file);
            try
                feval(obj.ModelConfigurationFcn,obj.SoftwareSystemModel);
            catch ME
                disp(message('soc:utils:InvalidMdlConfigFcn',char(obj.ModelConfigurationFcn),ME.message).getString);
                disp(ME.message);
            end
            rtwbuild(obj.SoftwareSystemModel);
        end
    end

    methods(Hidden)
        function savesocsysinfo(obj)
            socsysinfo=obj.HDLSystemInfo;
            save(fullfile(obj.HDLPrjDir,'socsysinfo.mat'),'socsysinfo');
        end

        function dtbFile=generateDeviceTree(obj)
            if obj.Debug&&exist(obj.DeviceTreeCompiler,'file')
                hobj=soc.if.CustomDeviceTreeUpdater.getInstance(obj.HDLSystemInfo,'HardwareObject',obj.HWObj,'DTCExecutable',obj.DeviceTreeCompiler);
            else
                hobj=soc.if.CustomDeviceTreeUpdater.getInstance(obj.HDLSystemInfo,'HardwareObject',obj.HWObj);
            end
            dtbFile=generateDeviceTree(hobj);
            obj.HDLSystemInfo.dtb_file=dtbFile;
        end

        function swModelRet=generateSoftwareSystem(obj)
            if~iscell(obj.SoftwareSystemModel)
                SoftwareModelsToCreate={obj.SoftwareSystemModel};
            else
                SoftwareModelsToCreate=obj.SoftwareSystemModel;
            end
            swModelRet='';
            for i=1:numel(SoftwareModelsToCreate)
                swModel=fullfile(obj.HDLPrjDir,SoftwareModelsToCreate{i});
                if isequal(exist(SoftwareModelsToCreate{i},'file'),4)
                    close_system(SoftwareModelsToCreate{i},0);
                    oldsrc=which(SoftwareModelsToCreate{i});
                    if isfile(oldsrc)
                        bkupMdlName=tempname(obj.HDLPrjDir);
                        [~,bkupName,~]=fileparts(bkupMdlName);
                        warning(message('soc:utils:SWModelExists',SoftwareModelsToCreate{i},bkupName,obj.HDLPrjDir));
                        load_system(SoftwareModelsToCreate{i});
                        model_obj=get_param(SoftwareModelsToCreate{i},'Object');
                        refreshModelBlocks(model_obj);
                        save_system(SoftwareModelsToCreate{i},bkupMdlName);
                        close_system(SoftwareModelsToCreate{i},0);
                        delete(oldsrc);
                    end
                end

                if~isempty(obj.HDLSystem)
                    hdlDirtyFlag=get_param(obj.HDLSystem,'Dirty');
                    resetHDL=onCleanup(@()set_param(obj.HDLSystem,'Dirty',hdlDirtyFlag));
                    set_param(obj.HDLSystem,'Dirty','off');
                end
                hasMultipleCPUs=soc.ui.SoCGenWorkflow.isModelMultiCPU(obj.TopModel);
                modelGen=soc.if.ModelGenerator(obj.TopModel,obj.HDLSystemInfo,obj.HardwareBoard,'AddIODataBlocks',true);
                if~hasMultipleCPUs
                    generateInterfaceModel(modelGen,SoftwareModelsToCreate{i});
                else
                    generateInterfaceModelsForCPUs(modelGen,SoftwareModelsToCreate{i});
                end
                load_system(SoftwareModelsToCreate{i});
                model_obj=get_param(SoftwareModelsToCreate{i},'Object');
                refreshModelBlocks(model_obj);

                sfname=[SoftwareModelsToCreate{i},'.slx'];
                save_system(SoftwareModelsToCreate{i},fullfile(obj.HDLPrjDir,sfname));
                disp(message('soc:utils:SystemModel',fullfile(obj.HDLPrjDir,sfname)).getString);
                if isfield(obj.HDLSystemInfo.projectinfo,'sw_system')&&~isempty(obj.HDLSystemInfo.projectinfo.sw_system)
                    obj.HDLSystemInfo.projectinfo.sw_system=[obj.HDLSystemInfo.projectinfo.sw_system,{[swModel,'.slx']}];
                else
                    obj.HDLSystemInfo.projectinfo.sw_system=[swModel,'.slx'];
                end
                if~isempty(swModelRet)
                    swModelRet=[swModelRet,{[swModel,'.slx']}];%#ok<AGROW>
                else
                    swModelRet=[swModel,'.slx'];
                end
            end
        end
    end

    methods(Access=private)
        function generateFPGABitstream(obj)
            genfpgadesign(obj.TopModel,...
            'PrjDir',obj.HDLPrjDir,...
            'ExternalBuild',obj.DeployerOptions.ExternalBuild,...
            'EnableBitGen',obj.DeployerOptions.EnableBitGen,...
            'EnablePrjGen',obj.DeployerOptions.EnablePrjGen,...
            'EnableIPCoreGen',obj.DeployerOptions.EnableIPCoreGen);
        end

        function validateProcessingSystem(obj)
            ctData=get_param(obj.TopModel,'CoderTargetData');
            if isfield(ctData,'FPGADesign')&&isfield(ctData.FPGADesign,'IncludeProcessingSystem')
                mdlConfigSet=getActiveConfigSet(obj.TopModel);
                if~isequal(codertarget.data.getParameterValue(mdlConfigSet,'FPGADesign.IncludeProcessingSystem'),1)
                    msgObj=message('soc:utils:ProcessingSystemNotEnabled',obj.TopModel);
                    me=MSLException(get_param(obj.TopModel,'handle'),msgObj);
                    throw(me);
                end
            end
        end
    end

    methods(Static,Hidden)

        function rebootFunction(hwObj)
            validateattributes(hwObj,{'ioplayback.hardware.Base','matlabshared.internal.LinuxSystemInterface','matlabshared.internal.SystemInterface'},{'nonempty'},'set.HwObj','Hardware connection object',1);
            system(hwObj,'sync');
            system(hwObj,'reboot');
            pause(10);
        end

        function list=formatCellArrayToString(arr,delim)

            if nargin<2
                delim='';
            end
            list='';
            for i=1:numel(arr)-1
                list=[list,arr{i},delim,' '];%#ok<AGROW>
            end
            list=[list,arr{end}];
        end
    end
end





