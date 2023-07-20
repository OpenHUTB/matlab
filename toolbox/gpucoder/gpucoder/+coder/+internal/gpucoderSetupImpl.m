classdef gpucoderSetupImpl<matlab.apps.AppBase


    properties(Access=public)
        GPUEnvironmentCheckUIFigure matlab.ui.Figure
        GPUCodeGenerationEnvironmentCheckSetupLabel matlab.ui.control.Label
        SelectHardwareDropDownLabel matlab.ui.control.Label
        SelectHardwareDropDown matlab.ui.control.DropDown
        SelectGPUDropDownLabel matlab.ui.control.Label
        SelectGPUDropDown matlab.ui.control.DropDown
        EnvironmentChecksPanel matlab.ui.container.Panel
        CUDAInstallationPathEditFieldLabel matlab.ui.control.Label
        CUDAInstallationPathEditField matlab.ui.control.EditField
        cuDNNEditFieldLabel matlab.ui.control.Label
        cuDNNEditField matlab.ui.control.EditField
        TensorRTEditFieldLabel matlab.ui.control.Label
        TensorRTEditField matlab.ui.control.EditField
        CUDAbrowse_button matlab.ui.control.Button
        cuDNNbrowse_button matlab.ui.control.Button
        TensorRTbrowse_button matlab.ui.control.Button
        NVTXbrowse_button matlab.ui.control.Button
        NVTXLibraryPathLabel matlab.ui.control.Label
        NVTXLibraryPathEditField matlab.ui.control.EditField
        WorkflowChecksPanel matlab.ui.container.Panel
        BasicCodeGenerationPanel matlab.ui.container.Panel
        BasicCodeGenerationWorkflow matlab.ui.container.ButtonGroup
        GenerateCodeBasicButton matlab.ui.control.RadioButton
        GenerateandExecuteBasicButton matlab.ui.control.RadioButton
        SILProfilingCheckBox matlab.ui.control.CheckBox
        DeepLearningCodeGenerationPanel matlab.ui.container.Panel
        TargetLabel matlab.ui.control.Label
        DeepLearning_Target_DropDown matlab.ui.control.DropDown
        DataTypeLabel matlab.ui.control.Label
        CheckLabel matlab.ui.control.Label
        DeepLearning_Target_DropDown_2 matlab.ui.control.DropDown
        DeepLearningWorkflow matlab.ui.container.ButtonGroup
        GenerateCodeDeepButton matlab.ui.control.RadioButton
        GenerateandExecuteDeepButton matlab.ui.control.RadioButton
        BasicCodeGen_CheckBox matlab.ui.control.CheckBox
        DeepLearning_CheckBox matlab.ui.control.CheckBox
        Button matlab.ui.control.Button
        RunChecksButton matlab.ui.control.Button
        GpuErrorMsg matlab.ui.control.Label
        ExportSettingsButton matlab.ui.control.Button
        BoardSettingsPanel matlab.ui.container.Panel
        DeviceAddressEditFieldLabel matlab.ui.control.Label
        DeviceAddressEditField matlab.ui.control.EditField
        UsernameEditFieldLabel matlab.ui.control.Label
        UsernameEditField matlab.ui.control.EditField
        PasswordEditFieldLabel matlab.ui.control.Label
        PasswordEditField matlab.ui.control.EditField
        GPUDeviceIdEditFieldLabel matlab.ui.control.Label
        GPUDeviceIdEditField matlab.ui.control.EditField
        ClearButton matlab.ui.control.Button
        ConnectButton matlab.ui.control.Button
        ExecutionTimeoutEditFieldLabel matlab.ui.control.Label
        ExecutionTimeoutEditField matlab.ui.control.EditField
    end


    properties(Access=private)
gpu_found
numGpu
defaultGpuIndex
gpu_struct
hardware
gpuID
valid_cuda_path
valid_cudnn_path
valid_tensorrt_path
valid_nvtx_path
basiccodegen
basiccodeexec
deepcodegen
deepcodeexec
deeplibtarget
datatype
profiling
boardsettings
hardwareconfig
timeout
connectPrompt
    end

    properties(Hidden)
result
testEnv
    end

    methods(Access=private)


        function hostReset(app)
            app.SelectGPUDropDown.Visible='off';
            app.SelectGPUDropDownLabel.Visible='off';
            app.GpuErrorMsg.Visible='off';
            app.BoardSettingsPanel.Visible='off';
            app.EnvironmentChecksPanel.Visible='on';
            app.WorkflowChecksPanel.Position=[14,302,567,201];
            app.ExportSettingsButton.Enable=true;
            app.SILProfilingCheckBox.Value=false;
            app.NVTXLibraryPathEditField.Enable=false;
            app.NVTXLibraryPathLabel.Enable=false;
            app.RunChecksButton.Enable='on';


            app.CUDAInstallationPathEditField.Enable='on';
            app.CUDAInstallationPathEditFieldLabel.Enable='on';
            app.CUDAInstallationPathEditField.Editable='on';
            app.CUDAbrowse_button.Enable='on';


            if app.BasicCodeGen_CheckBox.Value
                app.SILProfilingCheckBox.Enable='on';
            end

            if app.gpu_found
                app.SelectGPUDropDown.Visible='on';
                app.SelectGPUDropDownLabel.Visible='on';
                app.SelectGPUDropDown.Items=app.gpu_struct;
                app.SelectGPUDropDown.ItemsData=1:app.numGpu;
                app.SelectGPUDropDown.Value=app.defaultGpuIndex;
                app.gpuID=app.defaultGpuIndex;
            else
                if app.numGpu>0
                    app.GpuErrorMsg.Text=string(message('gpucoder:system:compatible_driver_not_found'));
                else
                    app.gpuID=0;
                    app.GpuErrorMsg.Text=string(message('gpucoder:system:compatible_gpu_not_found'));
                end
                app.GpuErrorMsg.Position=[18,521,559,44];
                app.GpuErrorMsg.FontAngle='italic';
                app.GpuErrorMsg.FontColor=[1,0,0];
                app.GpuErrorMsg.Visible='on';
                app.SelectGPUDropDown.Visible='off';
                app.SelectGPUDropDownLabel.Visible='off';
            end



            cudaenv=coder.internal.getCudaPath();

            if(isempty(cudaenv))
                app.CUDAInstallationPathEditField.Value=message('gpucoder:system:gpucodersetup_cudaenv_not_found').getString;
                app.CUDAInstallationPathEditField.FontAngle='italic';
                app.CUDAInstallationPathEditField.FontColor='red';
                app.valid_cuda_path=false;
            else
                app.CUDAInstallationPathEditField.Value=cudaenv;
                app.CUDAInstallationPathEditField.FontColor='black';
                app.valid_cuda_path=true;
            end


            cudnnPath=getenv('NVIDIA_CUDNN');

            if(isempty(cudnnPath))
                app.cuDNNEditField.Value=message('gpucoder:system:gpucodersetup_cudnn_not_found').getString;
                app.cuDNNEditField.FontColor='red';
                app.cuDNNEditField.FontAngle='italic';
                app.valid_cudnn_path=false;
            else
                app.cuDNNEditField.Value=cudnnPath;
                app.cuDNNEditField.FontColor='black';
                app.valid_cudnn_path=true;
            end


            tensorRTPath=getenv('NVIDIA_TENSORRT');

            if(isempty(tensorRTPath))
                app.TensorRTEditField.Value=message('gpucoder:system:gpucodersetup_tensorrt_not_found').getString;
                app.TensorRTEditField.FontColor='red';
                app.TensorRTEditField.FontAngle='italic';
                app.valid_tensorrt_path=false;
            else
                app.TensorRTEditField.Value=tensorRTPath;
                app.TensorRTEditField.FontColor='black';
                app.valid_tensorrt_path=true;
            end


            nvtxPath=coder.internal.getNvtxPath();
            if(isempty(nvtxPath))
                app.NVTXLibraryPathEditField.Value=message('gpucoder:system:gpucodersetup_nvtx_not_found').getString;
                app.NVTXLibraryPathEditField.FontColor='red';
                app.NVTXLibraryPathEditField.FontAngle='italic';
                app.valid_nvtx_path=false;
            else
                app.NVTXLibraryPathEditField.Value=nvtxPath;
                app.NVTXLibraryPathEditField.FontColor='black';
                app.valid_nvtx_path=true;
            end

        end

        function resetBoardSettings(app,clearSettings)


            app.hardwareconfig=[];
            app.SelectGPUDropDown.Visible='off';
            app.SelectGPUDropDownLabel.Visible='off';
            app.GpuErrorMsg.Visible='off';
            app.ConnectButton.Enable='on';
            app.RunChecksButton.Enable='on';
            app.BoardSettingsPanel.Visible='on';
            app.EnvironmentChecksPanel.Visible='off';
            app.WorkflowChecksPanel.Position=[14,78,567,201];
            app.ExportSettingsButton.Enable=false;
            app.SILProfilingCheckBox.Value=false;
            app.SILProfilingCheckBox.Enable=false;


            app.CUDAInstallationPathEditField.Value='';
            app.cuDNNEditField.Value='';
            app.TensorRTEditField.Value='';
            app.NVTXLibraryPathEditField.Value='';


            boardObj=[];
            if coder.internal.isHSPInstalled
                boardType=['NVIDIA ',app.hardware];
                boardObj=coder.Hardware(boardType);
            end
            if isempty(boardObj)||clearSettings
                app.DeviceAddressEditField.Value='';
                app.UsernameEditField.Value='';
                app.PasswordEditField.Value='';
            else
                app.DeviceAddressEditField.Value=boardObj.DeviceAddress;
                app.UsernameEditField.Value=boardObj.Username;
                app.PasswordEditField.Value=boardObj.Password;
            end

            if clearSettings
                app.GPUDeviceIdEditField.Value='';
                app.ExecutionTimeoutEditField.Value='';
            else
                app.GPUDeviceIdEditField.Value='0';
                app.ExecutionTimeoutEditField.Value='10';
            end
            app.gpuID=0;


            if strcmp(app.hardware,'Jetson')
                app.GPUDeviceIdEditField.Enable=false;
                app.GPUDeviceIdEditFieldLabel.Enable=false;
            elseif strcmp(app.hardware,'Drive')
                app.GPUDeviceIdEditField.Enable=true;
                app.GPUDeviceIdEditFieldLabel.Enable=true;
            end


            app.ConnectButton.Enable='on';
            app.DeviceAddressEditField.Enable=true;
            app.DeviceAddressEditFieldLabel.Enable=true;
            app.UsernameEditField.Enable=true;
            app.UsernameEditFieldLabel.Enable=true;
            app.PasswordEditField.Enable=true;
            app.PasswordEditFieldLabel.Enable=true;


            if~coder.internal.isHSPInstalled
                app.GpuErrorMsg.Position=[18,521,559,44];
                app.GpuErrorMsg.Text=string(message('gpucoder:system:gpu_check_no_hsp_app'));
                app.GpuErrorMsg.FontAngle='italic';
                app.GpuErrorMsg.FontColor=[1,0,0];
                app.GpuErrorMsg.Visible='on';
                app.ConnectButton.Enable='off';
                app.RunChecksButton.Enable='off';
                return;
            end
        end

        function createScript(app)

            scriptname='gpuEnvSettings.m';
            fID=fopen(scriptname,'w+');
            if fID==-1
                msgString=string(message('gpucoder:system:file_open_error_script'));
                uiString=string(message('gpucoder:system:gpucodersetup_uistr_fileopen'));
                if app.testEnv
                    errorStruct.message=msgString;
                    errorStruct.identifier='checkInstall:noWritePermissions';
                    error(errorStruct);
                else
                    uialert(app.GPUEnvironmentCheckUIFigure,msgString,uiString);
                end

                return;
            end
            fprintf(fID,message('gpucoder:system:gpucodersetup_script_msg',datestr(now)).getString);


            if app.gpu_found
                fprintf(fID,message('gpucoder:system:gpucodersetup_script_selecting_gpu').getString);
                fprintf(fID,'gpuDevice(%s);',num2str(app.gpuID));
            end


            if app.valid_cuda_path
                fprintf(fID,message('gpucoder:system:gpucodersetup_script_cuda_path').getString);
                if ispc
                    fprintf(fID,'setenv(''CUDA_PATH'', [''%s'' pathsep getenv(''CUDA_PATH'')]);',app.CUDAInstallationPathEditField.Value);
                else
                    cudaDir=app.CUDAInstallationPathEditField.Value;
                    libPath=fullfile(cudaDir,'lib64');
                    nvccPath=fullfile(cudaDir,'bin');
                    fprintf(fID,'setenv(''LD_LIBRARY_PATH'', [''%s'' pathsep getenv(''LD_LIBRARY_PATH'')]);',libPath);
                    fprintf(fID,'\n');
                    fprintf(fID,'setenv(''PATH'', [''%s'' pathsep getenv(''PATH'')]);',nvccPath);
                end
            end


            if app.valid_cudnn_path
                fprintf(fID,message('gpucoder:system:gpucodersetup_script_cudnn_path').getString);
                fprintf(fID,'setenv(''NVIDIA_CUDNN'',''%s'');',app.cuDNNEditField.Value);
            end


            if app.valid_tensorrt_path
                fprintf(fID,message('gpucoder:system:gpucodersetup_script_tensorrt_path').getString);
                fprintf(fID,'setenv(''NVIDIA_TENSORRT'',''%s'');',app.TensorRTEditField.Value);
            end


            if app.valid_nvtx_path
                fprintf(fID,message('gpucoder:system:gpucodersetup_script_nvtx_path').getString);
                if ispc
                    fprintf(fID,'setenv(''NVTOOLSEXT_PATH'',''%s'');',app.NVTXLibraryPathEditField.Value);
                else
                    nvtxPath=app.NVTXLibraryPathEditField.Value;
                    fprintf(fID,'setenv(''LD_LIBRARY_PATH'', [''%s'' pathsep getenv(''LD_LIBRARY_PATH'')]);',nvtxPath);
                end
            end


            fclose(fID);


            msgString=string(message('gpucoder:system:script_saved_message'));
            uiString=string(message('gpucoder:system:gpucodersetup_uistr_savesettings'));
            if app.testEnv
                disp(msgString);
            else
                uiconfirm(app.GPUEnvironmentCheckUIFigure,msgString,uiString,...
                'Icon','success','Options',{'OK'});
            end

        end

        function status=checkInputsForErrors(app)
            target=app.SelectHardwareDropDown.Value;
            app.timeout=str2double(app.ExecutionTimeoutEditField.Value);
            if strcmp(target,'Drive')
                app.gpuID=str2double(app.GPUDeviceIdEditField.Value);
            else
                app.gpuID=0;
            end

            any_setting_empty=isempty(app.DeviceAddressEditField.Value)||...
            isempty(app.UsernameEditField.Value)||...
            isempty(app.PasswordEditField.Value)||...
            isempty(app.ExecutionTimeoutEditField.Value);
            if strcmp(target,'Drive')
                any_setting_empty=any_setting_empty||isempty(app.GPUDeviceIdEditField.Value);
            end

            status=true;
            if any_setting_empty
                msgString=string(message('gpucoder:system:incomplete_board_settings'));
                uiString=string(message('gpucoder:system:gpucodersetup_uistr_incompinputs'));
                identifier='checkInstall:incomplete_board_settings';
                status=false;
            elseif isnan(app.timeout)||~isa(app.timeout,'double')||...
                ~isscalar(app.timeout)||app.timeout<=0
                msgString=string(message('gpucoder:system:invalid_input_timeout'));
                uiString=string(message('gpucoder:system:gpucodersetup_uistr_invalidinput'));
                identifier='checkInstall:invalid_input_timeout';
                status=false;
            end


            if~status
                if app.testEnv
                    errorStruct.message=msgString;
                    errorStruct.identifier=identifier;
                    error(errorStruct);
                else
                    uialert(app.GPUEnvironmentCheckUIFigure,msgString,uiString,'Icon','warning');
                end
            end
        end

        function status=makeConnection(app)

            status=checkInputsForErrors(app);
            if~status
                return;
            end


            if strcmp(app.ConnectButton.Enable,'off')
                return;
            end

            target=app.SelectHardwareDropDown.Value;
            uiString=string(message('gpucoder:system:gpucodersetup_uistr_connboard'));
            f=app.GPUEnvironmentCheckUIFigure;
            d=uiprogressdlg(f,'Title',uiString,'Indeterminate','on');

            settings={app.DeviceAddressEditField.Value,...
            app.UsernameEditField.Value,...
            app.PasswordEditField.Value};%#ok<NASGU> 

            try
                if strcmp(target,'Jetson')
                    evalc('hwObj = jetson(settings{1},settings{2},settings{3})');
                elseif strcmp(target,'Drive')
                    evalc('hwObj = drive(settings{1},settings{2},settings{3})');
                end
            catch e
                uiString=string(message('gpucoder:system:gpucodersetup_uistr_connfailure'));
                msgString=string(message('gpucoder:system:error_board_connection',e.message));
                close(d);
                if app.testEnv
                    errorStruct.message=msgString;
                    errorStruct.identifier='checkInstall:ConnectionFailure';
                    error(errorStruct);
                else
                    uialert(app.GPUEnvironmentCheckUIFigure,msgString,uiString);
                end
            end


            if exist('hwObj','var')
                close(d);
                processConnection(app,hwObj);
            end
        end

        function processConnection(app,hwObj)

            if app.connectPrompt
                uiString=string(message('gpucoder:system:gpucodersetup_uistr_connsuccess'));
                msgString=string(message('gpucoder:system:success_board_connection'));
                if app.testEnv
                    disp(msgString);
                else
                    uialert(app.GPUEnvironmentCheckUIFigure,msgString,uiString,'Icon','success');
                end
            end

            app.hardwareconfig=hwObj;
            app.GpuErrorMsg.Text=message('gpucoder:system:gpucodersetup_uistr_connected',hwObj.BoardName).getString;
            app.GpuErrorMsg.Position=[180,543,467,22];
            app.GpuErrorMsg.FontColor=[0,0,1];
            app.GpuErrorMsg.FontAngle='italic';
            app.GpuErrorMsg.Visible='on';
            app.ConnectButton.Enable='off';


            app.DeviceAddressEditField.Enable=false;
            app.DeviceAddressEditFieldLabel.Enable=false;
            app.UsernameEditField.Enable=false;
            app.UsernameEditFieldLabel.Enable=false;
            app.PasswordEditField.Enable=false;
            app.PasswordEditFieldLabel.Enable=false;
        end

        function processStartupStringsAndDefaults(app)
            app.GPUEnvironmentCheckUIFigure.Name=message('gpucoder:system:gpucodersetup_prop_fig_name').getString;
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.Text=message('gpucoder:system:gpucodersetup_prop_fig_desc').getString;
            app.SelectHardwareDropDownLabel.Text=message('gpucoder:system:gpucodersetup_prop_hwmenu_label').getString;
            app.SelectGPUDropDownLabel.Text=message('gpucoder:system:gpucodersetup_prop_gpumenu_label').getString;

            app.WorkflowChecksPanel.Title=message('gpucoder:system:gpucodersetup_prop_workchecks_panel').getString;
            app.BasicCodeGenerationPanel.Title=message('gpucoder:system:gpucodersetup_prop_basiccodegen').getString;
            app.GenerateCodeBasicButton.Text=message('gpucoder:system:gpucodersetup_prop_gencode').getString;
            app.GenerateandExecuteBasicButton.Text=message('gpucoder:system:gpucodersetup_prop_execcode').getString;
            app.SILProfilingCheckBox.Text=message('gpucoder:system:gpucodersetup_prop_silprof').getString;
            app.DeepLearningCodeGenerationPanel.Title=message('gpucoder:system:gpucodersetup_prop_dlcodegen').getString;
            app.GenerateCodeDeepButton.Text=message('gpucoder:system:gpucodersetup_prop_gencode').getString;
            app.GenerateandExecuteDeepButton.Text=message('gpucoder:system:gpucodersetup_prop_execcode').getString;
            app.TargetLabel.Text=message('gpucoder:system:gpucodersetup_prop_target').getString;
            app.DataTypeLabel.Text=message('gpucoder:system:gpucodersetup_prop_data_type').getString;
            app.CheckLabel.Text=message('gpucoder:system:gpucodersetup_prop_check').getString;

            app.EnvironmentChecksPanel.Title=message('gpucoder:system:gpucodersetup_prop_envchecks_panel').getString;
            app.CUDAInstallationPathEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_cudapath_label').getString;
            app.cuDNNEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_cudnnpath_label').getString;
            app.TensorRTEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_tensorrtpath_label').getString;
            app.NVTXLibraryPathLabel.Text=message('gpucoder:system:gpucodersetup_prop_nvtxpath_label').getString;
            app.CUDAbrowse_button.Tooltip=message('gpucoder:system:gpucodersetup_prop_cudapath_tooltip').getString;
            app.cuDNNbrowse_button.Tooltip=message('gpucoder:system:gpucodersetup_prop_cudnnpath_tooltip').getString;
            app.TensorRTbrowse_button.Tooltip=message('gpucoder:system:gpucodersetup_prop_tensorrtpath_tooltip').getString;
            app.NVTXbrowse_button.Tooltip=message('gpucoder:system:gpucodersetup_prop_nvtxpath_tooltip').getString;

            app.Button.Tooltip=message('gpucoder:system:gpucodersetup_prop_doc_tooltip').getString;
            app.RunChecksButton.Text=message('gpucoder:system:gpucodersetup_prop_runchks_button').getString;
            app.RunChecksButton.Tooltip=message('gpucoder:system:gpucodersetup_prop_runchks_tooltip').getString;
            app.ExportSettingsButton.Text=message('gpucoder:system:gpucodersetup_prop_export_button').getString;
            app.ExportSettingsButton.Tooltip=message('gpucoder:system:gpucodersetup_prop_export_tooltip').getString;
            app.ClearButton.Text=message('gpucoder:system:gpucodersetup_prop_clear_button').getString;
            app.ClearButton.Tooltip=message('gpucoder:system:gpucodersetup_prop_clear_tooltip').getString;
            app.ConnectButton.Text=message('gpucoder:system:gpucodersetup_prop_connect_button').getString;
            app.ConnectButton.Tooltip=message('gpucoder:system:gpucodersetup_prop_connect_tooltip').getString;
            app.GpuErrorMsg.Text=message('gpucoder:system:compatible_gpu_not_found').getString;
            app.BoardSettingsPanel.Title=message('gpucoder:system:gpucodersetup_prop_board_panel').getString;
            app.DeviceAddressEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_device_addr').getString;
            app.UsernameEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_device_usrn').getString;
            app.PasswordEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_device_pswd').getString;
            app.GPUDeviceIdEditFieldLabel.Text=message('gpucoder:system:gpucodersetup_prop_device_devid').getString;
        end
    end



    methods(Access=private)


        function startupFcn(app)

            processStartupStringsAndDefaults(app);


            set(0,'ShowHiddenHandles','on');
            openFigures=get(0,'Children');
            set(0,'ShowHiddenHandles','off');
            appInstances=0;
            figName=message('gpucoder:system:gpucodersetup_prop_fig_name').getString;
            for i=1:length(openFigures)
                if isprop(openFigures(i),'Name')&&strcmp(openFigures(i).Name,figName)
                    appInstances=appInstances+1;
                    if appInstances>1
                        delete(app);
                        error(message('gpucoder:system:app_open_error'));
                    end
                end
            end


            app.gpu_found=false;
            app.valid_cuda_path=false;
            app.valid_cudnn_path=false;
            app.valid_tensorrt_path=false;
            app.valid_nvtx_path=false;


            app.SelectGPUDropDown.Visible='off';
            app.SelectGPUDropDownLabel.Visible='off';
            app.GpuErrorMsg.Visible='off';
            app.defaultGpuIndex=-1;


            app.numGpu=gpuDeviceCount;
            if app.numGpu>0

                computeWarnId='parallel:gpu:device:DeviceDeprecated';
                warning('off',computeWarnId);
                try

                    gpuCurrent=gpuDevice;
                    if app.defaultGpuIndex==-1
                        app.defaultGpuIndex=gpuCurrent.Index;
                    end
                    app.gpu_found=true;
                    app.gpu_struct={};
                    for i=1:app.numGpu
                        gDevice(i)=gpuDevice(i);%#ok<AGROW> 
                        app.gpu_struct{i}=strcat('GPU',int2str(i-1),'-',gDevice(i).Name);
                    end


                    gpuDevice(app.defaultGpuIndex);
                catch e %#ok<NASGU> 

                end

                warning('on',computeWarnId);
            end


            value=app.SelectHardwareDropDown.Value;
            if strncmp(value,'Host',4)
                app.hardware='Host';
                hostReset(app);
            end
            app.testEnv=0;
        end


        function SelectHardwareDropDownValueChanged(app,event)
            value=app.SelectHardwareDropDown.Value;
            if strncmp(value,'Host',4)
                app.hardware='Host';
                hostReset(app);
            else
                app.hardware=value;
                resetBoardSettings(app,false);
            end
        end


        function ButtonPushed(app,event)
            helpview([docroot,'\gpucoder\helptargets.map'],'checkGpuInstall_app');
        end


        function BasicCodeGen_CheckBoxValueChanged(app,event)
            value=app.BasicCodeGen_CheckBox.Value;

            if value

                app.GenerateCodeBasicButton.Enable='on';
                target=app.SelectHardwareDropDown.Value;
                isHost=strncmp(target,'Host',4);
                if app.gpu_found||~isHost
                    app.GenerateandExecuteBasicButton.Enable='on';
                end


                if isHost
                    app.SILProfilingCheckBox.Enable='on';
                    if app.SILProfilingCheckBox.Value
                        app.NVTXLibraryPathEditField.Enable='on';
                        app.NVTXLibraryPathLabel.Enable='on';
                        app.NVTXLibraryPathEditField.Editable='on';
                        app.NVTXbrowse_button.Enable='on';
                    end
                end

            else


                app.GenerateCodeBasicButton.Enable='off';
                app.GenerateandExecuteBasicButton.Enable='off';
                app.SILProfilingCheckBox.Enable='off';


                app.NVTXLibraryPathEditField.Enable='off';
                app.NVTXLibraryPathLabel.Enable='off';
                app.NVTXLibraryPathEditField.Editable='off';
                app.NVTXbrowse_button.Enable='off';
            end



        end


        function DeepLearning_CheckBoxValueChanged(app,event)
            value=app.DeepLearning_CheckBox.Value;

            if value


                app.DeepLearning_Target_DropDown.Enable='on';
                app.TargetLabel.Enable='on';


                app.GenerateCodeDeepButton.Enable='on';
                target=app.SelectHardwareDropDown.Value;
                isHost=strncmp(target,'Host',4);
                if app.gpu_found||~isHost
                    app.GenerateandExecuteDeepButton.Enable='on';
                end


                if strcmp(app.DeepLearning_Target_DropDown.Value,'cuDNN')


                    app.DeepLearning_Target_DropDown_2.Enable='off';
                    app.DataTypeLabel.Enable='off';
                    app.CheckLabel.Enable='off';


                    app.cuDNNEditField.Enable='on';
                    app.cuDNNEditFieldLabel.Enable='on';
                    app.cuDNNbrowse_button.Enable='on';

                    app.TensorRTEditField.Enable='off';
                    app.TensorRTEditFieldLabel.Enable='off';
                    app.TensorRTbrowse_button.Enable='off';

                else


                    if app.gpu_found
                        app.DeepLearning_Target_DropDown_2.Enable='on';
                        app.DataTypeLabel.Enable='on';
                        app.CheckLabel.Enable='on';
                    end


                    app.cuDNNEditField.Enable='on';
                    app.cuDNNEditFieldLabel.Enable='on';
                    app.cuDNNbrowse_button.Enable='on';

                    app.TensorRTEditField.Enable='on';
                    app.TensorRTEditFieldLabel.Enable='on';
                    app.TensorRTbrowse_button.Enable='on';

                end

            else


                app.DeepLearning_Target_DropDown.Enable='off';
                app.DeepLearning_Target_DropDown_2.Enable='off';
                app.TargetLabel.Enable='off';
                app.DataTypeLabel.Enable='off';
                app.CheckLabel.Enable='off';


                app.GenerateCodeDeepButton.Enable='off';
                app.GenerateandExecuteDeepButton.Enable='off';


                app.cuDNNEditField.Enable='off';
                app.cuDNNEditFieldLabel.Enable='off';
                app.cuDNNbrowse_button.Enable='off';


                app.TensorRTEditField.Enable='off';
                app.TensorRTEditFieldLabel.Enable='off';
                app.TensorRTbrowse_button.Enable='off';
            end
        end


        function CUDAbrowse_buttonButtonPushed(app,event)

            uiString=message('gpucoder:system:gpucodersetup_select_cuda_path').getString;
            if app.valid_cuda_path
                selpath=uigetdir(app.CUDAInstallationPathEditField.Value,uiString);
            else
                selpath=uigetdir(matlabroot,uiString);
            end

            if selpath
                app.CUDAInstallationPathEditField.Value=selpath;
                app.CUDAInstallationPathEditField.FontColor='black';
                app.CUDAInstallationPathEditField.FontAngle='normal';
            end
        end


        function cuDNNbrowse_buttonButtonPushed(app,event)

            uiString=message('gpucoder:system:gpucodersetup_select_cudnn_path').getString;
            if app.valid_cudnn_path
                selpath=uigetdir(app.cuDNNEditField.Value,uiString);
            else
                selpath=uigetdir(matlabroot,uiString);
            end

            if selpath
                app.cuDNNEditField.Value=selpath;
                app.cuDNNEditField.FontColor='black';
                app.cuDNNEditField.FontAngle='normal';
            end
        end


        function TensorRTbrowse_buttonButtonPushed(app,event)

            uiString=message('gpucoder:system:gpucodersetup_select_tensorrt_path').getString;
            if app.valid_tensorrt_path
                selpath=uigetdir(app.TensorRTEditField.Value,uiString);
            else
                selpath=uigetdir(matlabroot,uiString);
            end

            if selpath
                app.TensorRTEditField.Value=selpath;
                app.TensorRTEditField.FontColor='black';
                app.TensorRTEditField.FontAngle='normal';
            end
        end


        function ExportSettingsButtonPushed(app,event)

            createScript(app);
        end


        function RunChecksButtonPushed(app,event)

            reportName=fullfile(pwd,'gpucoderSetupReport.html');
            htmlFile=fopen(reportName,'w+');
            if htmlFile==-1
                uiString=message('gpucoder:system:gpucodersetup_uistr_fileopen').getString;
                msgString=string(message('gpucoder:system:file_open_error_report'));
                if app.testEnv
                    errorStruct.message=msgString;
                    errorStruct.identifier='checkInstall:noWritePermissions';
                    error(errorStruct);
                else
                    uialert(app.GPUEnvironmentCheckUIFigure,msgString,uiString);
                end
                return;
            end
            fclose(htmlFile);

            if~strcmp(app.hardware,'Host')
                app.connectPrompt=false;
                status=makeConnection(app);
                if~status
                    return;
                end
            end

            if app.BasicCodeGen_CheckBox.Value
                if app.GenerateCodeBasicButton.Value
                    app.basiccodeexec=0;
                    app.basiccodegen=1;
                elseif app.GenerateandExecuteBasicButton.Value
                    app.basiccodeexec=1;
                    app.basiccodegen=1;
                end

            else
                app.basiccodegen=0;
                app.basiccodeexec=0;
            end

            if app.DeepLearning_CheckBox.Value

                app.deeplibtarget=lower(app.DeepLearning_Target_DropDown.Value);
                app.datatype=lower(app.DeepLearning_Target_DropDown_2.Value);

                if app.GenerateCodeDeepButton.Value
                    app.deepcodeexec=0;
                    app.deepcodegen=1;

                elseif app.GenerateandExecuteDeepButton.Value
                    app.deepcodeexec=1;
                    app.deepcodegen=1;
                end
            else
                app.deepcodegen=0;
                app.deepcodeexec=0;
                app.deeplibtarget='';
                app.datatype='';
            end

            gpuEnvConfigObj=coder.gpuEnvConfig(app.hardware);
            gpuEnvConfigObj.BasicCodegen=app.basiccodegen;
            gpuEnvConfigObj.BasicCodeexec=app.basiccodeexec;
            gpuEnvConfigObj.DeepLibTarget=app.deeplibtarget;
            gpuEnvConfigObj.DeepCodegen=app.deepcodegen;
            gpuEnvConfigObj.DeepCodeexec=app.deepcodeexec;
            gpuEnvConfigObj.GenReport=1;

            if strcmp(gpuEnvConfigObj.DeepLibTarget,'tensorrt')
                gpuEnvConfigObj.DataType=app.datatype;
            else
                gpuEnvConfigObj.DataType='';
            end

            if~strcmp(app.hardware,'Host')
                assert(~isempty(app.hardwareconfig));
                gpuEnvConfigObj.HardwareObject=app.hardwareconfig;
                gpuEnvConfigObj.GpuId=app.gpuID;
                gpuEnvConfigObj.ExecTimeout=app.timeout;
            else
                if app.gpu_found
                    gpuEnvConfigObj.GpuId=app.gpuID-1;
                else
                    gpuEnvConfigObj.GpuId=0;
                end
                app.profiling=app.SILProfilingCheckBox.Value;
                gpuEnvConfigObj.CudaPath=app.CUDAInstallationPathEditField.Value;
                gpuEnvConfigObj.CudnnPath=app.cuDNNEditField.Value;
                gpuEnvConfigObj.TensorrtPath=app.TensorRTEditField.Value;
                gpuEnvConfigObj.NvtxPath=app.NVTXLibraryPathEditField.Value;
                gpuEnvConfigObj.Profiling=app.profiling;
            end



            f=app.GPUEnvironmentCheckUIFigure;
            uiMesg=message('gpucoder:system:gpucodersetup_uistr_checking_env').getString;
            uiTitle=message('gpucoder:system:gpucodersetup_uistr_running_chks').getString;
            d=uiprogressdlg(f,'Title',uiTitle,'Message',uiMesg);

            pause(.5)
            d.Value=.33;
            pause(.5)
            d.Value=0.67;


            [app.result,reportName]=coder.checkGpuInstall(gpuEnvConfigObj);


            pause(.5)
            d.Value=1;
            uiMesg=message('gpucoder:system:gpucodersetup_uistr_gen_report').getString;
            d.Message=uiMesg;
            pause(1)
            close(d);
            web(reportName);
        end


        function DeepLearning_Target_DropDownValueChanged(app,event)
            value=app.DeepLearning_Target_DropDown.Value;


            if strcmp(value,'cuDNN')


                app.DeepLearning_Target_DropDown_2.Enable='off';
                app.DataTypeLabel.Enable='off';
                app.CheckLabel.Enable='off';


                app.cuDNNEditField.Enable='on';
                app.cuDNNEditFieldLabel.Enable='on';
                app.cuDNNbrowse_button.Enable='on';

                app.TensorRTEditField.Enable='off';
                app.TensorRTEditFieldLabel.Enable='off';
                app.TensorRTbrowse_button.Enable='off';

            else


                if app.gpu_found
                    app.DeepLearning_Target_DropDown_2.Enable='on';
                    app.DataTypeLabel.Enable='on';
                    app.CheckLabel.Enable='on';
                end


                app.cuDNNEditField.Enable='on';
                app.cuDNNEditFieldLabel.Enable='on';
                app.cuDNNbrowse_button.Enable='on';

                app.TensorRTEditField.Enable='on';
                app.TensorRTEditFieldLabel.Enable='on';
                app.TensorRTbrowse_button.Enable='on';

            end
        end


        function SelectGPUDropDownValueChanged(app,event)
            value=app.SelectGPUDropDown.Value;
            app.gpuID=value;
        end


        function ConnectButtonPushed(app,event)
            app.connectPrompt=true;
            makeConnection(app);
        end


        function ClearButtonPushed(app,event)
            resetBoardSettings(app,true);
        end


        function NVTXbrowse_buttonButtonPushed(app,event)

            uiString=message('gpucoder:system:gpucodersetup_select_nvtx_path').getString;
            if app.valid_nvtx_path
                selpath=uigetdir(app.NVTXLibraryPathEditField.Value,uiString);
            else
                selpath=uigetdir(matlabroot,uiString);
            end

            if selpath
                app.NVTXLibraryPathEditField.Value=selpath;
                app.NVTXLibraryPathEditField.FontColor='black';
                app.NVTXLibraryPathEditField.FontAngle='normal';
            end
        end


        function SILProfilingCheckBoxValueChanged(app,event)
            value=app.SILProfilingCheckBox.Value;

            if value
                app.NVTXLibraryPathEditField.Enable='on';
                app.NVTXLibraryPathLabel.Enable='on';
                app.NVTXLibraryPathEditField.Editable='on';
                app.NVTXbrowse_button.Enable='on';
            else
                app.NVTXLibraryPathEditField.Enable='off';
                app.NVTXLibraryPathLabel.Enable='off';
                app.NVTXLibraryPathEditField.Editable='off';
                app.NVTXbrowse_button.Enable='off';
            end

        end


        function CUDAInstallationPathEditFieldValueChanged(app,event)
            value=app.CUDAInstallationPathEditField.Value;
            if exist(value,'dir')
                app.valid_cuda_path=true;
                app.CUDAInstallationPathEditField.FontColor='black';
            else
                app.valid_cuda_path=false;
                app.CUDAInstallationPathEditField.FontColor='red';
            end
        end


        function cuDNNEditFieldValueChanged(app,event)
            value=app.cuDNNEditField.Value;
            if exist(value,'dir')
                app.valid_cudnn_path=true;
                app.cuDNNEditField.FontColor='black';
            else
                app.valid_cudnn_path=false;
                app.cuDNNEditField.FontColor='red';
            end
        end


        function TensorRTEditFieldValueChanged(app,event)
            value=app.TensorRTEditField.Value;
            if exist(value,'dir')
                app.valid_tensorrt_path=true;
                app.TensorRTEditField.FontColor='black';
            else
                app.valid_tensorrt_path=false;
                app.TensorRTEditField.FontColor='red';
            end
        end


        function NVTXLibraryPathEditFieldValueChanged(app,event)
            value=app.NVTXLibraryPathEditField.Value;
            if exist(value,'dir')
                app.valid_nvtx_path=true;
                app.NVTXLibraryPathEditField.FontColor='black';
            else
                app.valid_nvtx_path=false;
                app.NVTXLibraryPathEditField.FontColor='red';
            end
        end


        function CUDAInstallationPathEditFieldValueChanging(app,event)
            app.CUDAInstallationPathEditField.FontColor='black';
        end


        function cuDNNEditFieldValueChanging(app,event)
            app.cuDNNEditField.FontColor='black';
        end


        function TensorRTEditFieldValueChanging(app,event)
            app.TensorRTEditField.FontColor='black';
        end


        function NVTXLibraryPathEditFieldValueChanging(app,event)
            app.NVTXLibraryPathEditField.FontColor='black';
        end
    end


    methods(Access=private)


        function createComponents(app)


            app.GPUEnvironmentCheckUIFigure=uifigure('Visible','off');
            app.GPUEnvironmentCheckUIFigure.Position=[100,100,593,670];
            app.GPUEnvironmentCheckUIFigure.Name='GPU Environment Check';
            app.GPUEnvironmentCheckUIFigure.Resize='off';
            app.GPUEnvironmentCheckUIFigure.BusyAction='cancel';
            app.GPUEnvironmentCheckUIFigure.Interruptible='off';


            app.GPUCodeGenerationEnvironmentCheckSetupLabel=uilabel(app.GPUEnvironmentCheckUIFigure);
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.HorizontalAlignment='center';
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.FontSize=17;
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.FontWeight='bold';
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.FontColor=[0,0.451,0.7412];
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.Position=[80,621,409,22];
            app.GPUCodeGenerationEnvironmentCheckSetupLabel.Text='GPU Code Generation Environment Check / Setup';


            app.SelectHardwareDropDownLabel=uilabel(app.GPUEnvironmentCheckUIFigure);
            app.SelectHardwareDropDownLabel.HorizontalAlignment='right';
            app.SelectHardwareDropDownLabel.Position=[156,577,114,22];
            app.SelectHardwareDropDownLabel.Text='Select Hardware';


            app.SelectHardwareDropDown=uidropdown(app.GPUEnvironmentCheckUIFigure);
            app.SelectHardwareDropDown.Items={'Host (for MEX)','Drive','Jetson'};
            app.SelectHardwareDropDown.ValueChangedFcn=createCallbackFcn(app,@SelectHardwareDropDownValueChanged,true);
            app.SelectHardwareDropDown.Position=[284,576,123,24];
            app.SelectHardwareDropDown.Value='Host (for MEX)';


            app.SelectGPUDropDownLabel=uilabel(app.GPUEnvironmentCheckUIFigure);
            app.SelectGPUDropDownLabel.HorizontalAlignment='right';
            app.SelectGPUDropDownLabel.Visible='off';
            app.SelectGPUDropDownLabel.Position=[156,542,114,22];
            app.SelectGPUDropDownLabel.Text='Select GPU';


            app.SelectGPUDropDown=uidropdown(app.GPUEnvironmentCheckUIFigure);
            app.SelectGPUDropDown.Items={};
            app.SelectGPUDropDown.ValueChangedFcn=createCallbackFcn(app,@SelectGPUDropDownValueChanged,true);
            app.SelectGPUDropDown.Visible='off';
            app.SelectGPUDropDown.Position=[284,541,123,24];
            app.SelectGPUDropDown.Value={};


            app.EnvironmentChecksPanel=uipanel(app.GPUEnvironmentCheckUIFigure);
            app.EnvironmentChecksPanel.AutoResizeChildren='off';
            app.EnvironmentChecksPanel.ForegroundColor=[0,0.451,0.7412];
            app.EnvironmentChecksPanel.Title='Environment Checks';
            app.EnvironmentChecksPanel.BackgroundColor=[0.9412,0.9412,0.9412];
            app.EnvironmentChecksPanel.FontWeight='bold';
            app.EnvironmentChecksPanel.FontSize=14;
            app.EnvironmentChecksPanel.Position=[14,78,567,201];


            app.CUDAInstallationPathEditFieldLabel=uilabel(app.EnvironmentChecksPanel);
            app.CUDAInstallationPathEditFieldLabel.HorizontalAlignment='right';
            app.CUDAInstallationPathEditFieldLabel.Enable='off';
            app.CUDAInstallationPathEditFieldLabel.Position=[22,141,141,22];
            app.CUDAInstallationPathEditFieldLabel.Text='CUDA Installation Path';


            app.CUDAInstallationPathEditField=uieditfield(app.EnvironmentChecksPanel,'text');
            app.CUDAInstallationPathEditField.ValueChangedFcn=createCallbackFcn(app,@CUDAInstallationPathEditFieldValueChanged,true);
            app.CUDAInstallationPathEditField.ValueChangingFcn=createCallbackFcn(app,@CUDAInstallationPathEditFieldValueChanging,true);
            app.CUDAInstallationPathEditField.Editable='off';
            app.CUDAInstallationPathEditField.FontSize=10;
            app.CUDAInstallationPathEditField.Enable='off';
            app.CUDAInstallationPathEditField.Position=[175,141,300,22];


            app.cuDNNEditFieldLabel=uilabel(app.EnvironmentChecksPanel);
            app.cuDNNEditFieldLabel.HorizontalAlignment='right';
            app.cuDNNEditFieldLabel.Enable='off';
            app.cuDNNEditFieldLabel.Position=[22,99,140,22];
            app.cuDNNEditFieldLabel.Text='cuDNN';


            app.cuDNNEditField=uieditfield(app.EnvironmentChecksPanel,'text');
            app.cuDNNEditField.ValueChangedFcn=createCallbackFcn(app,@cuDNNEditFieldValueChanged,true);
            app.cuDNNEditField.ValueChangingFcn=createCallbackFcn(app,@cuDNNEditFieldValueChanging,true);
            app.cuDNNEditField.FontSize=10;
            app.cuDNNEditField.Enable='off';
            app.cuDNNEditField.Position=[175,99,300,22];


            app.TensorRTEditFieldLabel=uilabel(app.EnvironmentChecksPanel);
            app.TensorRTEditFieldLabel.HorizontalAlignment='right';
            app.TensorRTEditFieldLabel.Enable='off';
            app.TensorRTEditFieldLabel.Position=[22,58,140,22];
            app.TensorRTEditFieldLabel.Text='TensorRT';


            app.TensorRTEditField=uieditfield(app.EnvironmentChecksPanel,'text');
            app.TensorRTEditField.ValueChangedFcn=createCallbackFcn(app,@TensorRTEditFieldValueChanged,true);
            app.TensorRTEditField.ValueChangingFcn=createCallbackFcn(app,@TensorRTEditFieldValueChanging,true);
            app.TensorRTEditField.FontSize=10;
            app.TensorRTEditField.Enable='off';
            app.TensorRTEditField.Position=[175,58,300,22];


            app.CUDAbrowse_button=uibutton(app.EnvironmentChecksPanel,'push');
            app.CUDAbrowse_button.ButtonPushedFcn=createCallbackFcn(app,@CUDAbrowse_buttonButtonPushed,true);
            app.CUDAbrowse_button.BusyAction='cancel';
            app.CUDAbrowse_button.Interruptible='off';
            app.CUDAbrowse_button.Icon='Gpu_Browse_24.png';
            app.CUDAbrowse_button.Enable='off';
            app.CUDAbrowse_button.Tooltip='Browse CUDA installation path';
            app.CUDAbrowse_button.Position=[492,140,20,22];
            app.CUDAbrowse_button.Text='';


            app.cuDNNbrowse_button=uibutton(app.EnvironmentChecksPanel,'push');
            app.cuDNNbrowse_button.ButtonPushedFcn=createCallbackFcn(app,@cuDNNbrowse_buttonButtonPushed,true);
            app.cuDNNbrowse_button.BusyAction='cancel';
            app.cuDNNbrowse_button.Interruptible='off';
            app.cuDNNbrowse_button.Icon='Gpu_Browse_24.png';
            app.cuDNNbrowse_button.Enable='off';
            app.cuDNNbrowse_button.Tooltip='Browse cuDNN installation path';
            app.cuDNNbrowse_button.Position=[492,98,20,22];
            app.cuDNNbrowse_button.Text='';


            app.TensorRTbrowse_button=uibutton(app.EnvironmentChecksPanel,'push');
            app.TensorRTbrowse_button.ButtonPushedFcn=createCallbackFcn(app,@TensorRTbrowse_buttonButtonPushed,true);
            app.TensorRTbrowse_button.BusyAction='cancel';
            app.TensorRTbrowse_button.Interruptible='off';
            app.TensorRTbrowse_button.Icon='Gpu_Browse_24.png';
            app.TensorRTbrowse_button.Enable='off';
            app.TensorRTbrowse_button.Tooltip='Browse TensorRT installation path';
            app.TensorRTbrowse_button.Position=[492,57,20,22];
            app.TensorRTbrowse_button.Text='';


            app.NVTXbrowse_button=uibutton(app.EnvironmentChecksPanel,'push');
            app.NVTXbrowse_button.ButtonPushedFcn=createCallbackFcn(app,@NVTXbrowse_buttonButtonPushed,true);
            app.NVTXbrowse_button.BusyAction='cancel';
            app.NVTXbrowse_button.Interruptible='off';
            app.NVTXbrowse_button.Icon='Gpu_Browse_24.png';
            app.NVTXbrowse_button.Enable='off';
            app.NVTXbrowse_button.Tooltip={'Browse NVTX library path'};
            app.NVTXbrowse_button.Position=[492,17,20,22];
            app.NVTXbrowse_button.Text='';


            app.NVTXLibraryPathLabel=uilabel(app.EnvironmentChecksPanel);
            app.NVTXLibraryPathLabel.HorizontalAlignment='right';
            app.NVTXLibraryPathLabel.Enable='off';
            app.NVTXLibraryPathLabel.Position=[22,17,140,22];
            app.NVTXLibraryPathLabel.Text='NVTX Library Path';


            app.NVTXLibraryPathEditField=uieditfield(app.EnvironmentChecksPanel,'text');
            app.NVTXLibraryPathEditField.ValueChangedFcn=createCallbackFcn(app,@NVTXLibraryPathEditFieldValueChanged,true);
            app.NVTXLibraryPathEditField.ValueChangingFcn=createCallbackFcn(app,@NVTXLibraryPathEditFieldValueChanging,true);
            app.NVTXLibraryPathEditField.FontSize=10;
            app.NVTXLibraryPathEditField.Enable='off';
            app.NVTXLibraryPathEditField.Position=[175,17,300,22];


            app.WorkflowChecksPanel=uipanel(app.GPUEnvironmentCheckUIFigure);
            app.WorkflowChecksPanel.AutoResizeChildren='off';
            app.WorkflowChecksPanel.ForegroundColor=[0,0.451,0.7412];
            app.WorkflowChecksPanel.Title='Workflow Checks';
            app.WorkflowChecksPanel.FontWeight='bold';
            app.WorkflowChecksPanel.FontSize=14;
            app.WorkflowChecksPanel.Position=[14,302,567,201];


            app.BasicCodeGenerationPanel=uipanel(app.WorkflowChecksPanel);
            app.BasicCodeGenerationPanel.AutoResizeChildren='off';
            app.BasicCodeGenerationPanel.Title='        Basic Code Generation';
            app.BasicCodeGenerationPanel.Position=[19,17,253,147];


            app.BasicCodeGenerationWorkflow=uibuttongroup(app.BasicCodeGenerationPanel);
            app.BasicCodeGenerationWorkflow.AutoResizeChildren='off';
            app.BasicCodeGenerationWorkflow.BorderType='none';
            app.BasicCodeGenerationWorkflow.Position=[3,67,170,47];


            app.GenerateCodeBasicButton=uiradiobutton(app.BasicCodeGenerationWorkflow);
            app.GenerateCodeBasicButton.Enable='off';
            app.GenerateCodeBasicButton.Text='Generate Code';
            app.GenerateCodeBasicButton.Position=[14,29,106,22];
            app.GenerateCodeBasicButton.Value=true;


            app.GenerateandExecuteBasicButton=uiradiobutton(app.BasicCodeGenerationWorkflow);
            app.GenerateandExecuteBasicButton.Enable='off';
            app.GenerateandExecuteBasicButton.Text='Generate and Execute';
            app.GenerateandExecuteBasicButton.Position=[14,7,144,22];


            app.SILProfilingCheckBox=uicheckbox(app.BasicCodeGenerationPanel);
            app.SILProfilingCheckBox.ValueChangedFcn=createCallbackFcn(app,@SILProfilingCheckBoxValueChanged,true);
            app.SILProfilingCheckBox.Enable='off';
            app.SILProfilingCheckBox.Text='SIL Profiling';
            app.SILProfilingCheckBox.Position=[11,46,150,22];


            app.DeepLearningCodeGenerationPanel=uipanel(app.WorkflowChecksPanel);
            app.DeepLearningCodeGenerationPanel.AutoResizeChildren='off';
            app.DeepLearningCodeGenerationPanel.Title='        Deep Learning Code Generation';
            app.DeepLearningCodeGenerationPanel.Position=[296,16,253,148];


            app.TargetLabel=uilabel(app.DeepLearningCodeGenerationPanel);
            app.TargetLabel.Enable='off';
            app.TargetLabel.Position=[18,47,80,22];
            app.TargetLabel.Text='Target';


            app.DeepLearning_Target_DropDown=uidropdown(app.DeepLearningCodeGenerationPanel);
            app.DeepLearning_Target_DropDown.Items={'cuDNN','TensorRT'};
            app.DeepLearning_Target_DropDown.ValueChangedFcn=createCallbackFcn(app,@DeepLearning_Target_DropDownValueChanged,true);
            app.DeepLearning_Target_DropDown.Enable='off';
            app.DeepLearning_Target_DropDown.BackgroundColor=[1,1,1];
            app.DeepLearning_Target_DropDown.Position=[119,49,108,19];
            app.DeepLearning_Target_DropDown.Value='cuDNN';


            app.DataTypeLabel=uilabel(app.DeepLearningCodeGenerationPanel);
            app.DataTypeLabel.Enable='off';
            app.DataTypeLabel.Position=[18,22,80,22];
            app.DataTypeLabel.Text='Data Type';


            app.CheckLabel=uilabel(app.DeepLearningCodeGenerationPanel);
            app.CheckLabel.Enable='off';
            app.CheckLabel.Position=[18,5,80,22];
            app.CheckLabel.Text='Check';


            app.DeepLearning_Target_DropDown_2=uidropdown(app.DeepLearningCodeGenerationPanel);
            app.DeepLearning_Target_DropDown_2.Items={'FP32','FP16','INT8'};
            app.DeepLearning_Target_DropDown_2.Enable='off';
            app.DeepLearning_Target_DropDown_2.BackgroundColor=[1,1,1];
            app.DeepLearning_Target_DropDown_2.Position=[119,16,108,19];
            app.DeepLearning_Target_DropDown_2.Value='FP32';


            app.DeepLearningWorkflow=uibuttongroup(app.DeepLearningCodeGenerationPanel);
            app.DeepLearningWorkflow.AutoResizeChildren='off';
            app.DeepLearningWorkflow.BorderType='none';
            app.DeepLearningWorkflow.Position=[13,74,169,47];


            app.GenerateCodeDeepButton=uiradiobutton(app.DeepLearningWorkflow);
            app.GenerateCodeDeepButton.Enable='off';
            app.GenerateCodeDeepButton.Text='Generate Code';
            app.GenerateCodeDeepButton.Position=[3,22,106,22];
            app.GenerateCodeDeepButton.Value=true;


            app.GenerateandExecuteDeepButton=uiradiobutton(app.DeepLearningWorkflow);
            app.GenerateandExecuteDeepButton.Enable='off';
            app.GenerateandExecuteDeepButton.Text='Generate and Execute';
            app.GenerateandExecuteDeepButton.Position=[3,0,144,22];


            app.BasicCodeGen_CheckBox=uicheckbox(app.WorkflowChecksPanel);
            app.BasicCodeGen_CheckBox.ValueChangedFcn=createCallbackFcn(app,@BasicCodeGen_CheckBoxValueChanged,true);
            app.BasicCodeGen_CheckBox.Text='';
            app.BasicCodeGen_CheckBox.Position=[24,143,18,22];


            app.DeepLearning_CheckBox=uicheckbox(app.WorkflowChecksPanel);
            app.DeepLearning_CheckBox.ValueChangedFcn=createCallbackFcn(app,@DeepLearning_CheckBoxValueChanged,true);
            app.DeepLearning_CheckBox.Text='';
            app.DeepLearning_CheckBox.Position=[301,143,25,22];


            app.Button=uibutton(app.GPUEnvironmentCheckUIFigure,'push');
            app.Button.ButtonPushedFcn=createCallbackFcn(app,@ButtonPushed,true);
            app.Button.BusyAction='cancel';
            app.Button.Icon='Gpu_Help_24.png';
            app.Button.Tooltip={'GPU Coder documentation'};
            app.Button.Position=[556,639,30,24];
            app.Button.Text='';


            app.RunChecksButton=uibutton(app.GPUEnvironmentCheckUIFigure,'push');
            app.RunChecksButton.ButtonPushedFcn=createCallbackFcn(app,@RunChecksButtonPushed,true);
            app.RunChecksButton.BusyAction='cancel';
            app.RunChecksButton.Interruptible='off';
            app.RunChecksButton.Icon='Gpu_Publish_24.png';
            app.RunChecksButton.Tooltip='Run selected checks';
            app.RunChecksButton.Position=[114,22,120,28];
            app.RunChecksButton.Text='Run Checks';


            app.GpuErrorMsg=uilabel(app.GPUEnvironmentCheckUIFigure);
            app.GpuErrorMsg.VerticalAlignment='top';
            app.GpuErrorMsg.FontAngle='italic';
            app.GpuErrorMsg.FontColor=[1,0,0];
            app.GpuErrorMsg.Position=[18,521,559,44];
            app.GpuErrorMsg.Text='A compatible GPU device is not found on the host system. Execution and profiling of the generated';


            app.ExportSettingsButton=uibutton(app.GPUEnvironmentCheckUIFigure,'push');
            app.ExportSettingsButton.ButtonPushedFcn=createCallbackFcn(app,@ExportSettingsButtonPushed,true);
            app.ExportSettingsButton.BusyAction='cancel';
            app.ExportSettingsButton.Interruptible='off';
            app.ExportSettingsButton.Icon='Gpu_Save_24.png';
            app.ExportSettingsButton.Tooltip={'Export current settings as MATLAB script'};
            app.ExportSettingsButton.Position=[336.5,20,125,30];
            app.ExportSettingsButton.Text='Export Settings';


            app.BoardSettingsPanel=uipanel(app.GPUEnvironmentCheckUIFigure);
            app.BoardSettingsPanel.ForegroundColor=[0,0.451,0.7412];
            app.BoardSettingsPanel.Title='Board Settings';
            app.BoardSettingsPanel.FontWeight='bold';
            app.BoardSettingsPanel.FontSize=14;
            app.BoardSettingsPanel.Position=[14,302,567,201];


            app.DeviceAddressEditFieldLabel=uilabel(app.BoardSettingsPanel);
            app.DeviceAddressEditFieldLabel.HorizontalAlignment='right';
            app.DeviceAddressEditFieldLabel.Position=[10,131,110,22];
            app.DeviceAddressEditFieldLabel.Text='Device Address';


            app.DeviceAddressEditField=uieditfield(app.BoardSettingsPanel,'text');
            app.DeviceAddressEditField.Tooltip={'Board address'};
            app.DeviceAddressEditField.Position=[130,131,140,22];


            app.UsernameEditFieldLabel=uilabel(app.BoardSettingsPanel);
            app.UsernameEditFieldLabel.HorizontalAlignment='right';
            app.UsernameEditFieldLabel.Position=[298,131,76,22];
            app.UsernameEditFieldLabel.Text='Username';


            app.UsernameEditField=uieditfield(app.BoardSettingsPanel,'text');
            app.UsernameEditField.Tooltip={'Username to access board'};
            app.UsernameEditField.Position=[388,131,140,22];


            app.PasswordEditFieldLabel=uilabel(app.BoardSettingsPanel);
            app.PasswordEditFieldLabel.HorizontalAlignment='right';
            app.PasswordEditFieldLabel.Position=[298,93,76,22];
            app.PasswordEditFieldLabel.Text='Password';


            app.PasswordEditField=uieditfield(app.BoardSettingsPanel,'text');
            app.PasswordEditField.Tooltip={'Password to access board'};
            app.PasswordEditField.Position=[388,93,140,22];


            app.GPUDeviceIdEditFieldLabel=uilabel(app.BoardSettingsPanel);
            app.GPUDeviceIdEditFieldLabel.HorizontalAlignment='right';
            app.GPUDeviceIdEditFieldLabel.Position=[10,94,110,22];
            app.GPUDeviceIdEditFieldLabel.Text='GPU Device Id';


            app.GPUDeviceIdEditField=uieditfield(app.BoardSettingsPanel,'text');
            app.GPUDeviceIdEditField.Tooltip={'Index of GPU device on Drive board'};
            app.GPUDeviceIdEditField.Position=[130,94,140,22];


            app.ClearButton=uibutton(app.BoardSettingsPanel,'push');
            app.ClearButton.ButtonPushedFcn=createCallbackFcn(app,@ClearButtonPushed,true);
            app.ClearButton.BusyAction='cancel';
            app.ClearButton.Icon='Gpu_Delete_24.png';
            app.ClearButton.Tooltip={'Clear board settings'};
            app.ClearButton.Position=[311,10,100,28];
            app.ClearButton.Text='Clear';


            app.ConnectButton=uibutton(app.BoardSettingsPanel,'push');
            app.ConnectButton.ButtonPushedFcn=createCallbackFcn(app,@ConnectButtonPushed,true);
            app.ConnectButton.BusyAction='cancel';
            app.ConnectButton.Interruptible='off';
            app.ConnectButton.Icon='Gpu_Continue_24.png';
            app.ConnectButton.Tooltip={'Connect to board'};
            app.ConnectButton.Position=[138,10,100,28];
            app.ConnectButton.Text='Connect';


            app.ExecutionTimeoutEditFieldLabel=uilabel(app.BoardSettingsPanel);
            app.ExecutionTimeoutEditFieldLabel.HorizontalAlignment='right';
            app.ExecutionTimeoutEditFieldLabel.Position=[9,56,106,22];
            app.ExecutionTimeoutEditFieldLabel.Text='Execution Timeout';


            app.ExecutionTimeoutEditField=uieditfield(app.BoardSettingsPanel,'text');
            app.ExecutionTimeoutEditField.Tooltip={'Maximum time in seconds to wait until code execution completes'};
            app.ExecutionTimeoutEditField.Position=[130,56,140,22];
            app.ExecutionTimeoutEditField.Value='10';


            app.GPUEnvironmentCheckUIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=gpucoderSetupImpl

            coder.internal.ddux.logger.logCoderEventData("checkGpuInstallApp");


            createComponents(app)


            registerApp(app,app.GPUEnvironmentCheckUIFigure)


            runStartupFcn(app,@startupFcn)

            if nargout==0
                clear app
            end
        end


        function delete(app)


            delete(app.GPUEnvironmentCheckUIFigure)
        end
    end
end
