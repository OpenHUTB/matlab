function [modelInfo, resourceInfo, timingInfo] = getSSC2HDLSynthesisResults (modelName, synthesisToolParams)
%
% getSSC2HDLSynthesisResults : This function takes simscape model name
% and runs through HDL code generation and synthesis.
%
%
% modelName = 'sschdlexBuckConverterExample.slx';
%
% synthesisToolParams.SynthesisTool = 'Xilinx Vivado';
% synthesisToolParams.SynthesisToolChipFamily = 'Kintex7';
% synthesisToolParams.SynthesisToolDeviceName = 'xc7k325t';
% synthesisToolParams.SynthesisToolPackageName = 'fbg676';
% synthesisToolParams.SynthesisToolSpeedValue  = '-1';
% synthesisToolParams.TargetFrequency = 100;
% hdlsscRunHDLCodegenAndSynthesis(<modelName>, synthesisToolParams)
%
% Make sure to have synthesis tool is on the path. See >> help
% hdlsetuptoolpath

% Copyright 2021 The MathWorks, Inc.

bdclose all

if nargin < 2
    disp('missing synthesisTool and TargetParams specification');
    help hdlsscRunHDLCodegenAndSynthesis;
    return;
    % synthesisToolParams.SynthesisTool = '<name-of-tool>';
    % synthesisToolParams.SynthesisToolChipFamily = '<chip-family>';
    % synthesisToolParams.SynthesisToolDeviceName = '<device-name>';
    % synthesisToolParams.SynthesisToolPackageName = '<package-name>';
    % synthesisToolParams.SynthesisToolSpeedValue  = '<speed-value>';
    % synthesisToolParams.TargetFrequency = <target-frequency>;
    % hdlsscRunHDLCodegenAndSynthesis(<modelName>, synthesisToolParams)
    %
end

% Load the Model
load_system(modelName);
sscCodeGenWorkflowObj = ssccodegenworkflow.SwitchedLinearWorkflow(gcs);
% Run sschdladvisor
runWorkflow(sscCodeGenWorkflowObj)
info = sscCodeGenWorkflowObj.StateSpaceParametersDeamon;
for i = 1:numel(info)
    
    sz(1)= 11;
    sz(2)= 2;
    
    % create a table to capture model details like stacte space paramter
    % sizes, number of inputs, number of outputs, number of modes and
    % number of states
    modelInfo = table('Size',sz,'VariableTypes',["string","string"],'VariableNames',{'Parameter','Size'},'RowNames',{'Row1','Row2','Row3','Row4','Row5','Row6','Row7','Row8','Row9','Row10','Row11'});
    
    modelInfo(1,:) = {"A",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad, 3))]}};
    modelInfo(2,:) = {"B",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd, 3))]}};
    modelInfo(3,:) = {"C",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd, 3))]}};
    modelInfo(4,:) = {"D",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd, 3))]}};
    modelInfo(5,:) = {"Y0d",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d, 3))]}};
    modelInfo(6,:) = {"F0d",{[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d, 1)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d, 2)) ...
        ' x ' num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d, 3))]}};
    modelInfo(7,:)  = {'Number of states',num2str(size(info(i).data(1).A,1))};
    modelInfo(8,:) = {'Number of inputs',num2str(size(info(i).data(1).B,2))};
    modelInfo(9,:) = {'Number of outputs',num2str(size(info(i).data(1).C,1))};
    modelInfo(10,:) = {'Number of modes',num2str(numel(info(i).data))}; % number of switching modes
    modelInfo(11,:) = {'Number of differential variables', num2str(sscCodeGenWorkflowObj.NumberOfDifferentialVariables(i))};
    
end
% Get HDL subsystem of the implementation model
HDLmodel = sscCodeGenWorkflowObj.HDLModel;
pathOfHDLSubSystem =  hdlget_param(HDLmodel,'HDLSubsystem');
HDLSSpaths = getfullname( pathOfHDLSubSystem ) ;

% Set Implementation Model HDL parameters
hdlset_param(HDLmodel, 'FPToleranceValue', 1.000000e-03);
hdlset_param(HDLmodel, 'FloatingPointTargetConfiguration', hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint', 'LatencyStrategy', 'MIN'));
hdlset_param(HDLmodel, 'MaskParameterAsGeneric', 'on');
hdlset_param(HDLmodel, 'SynthesisTool', synthesisToolParams.SynthesisTool);
hdlset_param(HDLmodel, 'SynthesisToolChipFamily', synthesisToolParams.SynthesisToolChipFamily );
hdlset_param(HDLmodel, 'SynthesisToolDeviceName', synthesisToolParams.SynthesisToolDeviceName);
hdlset_param(HDLmodel, 'SynthesisToolPackageName', synthesisToolParams.SynthesisToolPackageName);
hdlset_param(HDLmodel, 'SynthesisToolSpeedValue', synthesisToolParams.SynthesisToolSpeedValue );
hdlset_param(HDLmodel, 'TargetDirectory', 'hdl_prj\hdlsrc');
hdlset_param(HDLmodel, 'TargetFrequency',  synthesisToolParams.TargetFrequency);


% Workflow Configuration Settings Construct the Workflow Configuration
% Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','Generic ASIC/FPGA');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndTestbench = true;
hWC.RunTaskVerifyWithHDLCosimulation = false;
hWC.RunTaskCreateProject = true;
hWC.RunTaskRunSynthesis = true;
hWC.RunTaskRunImplementation = false;
hWC.RunTaskAnnotateModelWithSynthesisResult = true;

% Set properties related to 'RunTaskGenerateRTLCodeAndTestbench' Task
hWC.GenerateRTLCode = true;
hWC.GenerateTestbench = false;
hWC.GenerateValidationModel = false;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';

% Set properties related to 'RunTaskRunSynthesis' Task
hWC.SkipPreRouteTimingAnalysis = false;

% Set properties related to 'RunTaskRunImplementation' Task
hWC.IgnorePlaceAndRouteErrors = false;

% Set properties related to 'RunTaskAnnotateModelWithSynthesisResult' Task
hWC.CriticalPathSource = 'pre-route';
hWC.CriticalPathNumber =  1;
hWC.ShowAllPaths = false;
hWC.ShowDelayData = true;
hWC.ShowUniquePaths = false;
hWC.ShowEndsOnly = false;

% Validate the Workflow Configuration Object
hWC.validate;

% Run the HDL workflow
hdlcoder.runWorkflow(HDLSSpaths, hWC);


hDI = downstream.integration('Model', HDLmodel, 'cliDisplay', true,'cmdDisplay',true);

[~, ~, ~, hardwareResults] = hDI.run({'Synthesis', 'PostMapTiming'});
% resource summary
resourceVariables = hardwareResults.ResourceVariables;
usage = hardwareResults.ResourceData;
resourceInfo = table(resourceVariables, usage,  ...
    'VariableNames', {'Resource', 'Usage'});

% timing summary
timingVariables = hardwareResults.TimingVariables;
timingData = hardwareResults.TimingData;
timingInfo = table(timingVariables, timingData, 'VariableNames', {'Timing', 'Value'});

end