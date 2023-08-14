function sampleTime = getSignalCompiledSampleTime(varargin)
% getSignalCompiledSampleTime
%
% Calculate the Compiled Sample Time for a given signal within a Simulink SYSTEM
%
% Parameters
%   segment_UDD -   UDD object of the signal
%   SYSTEM      -   Name of the current System
%   VERBOSE     -   output the back traversed path that was followed
%
% Returns
%     sampleTime  -  sample time associated with SIGNAL_ID
%
% Example
%
%     sampleTime = getSignalCompiledSampleTime(sighdl, 1)

%   Copyright 2011 The MathWorks, Inc.

if (nargin > 2)
    segment_UDD = varargin{1};
    SYSTEM = varargin{2};
    VERBOSE = varargin{3};
elseif( nargin == 2 )
    segment_UDD = varargin{1};
    SYSTEM = varargin{2};
    VERBOSE = 0;
else
    % Error out only if input parameters are less than 2.
    narginchk(2,3);
end
% Model has to be opened and updated to get LastCompiledSampleTime
visibleStatus = get((get_param(SYSTEM,'Handle')),'Shown');
if (strcmpi(visibleStatus, 'off'))
    disp ('### Open and update model to get the canlib.Signal properties');
    open_system(SYSTEM);
    set_param(SYSTEM, 'SimulationCommand', 'update');
end
% Recursively traverse backward from this signal line
% looking for a Block that specifies CompiledSampleTime
sampleTime = i_findRootBlock(segment_UDD, VERBOSE);

% Simulink.Port - follow a Line if it exists
function [sampleTime, code] = i_Port(udd_obj, VERBOSE)
% check there is a line field
if (udd_obj.Line == -1)
    sampleTime = udd_obj;
    code = 'Unconnected inport in Subsystem.';
    return;
end
[sampleTime code] = i_findRootBlock(get_param(udd_obj.Line,'UDDObject'), VERBOSE);

% Simulink.Segment -
%
% check Segment is connected
% check for triggered subsystem and follow trigger path
% follow srcBlockHandle
function [sampleTime, code] = i_Segment(udd_obj, VERBOSE)
% check this segment is connected
if (udd_obj.srcPortHandle == -1)
    sampleTime = udd_obj;
    code = 'Unconnected line segment.';
    return;
end

% check to see if we are in a triggered subsystem
% if so, the trigger is the path to follow to get the sample time
% get the parent
parent = get_param(udd_obj.parent,'UDDObject');
if isa(parent, 'Simulink.SubSystem')
    fields = get(parent);
    if (isfield(fields,'PortHandles') == 1)
        if (isfield(fields.PortHandles,'Trigger') == 1)
            if (isempty(fields.PortHandles.Trigger) == 0)
                [sampleTime code] = i_findRootBlock(get_param(parent.PortHandles.Trigger,'UDDObject'), VERBOSE);
                return;
            end
        end
    end
end
% get the port handle so we know how to map to the Simulink.Outport
% this line segment is connected to
portObj = get_param(udd_obj.srcPortHandle, 'UDDObject');
[sampleTime code] = i_findRootBlock(get_param(udd_obj.srcBlockHandle, 'UDDObject'), VERBOSE, portObj.PortNumber);

% Simulink.Subsystem -
%
% Find the correct Simulink.Outport and traverse
function [sampleTime, code] = i_Subsystem(udd_obj, VERBOSE, portnum)
% have to find the Simulink.Outport block within the subsystem
% note: there must be one otherwise we wouldn't have ended up in
% the subsystem
if ~isempty(udd_obj.PortHandles.Trigger)
    [sampleTime code] = i_findRootBlock(get_param(udd_obj.PortHandles.Trigger,'UDDObject'), VERBOSE);
else
    % In case of Output port, the sample time is provided by the port
    % itself.
    ts = get_param(udd_obj.PortHandles.Outport(portnum),'LastKnownCompiledSampleTime');
    sampleTime = ts(1);
    code = 'CompiledSampleTime';
end

% Simulink.YYY
%
% Generic block including Simulink.Inport and Simulink.Outport
% Return the CompiledSampleTime
function [sampleTime, code] = i_genericBlock(udd_obj, varargin)
% note: we include Simulink.Inport in this clause!
% note: we inlcude Simulink.Outport in this clause!

switch class(udd_obj)
    % Getting sample time from the ouput port of the upstream block, in case of
    % a Simulink Outport block, the input port of the Outport block provides sample time.
    case 'Simulink.Outport'
        ts = get_param(udd_obj.PortHandles.Inport,'LastKnownCompiledSampleTime');
        sampleTime = ts(1);
        code = 'CompiledSampleTime';
    otherwise
        ts = get_param(udd_obj.PortHandles.Outport(varargin{1}),'LastKnownCompiledSampleTime');
        sampleTime = ts(1);
        code = 'CompiledSampleTime';
end

% Recursive function to traverse the block diagram backwards from the original
% Simulink.Segment and find a Simulink.YYY that has a compiledSampleTime
function [sampleTime, code] = i_findRootBlock(udd_obj, VERBOSE, varargin)
% Path display code
if (VERBOSE == 1)
    if (length(varargin) == 1)
        portnum = varargin{1};
        disp([class(udd_obj) ' Handle=' num2str(udd_obj.handle) ' Port=' num2str(portnum)]);
    else
        disp([class(udd_obj) ' Handle=' num2str(udd_obj.handle)]);
    end
end

switch class(udd_obj)
    case 'Simulink.Port'
        [sampleTime, code] = i_Port(udd_obj, VERBOSE);
    case 'Simulink.Segment'
        [sampleTime, code] = i_Segment(udd_obj, VERBOSE);
    case 'Simulink.SubSystem'
        % can we retrieve a port number from varagin?
        if (length(varargin) == 1)
            portnum = varargin{1};
            [sampleTime, code] = i_Subsystem(udd_obj, VERBOSE, portnum);
        else
            sampleTime = udd_obj;
            code = 'No port number supplied by the Simulink.Segment!';
            return;
        end
    otherwise
        [sampleTime, code] = i_genericBlock(udd_obj, varargin{1});
end