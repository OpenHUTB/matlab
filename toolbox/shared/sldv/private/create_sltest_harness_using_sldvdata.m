function rootOutportNames = create_sltest_harness_using_sldvdata(sldvData, model, component, harnessName, ...
    src, extractedMdlLoc, varargin)

%

%   Copyright 2015-2022 The MathWorks, Inc.

% create a Simulink Test Harness
closeExtractedMdl = false;
if ~isempty(extractedMdlLoc)
    curDir = pwd;
    [dir, name, ~] = fileparts(extractedMdlLoc);
    if ~is_model_open(name)
        cd(dir);
        load_system(name);
        closeExtractedMdl = true;
    end
    srcModelH = get_param(name, 'Handle');
    cd(curDir);
else
    % if analyzing a test harness, we must reuse the test harness.
    % Here, we assert that create_sltest_harness will never be called if
    % a test harness is analyzed.
    if ~isempty(sldvData) && isfield(sldvData, 'ModelInformation')
        assert(~isfield(sldvData.ModelInformation, 'HarnessOwnerModel'), 'Cannot create a test harness for a test harness');
    end
    srcModelH = get_param(model, 'Handle');
end

harnessPath = ''; 
modelRefHarness = false;
if nargin > 6
    harnessPath = varargin{1}; 
    modelRefHarness = varargin{2};
end

isSignalBuilderSrc = strcmp(src, 'Signal Builder');
isSigBuilderOrSigEditorSrc = any(strcmp(src, {'Signal Builder','Signal Editor'}));
isSLDVCompat = false;   % Default value
if isempty(harnessPath)
    isSLDVCompat = true;
end

% Define the scheduler block to be used
schedulerBlk = 'None';
if ~strcmp(model, component)
    % Note: We do not check for the top model to be a Export Function model
    % because that should not be a case here since we create the harness
    % for the generated scheduler in case of export function models. It is
    % only in case of subsystem extraction where the harness is created for
    % the component itself.
    isMdlRef = strcmp(get_param(component,'BlockType'), 'ModelReference');
    if (~isMdlRef && strcmp(get_param(component, 'IsSimulinkFunction'), 'on')) || ...
        (isMdlRef && strcmpi(get_param(component, 'IsModelRefExportFunction'), 'on'))
        schedulerBlk = 'Matlab Function';
    end
end

if isSLDVCompat && ~strcmp(model, component) && isSigBuilderOrSigEditorSrc
    % Check if stubbed Simulink Functions were added while analyzing the
    % component. We support only Inport harness for such components.
    if isfield(sldvData.AnalysisInformation,'StubbedSimulinkFcnInfo') && ...
            ~isempty(sldvData.AnalysisInformation.StubbedSimulinkFcnInfo)
        % Report error for the component (g2745513)
        errID = 'Sldv:Compatibility:UnsupportedHarnessSourceForSLFunctionStub';
        reportError(component, errID);
    end
end

usedSignals = {};
if isSigBuilderOrSigEditorSrc
    usedSignals = Simulink.harness.internal.populateUsedSignals(sldvData.AnalysisInformation.InputPortInfo, usedSignals);
    usedSignals = usedSignals{:};
end

% Create a Stage to display all the messages
harnessCreateStage = Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:CreateHarnessStage'), ...
    'ModelName', model, ...
    'UIMode', Simulink.harness.internal.CreateFromDialogFlag()); %#ok

checkoutSLTLicense = (slsvTestingHook('UnifiedHarnessBackendMode') == 0); 

if isempty(harnessPath)
    Simulink.harness.internal.create(component, ...
         false, ... % createForLoad
         checkoutSLTLicense, ... % checkoutLicense
        'Source', src, ...
        'Name', harnessName, ...
        'AutoShapeInputs', isSignalBuilderSrc, ...
        'DriveFcnCallWithTestSequence', false, ...
        'SchedulerBlock', schedulerBlk, ...
        'UsedSignalsCell', usedSignals, ...
        'RebuildOnOpen', false,...
        'SLDVCompatible', isSLDVCompat);
else
    Simulink.harness.internal.create(component, ...
         false, ... % createForLoad
         checkoutSLTLicense, ... % checkoutLicense
        'Source', src, ...
        'Name', harnessName, ...
        'AutoShapeInputs', isSignalBuilderSrc, ...
        'DriveFcnCallWithTestSequence', false, ...
        'SchedulerBlock', schedulerBlk, ...
        'UsedSignalsCell', usedSignals, ...
        'HarnessPath', harnessPath, ...
        'RebuildOnOpen', false);
end

fundts = getTimeStep(sldvData.AnalysisInformation.SampleTimes);
Simulink.harness.internal.load(component, harnessName, checkoutSLTLicense);

if isSignalBuilderSrc || strcmp(src, 'Signal Editor')    
    [harnessSource, errorMsg] = Sldv.harnesssource.Source.getSource(harnessName);
    if ~isempty(harnessSource) && isempty(errorMsg)        
        open_system(harnessName);
        % Add Signal Editor scenarios or Signal Builder groups for the
        % harness source
        stopTime = createSourceBlockSignals(harnessSource.blockH, ...
            harnessName, sldvData, fundts, isSignalBuilderSrc, false); 
    else
        stopTime = 0;
    end
else
    if isfield(sldvData, 'TestCases')
        stopTime = computeSimStoptime(sldvData.TestCases) + fundts;
    else
        stopTime = computeSimStoptime(sldvData.CounterExamples) + fundts;
    end
end

% clear Continuous Sample Time Setting
Simulink.harness.internal.clearContTsSetting(get_param(model, 'Handle'), harnessName, get_param(component, 'Handle'));

% clear interpolation setting
inportBlocks = find_system(harnessName, 'SearchDepth', 1, 'BlockType', 'Inport');
n = length(inportBlocks);
for i=1:n
    set_param(inportBlocks{i}, 'Interpolate', 'off');
end

needsRelock = false;
if strcmp(get_param(model, 'Lock'), 'on')
    Simulink.harness.internal.setBDLock(model, false);
    needsRelock = true;
end

harnessH = get_param(harnessName, 'Handle');

Sldv.utils.configHarnessForSLDV(srcModelH, harnessH, sldvData.AnalysisInformation.Options);

if isSLDVCompat
    % Configure coverage of blocks that get inserted while generating SLDV
    % compatible harness
    sldvshareprivate('configSLDVCompatibleHarness', srcModelH, harnessH);
end

% for BD harness turn on coverage for model blocks
if strcmp(component, model)
    set_param(harnessH, 'covModelRefEnable', 'on');

    if Sldv.DataUtils.isXilSldvData(sldvData)
        % Set the corresponding simulation mode and code interface
        % for SIL-based test generation only if it's not the export
        % function model wrapper (in such case the wrapper model
        % contains a model reference already configured)
        if ~Sldv.DataUtils.isBDExtractedModel(sldvData)
            % Find the created model reference block
            mBlkH = find_system(get_param(harnessName, 'Handle'),...
                'SearchDepth', 1,...
                'BlockType', 'ModelReference',...
                'ModelName', component);

            if ~isempty(mBlkH)
                % Set the corresponding simulation mode and code interface
                % for SIL-based test generation
                if Sldv.utils.Options.isTestgenTargetForCode(sldvData.AnalysisInformation.Options)
                    codeIf = 'Top model';
                else
                    codeIf = 'Model reference';
                end
                simMode = SlCov.CovMode.toSimulationMode('SIL');
                set_param(mBlkH,...
                    'SimulationMode', simMode, ...
                    'CodeInterface', codeIf);
            end
        end
    end
end
srcHasRootLvlBEP = sldvshareprivate('mdl_check_rootlvl_buselemport',srcModelH);
Sldv.utils.configureInportExportFormatOnHarnessModel(srcModelH, harnessH, srcHasRootLvlBEP);

fromMdlFlag = false;
% We don't update the SampleTimeConstraint of SIL ATS from 
% Sample Time Independent to Unconstrained.
if strcmp(sldvData.AnalysisInformation.Options.TestgenTarget,'Model') || ...
        ~isfield(sldvData.ModelInformation, 'SubsystemPath')
    Sldv.utils.setSharedAttributesWithSldvruntest(harnessH, fromMdlFlag, modelRefHarness, fundts);
end

set_param(harnessH, 'StopTime', util_double2str(stopTime));
% Model may have nonzero StartTime. DV generates test vectors starting
% from zero. Set the StarTime to zero for all cases.
set_param(harnessH, 'StartTime', '0');

if strcmpi(sldvData.AnalysisInformation.Options.DetectDSMAccessViolations, 'on')
    set_param(harnessH, 'ReadBeforeWriteMsg', 'EnableAllAsWarning');
    set_param(harnessH, 'WriteAfterWriteMsg', 'EnableAllAsWarning');
    set_param(harnessH, 'WriteAfterReadMsg',  'EnableAllAsWarning');
end

if slsvTestingHook('UnifiedHarnessBackendMode') == 0 
    Simulink.harness.internal.clearModelCallbacks(harnessH);
end

if needsRelock
    Simulink.harness.internal.setBDLock(model, true);
end

%
if isfield(sldvData, 'TestCases')
    if isfield(sldvData.TestCases, 'expectedOutput')
        rootOutportNames = get_param(find_system(harnessH, 'SearchDepth', 1, 'BlockType', 'Outport'), 'Name');
    else
        rootOutportNames = {};
    end
else
    if isfield(sldvData.CounterExamples, 'expectedOutput')
        rootOutportNames = get_param(find_system(harnessH, 'SearchDepth', 1, 'BlockType', 'Outport'), 'Name');
    else
        rootOutportNames = {};
    end
end

set_param(harnessH, 'SaveFormat', 'DataSet');
            
if Simulink.harness.internal.isSavedIndependently(model)
    save_system(harnessName);
end
close_system(harnessName);

% close extracted model
if closeExtractedMdl
    curDir = pwd;
    [dir, name, ~] = fileparts(extractedMdlLoc);
    cd(dir);
    close_system(name);
    cd(curDir);
end
end

function out = is_model_open(mdlName)
try
    mdlH = get_param(mdlName, 'Handle');         %#ok<NASGU>
    out = true;
catch Mex                                       %#ok<NASGU>
    out = false;
end
end

function ts = getTimeStep(sampleTimes)
for i = 1:length(sampleTimes)
    ts = sampleTimes(i);
    if ts ~= 0
        break;
    end
end
end

function stopTime = computeSimStoptime(dvTestCases)
tc = length(dvTestCases);
stopTime = 0;
for g = 1:tc
    stopTime = max(stopTime, dvTestCases(g).timeValues(end));
end
end

function reportError(component, errID)
    errMsg = getString(message(errID, component));
    mEx = MException(errID, errMsg);
    throw(mEx);
end

% LocalWords:  slfunction defs

