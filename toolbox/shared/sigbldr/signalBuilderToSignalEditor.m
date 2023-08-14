function varargout = signalBuilderToSignalEditor( sbBlockH, varargin )
% SIGNALBUILDERTOSIGNALEDITOR imports signal data and properties from
%   Signal Builder block to Signal Editor block. If the dialog for the
%   Signal Builder block is open, it will be closed.
%
%   [SIGEDITBLOCKH, SORTGRPIDX, SORTGRPNAMES] = SIGNALBUILDERTOSIGNALEDITOR( SIGBLDRBLOCKH, 'ADDPARAMNAME', ADDPARAMVALUE )
%   adds a Signal Editor block to the current model using the signal data and
%   properties from the Signal Builder block.
%
%   INPUTS:
%       SIGBLDRBLOCKH: Signal Builder block handle or path.
%
%   Input parameter Name,Value pairs:
%   'FileName':    MAT-file that stores signals.
%                  Default: 'dataset.mat'
%                  Data types: character vector or string
%
%                  Do not use a file name from one locale in a different locale.
%                  When using the block on multiple platforms, consider specifying
%                  just the MAT-file name and having the MAT-file be on the MATLAB
%                  path.
%   'Replace':     Replace Signal Builder block with Signal Editor block.
%                  Default: false
%                  Data type: boolean
%
%                  false - The function uses the Signal Builder block name
%                  for the new Signal Editor block name. The Signal Editor
%                  block name is made unique by adding a numerical suffix.
%                  true - The function names the new Signal Editor block with
%                  the Signal Builder name and deletes the old Signal Builder block.
%
%   OUTPUT:
%       SIGEDITBLOCKH: Signal Editor block handle.
%       SORTGRPIDX:    List of Signal Builder group indices.
%
%                      They are specified as a vector and ordered as they will
%                      appear in Signal Editor block.
%       SORTGRPNAMES:  List of Signal Builder group names.
%
%                      Signal Editor scenario names, specified as a cell array in
%                      alphabetical order.  The names are unique valid MATLAB
%                      variable names generated from the Signal Builder group names.
%
%   Example:
%    Replace existing Signal Builder block with Signal Editor block that
%    uses a MAT-file, 'RoadProfiles.mat', to store the signals.
%
%        model = 'ex_replace_signalbuilder';
%        open_system(model);
%        sbBlockH = [model '/Road Profiles'];
%        seBlockH = signalBuilderToSignalEditor( sbBlockH, 'Replace', true, 'FileName', 'RoadProfiles.mat' );
%

% Copyright 2017-2021 The MathWorks, Inc.

narginchk( 1, 5 );
nargoutchk( 0, 3 );

% convert string to char; otherwise pass through
sbBlockH = convertStringsToChars(sbBlockH);

try
    objH = get_param(sbBlockH,'Handle');

catch invalidBlock
    %This means the block is not in an open/loaded model.
    if(~ischar(sbBlockH))
        error(message('sigbldr_api:signalbuilder:BlockNotOpen',inputname(1),inputname(1)));
    else
        error(message('sigbldr_api:signalbuilder:BlockNotOpen',sbBlockH,sbBlockH));
    end
end
if  ~is_signal_builder_block(sbBlockH)
    error(message('sigbldr_api:signalbuilder:invalidBlock',getfullname(sbBlockH)));
end

if strcmp(get_param(sbBlockH,'IOType'),'siggen')
    %This means the block is a Signal Generator which is not supported.
    %(see g1911151)
    if(~ischar(sbBlockH))
        error(message('sigbldr_api:signalbuilder:SigGenConversionNotSupported',inputname(1)));
    else
        error(message('sigbldr_api:signalbuilder:SigGenConversionNotSupported',sbBlockH));
    end
end

sbBlockH = objH;

modelH = bdroot(sbBlockH);
modelName = get_param(modelH, 'Name');

% check Simulink Design Verifier parameter settings on model InitFcn (g1679079)
initFcn = get_param(modelH, 'InitFcn');
% isSLDVGenHarness = Sldv.HarnessUtils.isSldvGenHarness( modelH ); % no need to search for sigbldr
try
    testHarness = get_param(modelH,'SldvGeneratedHarnessModel');
catch
    testHarness = [];
end

if ~isempty(initFcn) && ~isempty( testHarness )
    warning(message('sigbldr_api:signalbuilder:HasInitFcn', modelName ));
end

% check to see if model can be modified
if localIsSimulating(modelH)
    % Simulating cannot modify model
    error(message('sigbldr_api:signalbuilder:IsSimulating', modelName ));
end

if localIsFastRestart(modelH)
    % In Fast Restart cannot modify model
    error(message('sigbldr_api:signalbuilder:IsFastRestart', modelName ));
end

if localIsLocked(modelH)
    % In locked library cannot be modified
    error(message('sigbldr_api:signalbuilder:IsLocked', modelName ));
end

% Prevent conversion when Signal Builder block outputs a virtual bus
% - This is not supported because a bus object needs to be created for the new Signal Editor block,
%   but there is no current consensus on where that bus object would be stored.
% @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
% instead use the post-compile filter activeVariants() - g2603134
busCreatorH = find_system(sbBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'BusCreator' ); % look only inside active choice of VSS
if ~isempty(busCreatorH)
    error(message('sigbldr_api:signalbuilder:BusOutputNotSupported', getfullname(sbBlockH)));
end

inputStruct = parseInputs( varargin{:} );

FileName = convertStringsToChars(inputStruct.FileName);
Replace = inputStruct.Replace;

% get file parts
[path, name, ext] = fileparts(deblank(inputStruct.FileName));

% check file extension
if isempty(ext)
    % add .mat to filename if not there
    ext = '.mat';
    FileName = fullfile(path,[name ext]);
end

% get Name, Group, Parent and Position
grpIndex = signalbuilder(sbBlockH, 'activegroup');
positionSB = get_param(sbBlockH, 'Position');
blockNameSB = getfullname(sbBlockH);

% get block properties
fontNameSB = get_param(sbBlockH, 'FontName');
fontSizeSB = get_param(sbBlockH, 'FontSize');
fontWeightSB = get_param(sbBlockH, 'FontWeight');
fontAngleSB = get_param(sbBlockH, 'FontAngle');
orientationSB = get_param(sbBlockH, 'Orientation');
fgColorSB = get_param(sbBlockH, 'ForegroundColor');
bgColorSB = get_param(sbBlockH, 'BackgroundColor');
shadowSB = get_param(sbBlockH, 'DropShadow');

% get all signal names
[~, ~, sigNames, ~] = signalbuilder(sbBlockH);

% if the dialog is not open get from From Workspace block (force dialog closed)
sbBlockUD = get_param(sbBlockH, 'UserData');
if ~isempty(sbBlockUD) && ishghandle(sbBlockUD, 'figure')
    figureUD = get(sbBlockUD, 'UserData');
    close_internal(figureUD);
end

% Get all outport properties
loggingProperties = {...
    'DataLogging',...
    'DataLoggingNameMode',...
    'DataLoggingName',...
    'DataLoggingDecimateData',...
    'DataLoggingDecimation',...
    'DataLoggingSampleTime',...
    'DataLoggingLimitDataPoints',...
    'DataLoggingMaxPoints'...
};
outportHandles = get_param(sbBlockH, 'PortHandles').Outport;
outportPropsSB = cell(1, length(outportHandles));
for i=1:length(outportHandles)
    tempProps = struct;
    for j=1:length(loggingProperties)
        tempProps.(loggingProperties{j}) = get_param(outportHandles(i), loggingProperties{j});
    end
    outportPropsSB{i} = tempProps;
end

% Get handle to From Workspace block of Signal Builder
% @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
% instead use the post-compile filter activeVariants() - g2603134
fromWsH = find_system(sbBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'FromWorkspace' ); % look only inside active choice of VSS

% get SampleTime
sampleTimeSB = get_param(fromWsH, 'SampleTime');

% get Interpolate
interpolateSB = get_param(fromWsH, 'Interpolate');

% get ZeroCross
zeroCrossSB = get_param(fromWsH, 'ZeroCross');

% get OutputAfterFinalValue
outputAfterFinalValueSB = get_param(fromWsH, 'OutputAfterFinalValue');

% extract signal data to mat-file, FileName
% get Signal Builder block userdata
UD = get_param(fromWsH, 'SigBuilderData');

% get number of groups
numGroups = length(UD.dataSet);

% Get requirements if Signal Builder block has requirements attached
for nameIdx = numGroups:-1:1
    requirements{nameIdx} = rmi('get', sbBlockH, nameIdx);
    reqEmpty(nameIdx) = isempty(requirements{nameIdx})*nameIdx;
    reqNumel(nameIdx) = numel(requirements{nameIdx});
end

% Make sure existing requirements can be written to Signal Editor block
if ~all(reqEmpty)
    % some requirements exist
    if ~license('test','Simulink_Requirements')
       % no Simulink Requirement license available
       % requirements will not be able to be set on Signal Editor block
       error(message('sigbldr_api:signalbuilder:NoRMILicense', blockNameSB ));
    end
end

% export all groups
groupIdx = 1:numGroups;
% call export to MAT-File
dsNameCell = exportMatFile( FileName, UD, groupIdx, false );

if Replace
    % remove Signal Builder block
    delete_block(sbBlockH);

    % set position with offset for Signal Editor block
    % to avoid connecting incorrect ports before setting data on block
    offsetY = positionSB(4) - positionSB(2) + 10;
    offsetX = positionSB(3) - positionSB(1) + 10;

    % set position for Signal Editor block
    positionSE = positionSB;
    positionSEInit = positionSB + [offsetX offsetY offsetX offsetY];
else
    % set position with offset for Signal Editor block
    % to avoid placing block behind existing Signal Builder
    offset = positionSB(4) - positionSB(2) + 10;
    positionSE = positionSB + [0 offset 0 offset];
    positionSEInit = positionSE;
end

% add Signal Editor block to model
block = add_block('simulink/Sources/Signal Editor', blockNameSB, ...
    'MakeNameUnique', 'on', 'FileName', FileName, 'Position', positionSEInit);

blockH = get_param(block,'Handle');

% set block properties
set_param(blockH, 'FontName', fontNameSB, 'FontWeight', fontWeightSB, 'FontSize', fontSizeSB,...
                  'FontAngle', fontAngleSB, 'Orientation', orientationSB, ...
                  'ForegroundColor', fgColorSB, 'BackgroundColor', bgColorSB, ...
                  'DropShadow', shadowSB);

set_param(blockH, 'Position', positionSE ); % work around g1656580

% logic to allow setting values if not the default value for the Signal Editor Block
setSampleTime = ~strcmp(sampleTimeSB, '0');
setInterpolate = ~strcmp(interpolateSB, 'off');
setZeroCross = ~strcmp(zeroCrossSB, 'off');
setoutputAfterFinalValue = ~strcmp(outputAfterFinalValueSB, 'Setting to zero');

if (setSampleTime || setInterpolate || setZeroCross || setoutputAfterFinalValue)
    % set signal properties to signal builder settings
%     for idxGroup = 1:length(dsNameCell)
%         % set ActiveScenario
%         set_param(blockH, 'ActiveScenario', dsNameCell{idxGroup});
        for idxSignal = 1:length(sigNames)
            % set ActiveSignal
            set_param(blockH, 'ActiveSignal', sigNames{idxSignal});

            % set SampleTime, Interpolate, ZeroCross, and OutputAfterFinalValue
            set_param(blockH, 'SampleTime', sampleTimeSB, ...
                'Interpolate', interpolateSB, 'ZeroCross', zeroCrossSB, ...
                'OutputAfterFinalValue', outputAfterFinalValueSB);
        end
%     end
end

% set ActiveScenario
set_param(blockH, 'ActiveScenario', dsNameCell{grpIndex});

% Set the signal logging properties
newOutportHandles = get_param(blockH, 'PortHandles').Outport;
if length(newOutportHandles) == length(outportPropsSB)
    for i=1:length(outportPropsSB)
        propStruct = outportPropsSB{i};
        if length(fieldnames(propStruct)) == length(loggingProperties)
            % Check if values are different than default (skip DataLoggingName since DataLoggingNameMode determines its default value)
            if (~strcmp(propStruct.DataLogging, 'off') ||...
                ~strcmp(propStruct.DataLoggingNameMode, 'SignalName') ||...
                ~strcmp(propStruct.DataLoggingDecimateData, 'off') ||...
                ~strcmp(propStruct.DataLoggingDecimation, '2') ||...
                ~strcmp(propStruct.DataLoggingSampleTime, '-1') ||...
                ~strcmp(propStruct.DataLoggingLimitDataPoints, 'off') ||...
                ~strcmp(propStruct.DataLoggingMaxPoints, '5000'))
                set_param(newOutportHandles(i),...
                    'DataLogging', propStruct.DataLogging,...
                    'DataLoggingNameMode', propStruct.DataLoggingNameMode,...
                    'DataLoggingName', propStruct.DataLoggingName,...
                    'DataLoggingDecimateData', propStruct.DataLoggingDecimateData,...
                    'DataLoggingDecimation', propStruct.DataLoggingDecimation,...
                    'DataLoggingSampleTime', propStruct.DataLoggingSampleTime,...
                    'DataLoggingLimitDataPoints', propStruct.DataLoggingLimitDataPoints,...
                    'DataLoggingMaxPoints', propStruct.DataLoggingMaxPoints);
            end
        else
            error(message('sigbldr_api:signalbuilder:OutportLoggingParamMismatch', blockH));
        end
    end
else
    error(message('sigbldr_api:signalbuilder:OutportMismatch', blockH, length(newOutportHandles), length(outportPropsSB)));
end

% get sorted group names and the sorting index
[sortGrpNames, sortGrpIdx] = sort(dsNameCell);

% set requirements on block
if ~all(reqEmpty)
    % some requirements exist. add requirements to Signal Editor block
    reqCnt = 0;
    for grpIdx = sortGrpIdx
        if ~any(reqEmpty == grpIdx)
            % only action non-empty cell arrays
            for idx = 1:reqNumel(grpIdx)
                reqCnt = reqCnt + 1;
                reqSort(reqCnt) = requirements{grpIdx}(idx); %#ok<AGROW>
                % Prepend Signal Editor group name to keywords
                reqSort(reqCnt).keywords = strtrim([sortGrpNames{sortGrpIdx(grpIdx)} ' ' reqSort(reqCnt).keywords]); %#ok<AGROW>
            end
        end
    end
    % set first requirement on Signal Editor block
    rmi('set', blockH, reqSort(1) );
    if (length(reqSort) > 1)
        % more than one requirement to set on Signal Editor block
        for reqIdx = 2:length(reqSort)
            rmi('cat', blockH, reqSort(reqIdx) );
        end
    end
end

% return block handle to signal editor block
if nargout > 0
    varargout{1} = blockH;
    if nargout > 1
        % sorting indices
        varargout{2} = sortGrpIdx;
        if nargout > 2
            % sorted group names
            varargout{3} = sortGrpNames;
        end
    end
end

%--------------------------------------------------------------------------
function inputStruct = parseInputs( varargin )

p = inputParser;

addParameter( p, 'FileName', 'dataset.mat', @isValidFileName);
addParameter( p, 'Replace',  false,         @isScalarLogical);

parse(p,varargin{:});
inputStruct = p.Results;

%--------------------------------------------------------------------------
function isValidFileName(input)

if isempty(input) || (~ischar(input) && ~isstring(input))
    error(message('sigbldr_api:signalbuilder:NotCharFileName'));
end

% convert string to char
input = convertStringsToChars(input);

% get file parts
[~, ~ ,ext] = fileparts(deblank(input));

if ~isempty(ext) && ~strcmpi(ext,'.mat')
    % if not a MAT-file error
    error(message('sigbldr_api:signalbuilder:NotMATFileName'));
end

%--------------------------------------------------------------------------
function isScalarLogical(input)

if isempty(input)
    error(message('sigbldr_api:signalbuilder:NotScalarLogicalReplace'));
end

if ~(islogical(input) && isscalar(input))
    error(message('sigbldr_api:signalbuilder:NotScalarLogicalReplace'));
end

%--------------------------------------------------------------------------
function isSimulating = localIsSimulating(modelH)
% determine if model is simulating
isSimulating = false;

if ~strcmp(get_param(modelH, 'simulationStatus'), 'stopped') && get_param(modelH ,'InteractiveSimInterfaceExecutionStatus') ~= 2
    isSimulating = true;
end

%--------------------------------------------------------------------------
function isFastRestart = localIsFastRestart(modelH)
% determine if model is in fast restart

isFastRestart = false;

if strcmp(get_param(modelH,'InitializeInteractiveRuns'),'on')
    isFastRestart = true;
end

%--------------------------------------------------------------------------
function isLocked = localIsLocked(modelH)
% determine if model is in locked library

isLocked = false;

if strcmpi(get_param(modelH, 'lock'), 'on')
    isLocked = true;
end


