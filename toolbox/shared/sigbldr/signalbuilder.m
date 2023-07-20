function varargout = signalbuilder(blockH, method, varargin)
%SIGNALBUILDER - Command line interface to the Simulink Signal Builder block.
%
%  [TIME, DATA] = SIGNALBUILDER(BLOCK) Returns the X coordinates, TIME, and Y
%  coordinates, DATA, of the Signal Builder block, BLOCK.  TIME and DATA take
%  different formats depending on the block configuration:
%
%    Configuration:        TIME/DATA format:
%
%    1 signal, 1 group     Row vector of break points
%
%    >1 signal, 1 group    Column cell vector where each element corresponds to
%                          a separate signal and contains a row vector of breakpoints
%
%    1 signal, >1 group    Row cell vector where each element corresponds to a
%                          separate group and contains a row vector of breakpoints
%
%    >1 signal, >1 group   Cell matrix where each element (i, j) corresponds to
%                          signal i and group j.
%
%
%  [TIME, DATA, SIGNAMES] = SIGNALBUILDER(BLOCK) Returns the signal names,
%  SIGNAMES, in a string or a cell array of strings.
%
%  [TIME, DATA, SIGNAMES, GROUPNAMES] = SIGNALBUILDER(BLOCK) Returns the group
%  names, GROUPNAMES in a string or a cell array of strings.
%
%  CREATING A NEW BLOCK
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES)
%  Creates a new Signal Builder block at PATH using the specified values.
%  If PATH is empty, the function creates the block in a new model with a
%  default name. If DATA is a cell array and TIME is a vector, the function
%  duplicates the TIME values for each element of DATA.  Each vector within
%  TIME and DATA must be the same length and have at least two elements.
%  If TIME is a cell array, all elements in a column must have the same
%  initial and final value.  To use default values for signal names, SIGNAMES,
%  and group names, GROUPNAMES, omit these values.  The function returns the
%  path to the new block, BLOCK.
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES, VIS)
%  Creates a new Signal Builder block and sets the visible signals in each
%  group based on the values of the matrix VIS. VIS must be the same size as
%  the cell array DATA. When you first create a signal builder block, its
%  first signal is always visible. This behavior is regardless of the value
%  of the VIS option.
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES, VIS, POS)
%  Creates a new Signal Builder block and sets the block position to POS.
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES, VIS, POS, {OPENUI OPENMODEL})
%  Creates a new Signal Builder block and opens the UI and/or opens the
%  model based on the values of OPENUI and OPENMODEL.
%
%  ADDING NEW GROUPS
%
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPEND', TIME, DATA, SIGNAMES, GROUPNAMES) or
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPENDGROUP', TIME, DATA, SIGNAMES, GROUPNAMES)
%  Appends new groups to the Signal Builder block, BLOCK.  The TIME and DATA
%  arguments must have the same number of signals as the existing block.
%
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPEND', DS) or
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPENDGROUP', [DS1 DS2])
%  Appends new groups from Simulink.SimulationData.Dataset object(s) to the 
%  Signal Builder block, BLOCK.  The DS argument(s) must have the same number of 
%  signals as the existing block and the elements must be timeseries of
%  data type double.
%
%  ADDING NEW SIGNALS TO CURRENT GROUPS
%
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPENDSIGNAL', TIME, DATA, SIGNAMES)
%  Appends new signals to ALL groups in Signal Builder block, BLOCK. You
%  must append signals to all groups in the block; you cannot append signals
%  to only a subset of groups. As a result, you must provide TIME and DATA
%  arguments for either one  group (append the same signal(s) to all groups)
%  or for all  groups. You can omit signal names, SIGNAMES, to use default
%  values.
%
%  SETTING SIGNALS VISIBILITY
%
%  SIGNALBUILDER(BLOCK, 'SHOWSIGNAL', SIGNAL, GROUP)
%  Sets signals, SIGNAL, from groups, GROUP, to be visible. SIGNALs can
%  be the unique name of a signal, a scalar index of a signal, or an array
%  of signal indices.  GROUP parameter can be a unique group name, a scalar
%  index, or an array of indices.
%
%  SIGNALBUILDER(BLOCK, 'HIDESIGNAL', SIGNAL, GROUP)
%  Set signals, SIGNAL, from groups, GROUP, to be invisible.
%
%  GET/SET METHODS FOR SPECIFIC SIGNALS AND GROUPS
%
%  [TIME, DATA] = SIGNALBUILDER(BLOCK, 'GET', SIGNAL, GROUP) Gets the time and
%  data values for the specified signal(s) and group(s).  The SIGNAL parameter
%  can be the unique name of a signal, a scalar index of a signal, or an array
%  of signal indices.  The GROUP parameter can be a unique group name, a scalar
%  index, or an array of indices.
%    
%  [DS1, DS2] = SIGNALBUILDER(BLOCK, 'GET', GROUP) Returns a 
%  Simulink.SimulationData.Dataset object(s) for the specified group(s). The 
%  GROUP parameter can be a unique group name, a scalar index, or an array of 
%  indices.
%
%  SIGNALBUILDER(BLOCK, 'SET', SIGNAL, GROUP, TIME, DATA) Sets the time and
%  data values for the specified signal(s) and group(s).  To remove groups and
%  signals, use empty values of TIME and DATA. You can only remove signals
%  from all groups. You cannot delete signals from only a subset of groups.
%
%  SIGNALBUILDER(BLOCK, 'SET', GROUP, DS) Sets the time and
%  data values for the specified group(s) from
%  Simulink.SimulationData.Dataset object(s).  Group and signal names of
%  BLOCK will not be updated to the names in the
%  Simulink.SimulationData.Dataset object(s).  The DS argument(s) must have
%  the same number of signals as the existing block and the elements must
%  be timeseries of data type double. To remove groups and signals, use empty 
%  Simulink.SimulationData.Dataset object(s). 
%
%  QUERY AND SET THE ACTIVE GROUP USED IN SIMULATION
%
%  INDEX = SIGNALBUILDER(BLOCK, 'ACTIVEGROUP') Gets the index of the currently
%  active group
%
%  [INDEX, ACTIVEGROUPLABEL] = SIGNALBUILDER(BLOCK, 'ACTIVEGROUP') Gets the index 
%    and label values of the currently active group   
%
%  SIGNALBUILDER(BLOCK, 'ACTIVEGROUP', INDEX) Sets the active group index
%  to INDEX
%
%  ANNOTATE SIGNAL BUILDER BLOCK WITH ACTIVE GROUP NAME
%  
%  SIGNALBUILDER(BLOCK,'ANNOTATEGROUP','ON') turns on the group annotation 
%
%  SIGNALBUILDER(BLOCK,'ANNOTATEGROUP','OFF) turns off the group annotation
%
%  PRINTING
%
%  SIGNALBUILDER(BLOCK, 'PRINT', CONFIG, <PRINT ARGS>) Prints a single group.
%  The function includes the contents of the group after removing the interface
%  items from the window. Refer to the help on PRINT for information about the
%  available calling syntax and format for <PRINT ARGS>.  You can control the
%  details of printing with the optional CONFIG structure. This structure can
%  contain the following fields:
%
%      groupIndex := Group Index
%       timeRange := Time range (limited to full group range)
%  visibleSignals := Index of signals to display
%         yLimits := Cell array of Y Limits for each signal
%          extent := Pixel extent of captured figure
%       showTitle := True (default) indicates a title should be added
%
%  The default value of each parameter is based on the current display. If the
%  interface is not open, then the default of each parameter is based on the last
%  active display
%
%  FIGH = SIGNALBUILDER(BLOCK, 'PRINT', CONFIG, 'FIGURE') Prints the signal builder
%  to a new hidden figure handle FIGH.
%
%

%  Copyright 2003-2021 The MathWorks, Inc.

% For UE performance, enable grouping of multiple set_param calls into
% higher level transactions.
grouper = []; %#ok<NASGU>
if inmem('-isloaded','get_param') && inmem('-isloaded','sl_datamodel')
    grouper = SLM3I.ScopedGroupTransactions();  %#ok<NASGU>
end

% Check number of inputs to determine if valid. If not error is thrown.
narginchk(1,9);

% convert string to char; otherwise pass through
blockH = convertStringsToChars(blockH); 

% convert string to char; otherwise pass through
if nargin > 1
    method = convertStringsToChars(method);
end

if ( ( nargin == 1 || ~strcmpi(method, 'create') ) && isempty(blockH))
    error(message('sigbldr_api:signalbuilder:noBlockSpecified'));
end

if nargin < 2
    method = 'props';
end

if ~ischar(method)
    error(message('sigbldr_api:signalbuilder:stringMethod'));
end

% Put arguments in a canonical form
if  ~strcmpi(method, 'create')       % if method is NOT create
   
    %Check if the signal builder block is open    
    try
      objH = get_param(blockH,'Handle');
        
    catch invalidBlock  
        %This means the block is not open.
        if(~ischar(blockH))
            error(message('sigbldr_api:signalbuilder:BlockNotOpen',inputname(1),inputname(1)));
        else
            error(message('sigbldr_api:signalbuilder:BlockNotOpen',blockH,blockH));
        end
    end
    if  ~is_signal_builder_block(blockH)
        error(message('sigbldr_api:signalbuilder:invalidBlock',getfullname(blockH)));
    end
    blockH = objH;

else                                 % if method is create
    if  ~isempty(blockH) && ~is_valid_path(blockH)
        error(message('sigbldr_api:signalbuilder:invalidBlockPath'));
    end
    
end

% convert strings to chars; otherwise pass through
if nargin > 2 
    for iii = 1:(nargin-2)
        if iscell(varargin{iii}) && any(any(cellfun(@isstring, varargin{iii})))
            for jjj = 1:length(varargin{iii})
                % convertStringsToChars fails to convert cell arrays of
                % strings. Doing this to support the current format of
                % inputting cell arrays
                %
                % Rationale for non-support:
                % If your inputs are only supposed to support text, you
                % don't need to support a cell array of string objects. The
                % proper text arrays types are string arrays and cell
                % arrays of character vectors. We do not consider a cell
                % array of string scalars to be a text type.  
                %
                [varargin{iii}{jjj}] = convertStringsToChars(varargin{iii}{jjj});
            end
        else 
            [varargin{iii}] = convertStringsToChars(varargin{iii});
        end
    end
end

switch lower(method)
    %---------------------------------------------------------------------%
    case 'get'
        % nargin = 3 : [ DS1, DS2 ] = signalbuilder( blockH, 'get', GroupIdx )
        % nargin = 4 : [ Time, Data ] = signalbuilder( blockH, 'get', SignalIdx, GroupIdx )
        
        narginchk( 3, 4 );
        %local_nargin_check(method, nargin, 4);
        
        if nargin > 3
            SBSigSuite = getSBSigSuite(blockH);
            [signal, group, signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, method, varargin{:});
            [time, data, varargout{3}, varargout{4}] = groupSignalGet(SBSigSuite, signal, group);

            % if needed, delete duplicate points and duplicate end points
            % switching to active group will trim data automatically
            numSig = length(signalIdx);
            numGrp = length(groupIdx);
            activeGroup = SBSigSuite.ActiveGroup;

            if ~((numGrp == 1) && (groupIdx == activeGroup))
                [timeNew, dataNew] = local_trimDataPoints(time, data, numSig, numGrp);
                varargout{1} = timeNew;
                varargout{2} = dataNew;
            else
                varargout{1} = time;
                varargout{2} = data;
            end
        else
            % Simulink.SimulationData.Dataset to be returned
            SBSigSuite = getSBSigSuite(blockH);
            [~, groupIdx] = local_resolve_group_index(SBSigSuite, varargin{:});
            
            % if needed, delete duplicate points and duplicate end points
            % switching to active group will trim data automatically
            numGrp = length(groupIdx);
            activeGroup = SBSigSuite.ActiveGroup;
            
            if ~((numGrp == 1) && (groupIdx == activeGroup))
                SBSigSuite = local_trimDataPointsSS(SBSigSuite, groupIdx);
            end           
            
            ds = SBSigSuite.group2Dataset(groupIdx);
            
            for dsIdx = numel(ds):-1:1
                dsOut = ds(dsIdx);
                varargout{dsIdx} = dsOut;
            end

        end
        
        %---------------------------------------------------------------------%
    case 'appendsignal'
        % nargin = 5 : signalbuilder( blockH, 'appendsignal', Time, Data, sigNames )
        local_nargin_check(method, nargin, 5);
        
        if nargin < 4
            error(message('sigbldr_api:signalbuilder:appendSignalMethod'));
        end
        SBSigSuite = getSBSigSuite(blockH);

        if nargin < 5
            groupSignalAppend(SBSigSuite, varargin{1}, varargin{2});
        else
            groupSignalAppend(SBSigSuite, varargin{1}, varargin{2}, varargin{3});
        end
        
        signal_append(blockH, SBSigSuite);
        varargout{1} = blockH;
        
        %---------------------------------------------------------------------%
    case 'movesignal'
        % nargin = 4 : signalbuilder( blockH, 'movesignal', oldIdx, newIdx)
        %---------------------------------------------------------------------%
    case 'movegroup'
        % nargin = 4 : signalbuilder( blockH, 'movesignal', oldIdx, newIdx)
        %---------------------------------------------------------------------%
       
    case 'showsignal'
        % nargin = 4 : signalbuilder( blockH, 'showsignal', SignalIdx, GroupIdx )
        local_nargin_check(method, nargin, 4);
        SBSigSuite = getSBSigSuite(blockH);
        [~, ~, signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, method, varargin{:});
        ActiveGroup = SBSigSuite.ActiveGroup;
        
        forceOpen = false;
        figH = get_param(blockH, 'UserData');
        if isempty(figH) || ~ishghandle(figH, 'figure')
            forceOpen = true;
            open_system(blockH,'OpenFcn');
            figH = get_param(blockH, 'UserData');
        end
        UD = get(figH, 'UserData');
        
        
        grpCnt = length(groupIdx);
        sigCnt = length(signalIdx);
        for gidx = 1:grpCnt
            m = groupIdx(gidx);
            curVis = UD.dataSet(m).activeDispIdx;
            for sidx = 1:sigCnt
                n = signalIdx(sidx);
                % if signal n is already visible, don't do anything.
                if (m == ActiveGroup)
                    toAdd = (curVis == n);
                    %if (sum(toAdd) == 0)
                    if (~any(toAdd))
                        UD = signal_show(UD, n, m);
                    end
                end
            end
            newVis = signalIdx;
            totalVis = unique([curVis newVis]);
            totalVis = sort(totalVis(:), 'descend')';
            UD.dataSet(m).activeDispIdx = totalVis;
        end
        
        UD = cant_undo(UD);
        set(UD.dialog, 'UserData', UD)
        
        % Close the GUI if it was forced open
        if(forceOpen)
            UD = set_dirty_flag(UD);
            close_internal(UD);
        end
        
        %---------------------------------------------------------------------%
    case 'hidesignal'
        % nargin = 4 : signalbuilder( blockH, 'hidesignal', SignalIdx, GroupIdx )
        local_nargin_check(method, nargin, 4);
        SBSigSuite = getSBSigSuite(blockH);
        [~, ~, signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, method, varargin{:});
        ActiveGroup = SBSigSuite.ActiveGroup;
        
        forceOpen = false;
        figH = get_param(blockH, 'UserData');
        if isempty(figH) || ~ishghandle(figH, 'figure')
            forceOpen = true;
            open_system(blockH,'OpenFcn');
            figH = get_param(blockH, 'UserData');
        end
        UD = get(figH, 'UserData');
        
        grpCnt = length(groupIdx);
        sigCnt = length(signalIdx);
        for gidx = 1:grpCnt
            m = groupIdx(gidx);
            curVis = UD.dataSet(m).activeDispIdx;
            for sidx = 1:sigCnt
                n = signalIdx(sidx);
                toRemove = (curVis == n);
                %if (sum(toRemove) ~= 0)
                if (any(toRemove))
                    curVis(toRemove) = [];
                    if (m == ActiveGroup)
                        axesIdx = find(UD.dataSet(m).activeDispIdx == n);
                        UD = signal_hide(UD, n, m, axesIdx);
                    end
                end
            end
            UD.dataSet(m).activeDispIdx = curVis;
            
        end
        
        UD = cant_undo(UD);
        set(UD.dialog, 'UserData', UD)
        
        % Close the GUI if it was forced open
        if(forceOpen)
            UD = set_dirty_flag(UD);
            close_internal(UD);
        end
        
        %---------------------------------------------------------------------%
    case 'set'
        % nargin = 4 : signalbuilder( blockH, 'set', GroupIdx, Ds )
        % nargin = 4 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx )
        % nargin = 5 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx, Time )
        % nargin = 6 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx, Time, Data )
        local_nargin_check(method, nargin, 6);
        SBSigSuite = getSBSigSuite(blockH);
        
        if ((nargin == 4) && (isa(varargin{2},'Simulink.SimulationData.Dataset')))
            % set dataset input
            [~, groupIdx] = local_resolve_group_index(SBSigSuite, varargin{:});
            
            ds = varargin{2};
                        
            if isempty(ds) 
                % Scenario 1: dataset is empty
                grpCnt = SBSigSuite.NumGroups;
                groupIdx = sort(groupIdx(:), 'ascend')';
                removeGroups = groupIdx;                    
                local_remove_groups(blockH, SBSigSuite, groupIdx, grpCnt, removeGroups)

            else
                % Scenario 2: dataset is NOT empty
                
                numSigBlk = SBSigSuite.Groups(1).NumSignals;
                
                for jjj = 1:numel(ds)
                    grpName = ds(jjj).Name;
                    numSig = ds(jjj).numElements;
                    signalIdx = 1:numSig;
                    % check number of elements is equal to number of signal in sigbldr group
                    local_validate_dataset_number_elements(numSig, numSigBlk, grpName);
                    for mmm = signalIdx
                        % only accept simple dataset generated by signal builder
                        sig(mmm) =  ds(jjj).getElement(mmm); %#ok<AGROW>
                        % Check elements
                        local_validate_dataset_elements(sig(mmm), mmm);
                        % Get time and data
                        time{mmm,1} = sig(mmm).Time; %#ok<AGROW>
                        data{mmm,1} = sig(mmm).Data; %#ok<AGROW>
                    end
                    
                    local_set_group_data(blockH, SBSigSuite, time, data, signalIdx, groupIdx(jjj));
                end
            end
        else
            % set time and data input
            [~, ~, signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, method, varargin{:});
            [time, data] = local_get_set_nargin_check(signalIdx, groupIdx, varargin{:});
            
            ActiveGroup = SBSigSuite.ActiveGroup;
            grpCnt = SBSigSuite.NumGroups;
            sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;
            
            
            % Scenario 1: time and data are empty
            if isempty(time) && isempty(data)
                signalIdx = sort(signalIdx(:), 'ascend')';                
                groupIdx = sort(groupIdx(:), 'ascend')';
                removeGroups = groupIdx;
                if isequal(signalIdx, 1:sigCnt)
                    local_remove_groups(blockH, SBSigSuite, groupIdx, grpCnt, removeGroups);
                    return;
                elseif isequal(groupIdx, 1:grpCnt)
                    removeSignals = signalIdx;
                    
                    % GUI Operations:
                    %----------------
                    % Force open the GUI if needed
                    forceOpen = false;
                    figH = get_param(blockH, 'UserData');
                    if isempty(figH) || ~ishghandle(figH, 'figure')
                        forceOpen = true;
                        open_system(blockH,'OpenFcn');
                        figH = get_param(blockH, 'UserData');
                    end
                    UD = get(figH, 'UserData');
                    % Need to remove signals in reverse order
                    groupSignalRemove(SBSigSuite, removeSignals);
                    for sigIdx = sort(removeSignals(:), 'descend')'
                        UD = remove_channel(UD, sigIdx);
                    end
                    UD = cant_undo(UD);
                    set(UD.dialog, 'UserData', UD) % save changes
                    
                    % Close the GUI if it was forced open
                    if(forceOpen)
                        close_internal(UD);
                    end
                    return;
                    
                else
                    ME = MException('sigbldr_api:signalbuilder:removeGroupOrSignal', ...
                        getString(message('sigbldr_api:signalbuilder:removeGroupOrSignal')));
                    throw(ME);
                end
                
            elseif iscell(data) & find(cellfun('isempty',data), 1) %#ok<AND2>
                % check for input like {[];[]}
                if numel(find(cellfun('isempty',data))) == numel(data)
                    ME = MException('sigbldr_api:signalbuilder:multipleemptyinput', ...
                        getString(message('sigbldr_api:signalbuilder:MultipleEmptyInput')));
                    throw(ME);
                    
                end
                ME = MException('sigbldr_api:signalbuilder:simultaneouschangeanddelete', ...
                    getString(message('sigbldr_api:signalbuilder:SimultaneousChangeAndDelete')));
                throw(ME);
            end
            
            % Scenario 2: time and data are NOT empty
            local_set_group_data(blockH, SBSigSuite, time, data, signalIdx, groupIdx);

        end
        %---------------------------------------------------------------------%
    case 'activegroup'
        % nargin = 2 : groupIdx = signalbuilder( blockH, 'activegroup' )
        % nargin = 3 : groupIdx = signalbuilder( blockH, 'activegroup', Index )
        local_nargin_check(method, nargin, 3);
        SBSigSuite = getSBSigSuite(blockH);
        if nargin == 3
            % set the activegroup to the indexed one
            newIdx = varargin{1};
            SBSigSuite.ActiveGroup = newIdx;
            
            % GUI Operations:
            %-----------------
            figH = get_param(blockH, 'UserData');
            
            if ~isempty(figH) && ishghandle(figH, 'figure')
                UD = get(figH, 'UserData');
                UD = showTab(UD, newIdx);
                set(UD.dialog, 'UserData', UD);
            else
		% @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
		% instead use the post-compile filter activeVariants() - g2603134
                fromWsH = find_system(blockH, 'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
		    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,... % look only inside active choice of VSS
                    'BlockType', 'FromWorkspace');
                savedUD = get_param(fromWsH, 'SigBuilderData');
                savedUD.sbobj = SBSigSuite;
                
                savedUD.dataSetIdx = newIdx;
                
                savedUD = trimDataPoints( savedUD );
                
                set_param(fromWsH, 'SigBuilderData', savedUD);
                vnv_notify('sbBlkGroupChange', blockH, newIdx);
                set_param(blockH, 'UserData', -1);
                % changing the active group name on the mask
                refreshGroupAnnotation(blockH);
            end
        end
        
        if nargout > 0
            % get the activegroup
            varargout{1} = SBSigSuite.ActiveGroup;
            if nargout >1
                %using the ActiveGroup Property from SBSigSuite index into the
                %SBSigSuite.Groups and get the Name property from the
                %SigSuiteGroup class
                varargout{2} = SBSigSuite.Groups(SBSigSuite.ActiveGroup).Name;
            end

        end
        
        %--------------------------------------------------------------------%
    case 'annotategroup'
        % nargin = 3 : signalbuilder( blockH, 'activegroup', 'on' )
        local_nargin_check(method, nargin, 3);
        if nargin<3
             DAStudio.error('sigbldr_api:signalbuilder:AnnotateGroupInvalidParameters');
        end
        %These commands are also present in sigbuilder_block.m and the
        %signal builder block mask in simulink.mdl. Consider changing them
        %there while changing these.
        groupHideCmd = ['plot(0,0,100,100,[10,10,40,40,10],[80,20,20,80,80],'...
            '[40,10],[50,50], [40,27,10],[65,72,56],[40,25,25,10],[28,28,43,43]);'];         
        groupShowCmd = ['plot(0, 0, 100, 100,[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
            '[32, 2], [38, 38], [32, 19, 2],[53, 60, 44], [32, 17, 17, 2],[16, 16, 31, 31]);'...
            'txt = getActiveGroup(gcbh);text(2, 100, txt,''verticalAlignment'', ''top'');'];
        if strcmpi(varargin{1},'on')
            set_param(blockH,'MaskDisplay',groupShowCmd);
        elseif strcmpi(varargin{1},'off')
            set_param(blockH,'MaskDisplay',groupHideCmd);
        else
            DAStudio.error('sigbldr_api:signalbuilder:AnnotateGroupInvalidParameters');
        end
        
        %---------------------------------------------------------------------%
    case 'print'
        % can only use figure or cmd (default) method from command line
        % nargin = 3 : figH = signalbuilder( blockH, 'print', Config )
        % nargin = 4 : figH = signalbuilder( blockH, 'print', Config, 'figure' )
        % nargin = 4 -> 8 : figH = signalbuilder( blockH, 'print', Config, <print args> )
        
        %This is the third argument, empty by default.
        configstruct = [];
        % Checking for validity of 3rd argument.
        if(nargin >=3)
            if ~isempty(varargin{1})
                %User passed something in the 3rd argument intentionally.
                if ~isstruct(varargin{1})
                    %Throws an error when the third argument is not empty but
                    %its not a struct either.
                    error(message('sigbldr_api:signalbuilder:InvalidPrintCommand'));
                else
                    configstruct = varargin{1};
                    
                    if~(any (isfield(configstruct,{'groupIndex','timeRange','visibleSignals','yLimits','extent','showTitle'})))
                        % When none of the customization properties are to be
                        % found in the input struct, the user is warned. This
                        % is not an error condition since its not mandatory to
                        % customize the printing.
                        warning(message('sigbldr_api:signalbuilder:InvalidConfigStruct',inputname(3)));
                    end
                end
            end
        end
        
        if nargin > 3 && ischar(varargin{2}) && strcmpi(varargin{2}, 'figure')
            options = varargin(:);
        else
            options = {configstruct 'cmd' varargin{2:end}};
            
        end
        
        % try to print signal builder block gui
        try
            [figH, errMsg] = sigbuilder('print', blockH, [], options{:});
        catch ProblemSendingFile
            errPrintID = {'MATLAB:print:ProblemSendingFile','MATLAB:print:invalidPrinter'};
            [isErr,~] = ismember(errPrintID,ProblemSendingFile.('identifier'));
            
            if any(isErr)
                %g898145 - add input parameter. Create errMsg to throw the
                %error below
                errMsg = DAStudio.message(errPrintID{isErr},get(blockH,'Name'));
            else
                rethrow(ProblemSendingFile);
            end
        end
        
        % catch any errors with printing or print parameters
        if ~isempty(errMsg)
            error(message('sigbldr_api:signalbuilder:printError', errMsg));
        end
        if nargout > 0
            varargout{1} = figH;
        end
        
        %---------------------------------------------------------------------%
    case {'appendgroup', 'append'}
        % nargin = 2 -> 6: blockH = signalbuilder( blockH,'append', time, data, SigNames, GroupNames )
        local_nargin_check(method, nargin, 6);
        if (nargin < 3)
            error(message('sigbldr_api:signalbuilder:appendMethod'));
        end
        SBSigSuite = getSBSigSuite(blockH);
        
        if nargin == 3
            % Simulink.SimulationData.Dataset or array of Simulink.SimulationData.Dataset is input
            ds = varargin{1};
            if ~(isa(ds,'Simulink.SimulationData.Dataset'))
                error(message('sigbldr_api:signalbuilder:DatasetInput'));
            end
            
            % check for empty datasets
            if isempty(ds) 
                error(message('sigbldr_api:signalbuilder:DatasetEmpty'));
            end
            
            numSigBlk = SBSigSuite.Groups(1).NumSignals;
            
            for jjj = 1:numel(ds)
                grpName = ds(jjj).Name; 
                numSig = ds(jjj).numElements;
                % check number of elements is equal to number of signal in sigbldr group
                local_validate_dataset_number_elements(numSig, numSigBlk, grpName);
                
                for mmm = 1:numSig
                    % only accept simple dataset generated by signal builder
                    sig(mmm) =  ds(jjj).getElement(mmm); %#ok<AGROW>
                    % Check elements
                    local_validate_dataset_elements(sig(mmm), mmm);
                    % Get time and data
                    time{mmm,1} = sig(mmm).Time; %#ok<AGROW>
                    data{mmm,1} = sig(mmm).Data; %#ok<AGROW>
                    % always return the last set of signal name per signal
                    % builder standard behavior
                    sigNames{mmm} = sig(mmm).Name; %#ok<AGROW>
                end
                
                [SBSigSuite, ~] = groupAppend(SBSigSuite, time, data, sigNames, grpName);
            end
        else
            [SBSigSuite, ~] = groupAppend(SBSigSuite, varargin{1:end});
        end
        
        group_append(blockH, SBSigSuite);
        varargout{1} = blockH;
        %---------------------------------------------------------------------%
    case 'create'
        % nargin = 2 -> 8: blockH = signalbuilder( path, 'create', time, data, SigNames, GroupNames, Visibility, blkPos, { openUI openModel } )
        local_nargin_check(method, nargin, 9);
        if (nargin < 4)
            error(message('sigbldr_api:signalbuilder:createMethod'));
        end
        visibility = [];
        blkPos = [];
        openUI = 1;
        openModel = 1;
        if nargin >= 6
            SBSigSuite = SigSuite(varargin{1:4});
        else
            SBSigSuite = SigSuite(varargin{:});
        end       
        
        if nargin >= 7
            if ~isnumeric(varargin{5})
                error(message('sigbldr_api:signalbuilder:matrixVIS'));
            end
            visibility = varargin{5};
        end
        
        if nargin >= 8
            % allow [] in addition to [ x y dx dy].  disallow ''
            if ~(isempty(varargin{6}) && isnumeric(varargin{6})) && (~isnumeric(varargin{6}) || length(varargin{6}) ~= 4)
                error(message('sigbldr_api:signalbuilder:vectorPOS'));
            end
            blkPos = varargin{6};
        end
        
        if nargin >= 9
            if ~iscell(varargin{7}) || length(varargin{7}) ~= 2
                error(message('sigbldr_api:signalbuilder:cellOpen'));
            end
            
            openUI = varargin{7}{1};
            openModel  = varargin{7}{2};
            
            if ~(isscalar(openUI) && isnumeric(openUI))
                error(message('sigbldr_api:signalbuilder:scalarOpenUI'));
            end
            if ~(isscalar(openModel) && isnumeric(openModel))
                error(message('sigbldr_api:signalbuilder:scalarOpenModel'));
            end
        end
        
        % Check for valid path
        blockPath = blockH;
        if ~isempty(blockPath) && ~ischar(blockPath)
            error(message('sigbldr_api:signalbuilder:needCharacterPath'));
        end
        
        % Check visibility
        if ~isempty(visibility)
            grpCnt = SBSigSuite.NumGroups;
            ActiveGroup = SBSigSuite.ActiveGroup;
            sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;
            
            [visRows, visCols] = size(visibility);
            if (visRows ~= sigCnt || visCols ~= grpCnt)
                error(message('sigbldr_api:signalbuilder:visibilityRowsColumns'));
            end
            
            % Make at least one signal visible in every group to prevent errors
            visibility(1, :) = visibility(1, :) + (sum(visibility, 1) == 0);
        end
        
        
        % create model and/or add signal builder block to model
        apiData = create_gui_data(SBSigSuite, visibility);
        apiData.sbobj = SBSigSuite;
        
        % Create the GUI
        if openUI
            dialog = create([], apiData.sbobj.Groups(apiData.sbobj.ActiveGroup).Name);
        else
            % keep_hidden = 1;
            dialog = create(1, apiData.sbobj.Groups(apiData.sbobj.ActiveGroup).Name);
        end
        UD = get(dialog, 'UserData');
        UD = restore_from_saveStruct(UD, apiData);
        %Since this is create API update all groups
        grpToUpdate = 1:SBSigSuite.NumGroups;
        guiOpen = 1; %Create API opens UI.
        UD = update_time_range(UD, SBSigSuite,grpToUpdate,guiOpen);
        
        % Create the block
        UD = export_to_simulink(UD, blockPath, blkPos, openModel);
        set(dialog, 'UserData', UD);
        update_titleStr(UD);
        
        % Add root callback to close UI when model is closed (g1568484)
        modelH = UD.simulink.modelH;
        blockH = UD.simulink.subsysH;
        modelObject = get_param(modelH, 'object');
        id = matlab.lang.makeValidName(getfullname(blockH));

        if ~modelObject.hasCallback('PreClose', id)
            Simulink.addBlockDiagramCallback(modelH, 'PreClose', id ,@()preCloseCallback(dialog,[]));
        end
        
        % need this due to the restore call above.
        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end
        
        vnv_notify('sbBlkUpdateGroupInfo', UD.simulink.subsysH);
        
        if nargout > 0
            varargout{1} = blockH;
        end
        
        %---------------------------------------------------------------------%
    case 'props'
        % nargin = 1: [ Time, Data, SignalName, GroupName ] = signalbuilder( blockH );
        
        % collect output data
        SBSigSuite = getSBSigSuite(blockH);
        [time, data, sigNames, grpNames] = groupSignalGetAll(SBSigSuite);

        % if needed, delete duplicate points and duplicate end points
        % switching to active group will trim data automatically
        numSig = SBSigSuite.Groups.NumSignals;
        numGrp = SBSigSuite.NumGroups;
        
        if numGrp ~= 1
            [timeNew, dataNew] = local_trimDataPoints(time, data, numSig, numGrp);
            varargout{1} = timeNew;
            varargout{2} = dataNew;
        else
            varargout{1} = time;
            varargout{2} = data;
        end
                
        if nargout > 2
            varargout{3} = sigNames;
        end
        
        if nargout > 3
            varargout{4} = grpNames;
        end
        %---------------------------------------------------------------------%
    otherwise
        DAStudio.error('Sigbldr:sigbldr:APIUnknownMethod', method);
        %error('sigbldr_api:signalbuilder:unknownMethod', ['Unexpected METHOD value: "' method '"']);
end
%--------------------------------------------------------------------------
% Nested Functions
%--------------------------------------------------------------------------
% getSBSigSuite(blockH)
%--------------------------------------------------------------------------
    function SBSigSuite = getSBSigSuite(blockH)
        if isa(blockH, 'SigSuite')
            SBSigSuite = blockH;
        else
            figH = get_param(blockH, 'UserData');
            if ~isempty(figH) && ishghandle(figH, 'figure')
                UD = get(figH, 'UserData');
                SBSigSuite = UD.sbobj;
            else
                SBSigSuite = update_sbobj(blockH);
            end
        end
    end
%--------------------------------------------------------------------------
%local_check_set_time
%--------------------------------------------------------------------------
    function time_out = local_check_set_time(time_in)
        % test input before assignment
        if ~iscell(time_in) && ~isnumeric(time_in)
            error(message('sigbldr_api:signalbuilder:vectorOrCellTime'));
        end
        time_out = time_in;
    end
%--------------------------------------------------------------------------
% local_check_set_data
%--------------------------------------------------------------------------
    function data_out = local_check_set_data(data_in)
        % test input before assignment
        if ~iscell(data_in) && ~isnumeric(data_in)
            error(message('sigbldr_api:signalbuilder:vectorOrCellData'));
        end
        data_out = data_in;
    end
%--------------------------------------------------------------------------
% local_get_set_nargin_check
%--------------------------------------------------------------------------
    function [time, data] = local_get_set_nargin_check(signalIdx, groupIdx, varargin)
        % preallocate optional inputs
        time = []; data = [];
               
        % nargin >= 5 is only called for set method
        if nargin >= 5
            time = local_check_set_time(varargin{3});
        end
        
        if nargin >= 6
            data = local_check_set_data(varargin{4});            
            if ((iscell(time) && ~isempty(time)) && (~iscell(data) && ~isempty(data)))
                % when time is cell and data is array and not empty
                error(message('sigbldr_api:signalbuilder:vectorOrCell'));
            end
            
            % Do a rough consistency check for time and data
            % A thorough consistency check is done when setting the data
            matrixTime = ~isempty(time) && (~isvector(time) && ismatrix(time));
            matrixData = ~isempty(data) && (~isvector(data) && ismatrix(data));
            if matrixTime && ~matrixData
                % time is a matrix and data is a vector
                error(message('Sigbldr:sigsuite:GroupTimeDataFormatMatch'));
            end
            if (matrixTime && matrixData) && any(size(time)~=size(data))
                % matrix sizes of time and data don't match
                error(message('Sigbldr:sigsuite:GroupTimeDataMismatchGeneral'));
            end
            
            % Determine if data is the same size as specified by signal, group
            sigCnt = length(signalIdx);
            grpCnt = length(groupIdx);
            if iscell(data)
                [numSigs, numGrps] = size(data);
            else
                if iscolumn(data)
                    % single column of data g1705116
                    [~, numSigs] = size(data);
                else
                    % array of data in rows
                    [numSigs, ~] = size(data);
                end
                numGrps = 1;
            end
            
            if ~isempty(data) && (sigCnt ~= numSigs)
                error(message('sigbldr_api:signalbuilder:SignalDataMismatch', sigCnt,  numSigs));
            end
            if ~isempty(data) && (grpCnt ~= numGrps)
                error(message('sigbldr_api:signalbuilder:GroupDataMismatch', grpCnt, numGrps));
            end
        end
    end
%--------------------------------------------------------------------------
% local_nargin_check
%--------------------------------------------------------------------------
    function local_nargin_check(method, argSize, max)
        if argSize > max
            DAStudio.error('Sigbldr:sigbldr:APIMaxArgCheck', method);
        end
        
    end
end

%--------------------------------------------------------------------------
% Subfunctions
%--------------------------------------------------------------------------
% local_resolve_group_index
%--------------------------------------------------------------------------
function [group, groupIdx] = local_resolve_group_index(SBSigSuite, varargin)
groupIdx = []; %#ok<NASGU>
msg = '';

if (~ischar(varargin{1}) && ~isnumeric(varargin{1})) || isempty(varargin{1})
    error(message('sigbldr_api:signalbuilder:stringOrNumericGroup'));
end
group = varargin{1};

grpCnt = SBSigSuite.NumGroups;

if ischar(group)
    allNames = {SBSigSuite.Groups.Name};
    groupIdx = find(strcmp(group, allNames));
    
    if isempty(groupIdx)
        msg = getString(message('sigbldr_api:signalbuilder:NoGroupExists',group));
    end
    
    if length(groupIdx) > 1
        msg = getString(message('sigbldr_api:signalbuilder:GroupNotUnique',group));
    end
else
    if islogical(group)
        groupIdx = find(group);
    else
        groupIdx = group;
    end
    
    if any(groupIdx < 1)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
    end
    
    if any(groupIdx > grpCnt)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
    end
end

if ~isempty(msg)
    ME = MException('sigbldr_api:signalbuilder:invalidSignalOrGroupIndex', '''%s''', msg);
    throw(ME);
end

end

%--------------------------------------------------------------------------
% local_resolve_signal_group_index
%--------------------------------------------------------------------------
function [signal, group, signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, method, varargin)
groupIdx = []; %#ok<NASGU>
msg = '';

if nargin < 4
    DAStudio.error('Sigbldr:sigbldr:APINeedSignalAndGroupParams', method);
else
    if (~ischar(varargin{1}) && ~isnumeric(varargin{1})) || ...
            isempty(varargin{1})
        error(message('sigbldr_api:signalbuilder:needStringOrNumericSignal'));
    end
    if (~ischar(varargin{2}) && ~isnumeric(varargin{2})) || ...
            isempty(varargin{1})
        error(message('sigbldr_api:signalbuilder:stringOrNumericGroup'));
    end
    signal = varargin{1};
    group = varargin{2};
end

ActiveGroup = SBSigSuite.ActiveGroup;
grpCnt = SBSigSuite.NumGroups;
sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;

if isempty(signal)
    signalIdx = 1:sigCnt;
elseif ischar(signal)
    allNames = {SBSigSuite.Groups(ActiveGroup).Signals.Name};
    signalIdx = find(strcmp(signal, allNames));
    if isempty(signalIdx)
        msg = getString(message('sigbldr_api:signalbuilder:NoSignalExists',signal));
    end
    if length(signalIdx) > 1
        msg = getString(message('sigbldr_api:signalbuilder:SignalNotUnique',signal));
    end
else
    if islogical(signal)
        signalIdx = find(signal);
    else
        signalIdx = signal;
    end
    
    if any(signalIdx < 1)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidSignalIndex'));
    end
    
    if any(signalIdx > sigCnt)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidSignalIndex'));
    end
end
if ~isempty(msg)
    ME = MException('sigbldr_api:signalbuilder:invalidSignalOrGroupIndex', '''%s''', msg);
    throw(ME);
end


if isempty(group)
    groupIdx = 1:grpCnt;
elseif ischar(group)
    allNames = {SBSigSuite.Groups.Name};
    groupIdx = find(strcmp(group, allNames));
    
    if isempty(groupIdx)
        msg = getString(message('sigbldr_api:signalbuilder:NoGroupExists',group));
    end
    
    if length(groupIdx) > 1
        msg = getString(message('sigbldr_api:signalbuilder:GroupNotUnique',group));
    end
else
    if islogical(group)
        groupIdx = find(group);
    else
        groupIdx = group;
    end
    
    if any(groupIdx < 1)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
    end
    
    if any(groupIdx > grpCnt)
        msg = getString(message('sigbldr_api:signalbuilder:InvalidGroupIndex'));
    end
end

if ~isempty(msg)
    ME = MException('sigbldr_api:signalbuilder:invalidSignalOrGroupIndex', '''%s''', msg);
    throw(ME);
end

end
%--------------------------------------------------------------------------
% local_trimDataPoints
%--------------------------------------------------------------------------
function [timeNew, dataNew] = local_trimDataPoints(time, data, numSigs, numGrps)
% delete duplicate points and duplicate end points
        
if iscell(time) && iscell(data)
    % time and data are cell arrays
    for idxSig = numSigs:-1:1
        for idxGrp = numGrps:-1:1
            if numel(time) == numel(data)
                % one time for each signal
                timeOld = time{idxSig,idxGrp};
            else
                % one time per group
                timeOld = time{idxGrp};
            end
            dataOld = data{idxSig,idxGrp};
            if isempty(timeOld) || isempty(dataOld)
                % protect against old blocks with extraneous empty time/data
                timeNew{idxSig,idxGrp} = timeOld;
                dataNew{idxSig,idxGrp} = dataOld;
            else
                [timeNew{idxSig,idxGrp}, dataNew{idxSig,idxGrp}] = remove_unneeded_points(timeOld, dataOld);
            end
        end
    end
elseif iscell(data)
    % time is array and data is cell arrays
    for idxSig = numSigs:-1:1
        for idxGrp = numGrps:-1:1
            timeOld = time;
            dataOld = data{idxSig,idxGrp};
            if isempty(timeOld) || isempty(dataOld)
                % protect against old blocks with extraneous empty time/data
                timeNew{idxSig,idxGrp} = timeOld;
                dataNew{idxSig,idxGrp} = dataOld;
            else
                [timeNew{idxSig,idxGrp}, dataNew{idxSig,idxGrp}] = remove_unneeded_points(timeOld, dataOld);
            end
        end
    end
else
    % time and data are arrays
    if isempty(time) || isempty(data)
        % protect against old blocks with extraneous empty time/data
        timeNew = time;
        dataNew = data;
    else
        [timeNew, dataNew] = remove_unneeded_points(time, data);
    end
end
end
%--------------------------------------------------------------------------
% local_trimDataPointsSS
%--------------------------------------------------------------------------
function sigSuite = local_trimDataPointsSS(sigSuite, grpIdxs)
% delete duplicate points and duplicate end points in SigSuite object
        
for idxGrp = grpIdxs
    group = sigSuite.Groups(idxGrp);
    numSigs = group.NumSignals;
    for idxSig = numSigs:-1:1
        signal = group.Signals(idxSig);
        sigSuite.Groups(idxGrp).Signals(idxSig) = signal.removeUnneededPoints;
    end
end

end
%--------------------------------------------------------------------------
% local_remove_groups
%--------------------------------------------------------------------------
function local_remove_groups(blockH, SBSigSuite, groupIdx, grpCnt, removeGroups)
% remove groups specified by groupIdx to be removed in SBSigSuite

if isequal(groupIdx, 1:grpCnt)
    warning(message('sigbldr_api:signalbuilder:removeALLGroupsAndALLSignals')); 
    removeGroups = groupIdx(2:end);
end

if isempty(removeGroups)
    % Return when groups to be removed are empty.
    return;
end

% GUI Operations:
%----------------
% Force open the GUI if needed
forceOpen = false;
figH = get_param(blockH, 'UserData');
if isempty(figH) || ~ishghandle(figH, 'figure')
    forceOpen = true;
    open_system(blockH,'OpenFcn');
    figH = get_param(blockH, 'UserData');
end

groupRemove(SBSigSuite, removeGroups(:));
UD = get(figH, 'UserData');
UD = cant_undo(UD);
UD = group_delete(UD, removeGroups(:)');
%group_delete pushes the updated UD in the figure.
%Therefore refreshGroupAnnotation will correctly update the
%mask icon
refreshGroupAnnotation(blockH);

% Close the GUI if it was forced open
if(forceOpen)
    close_internal(UD);
end

end

%--------------------------------------------------------------------------
% local_set_group_data
%--------------------------------------------------------------------------
function local_set_group_data(blockH, SBSigSuite, time, data, signalIdx, groupIdx)

% if needed, delete duplicate points and duplicate end points
numSig = length(signalIdx);
numGrp = length(groupIdx);

[timeNew, dataNew] = local_trimDataPoints(time, data, numSig, numGrp);

% set signals or groups to new values.
groupSignalSet(SBSigSuite, signalIdx, groupIdx, timeNew, dataNew);

sigCnt = length(signalIdx);

% Get the existing signal data
figH = get_param(blockH, 'UserData');
if ~isempty(figH) && ishghandle(figH, 'figure')
    guiOpen = 1;
    UD = get(figH, 'UserData');
    %Get SIGNAL visibility
    visibility = get_group_visibility(UD);
    % create model and/or add signal builder block to model
    apiData = create_gui_data(SBSigSuite,visibility);
    UD.dataSet = apiData.dataSet;
    activeIdx = UD.current.dataSetIdx;
    UD = update_time_range(UD, SBSigSuite,groupIdx,guiOpen);
    UD.common.dirtyFlag = 1;
else
    guiOpen = 0;
    % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
    % instead use the post-compile filter activeVariants() - g2603134
    fromWsH = find_system(blockH, 'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,... % look only inside active choice of VSS
        'BlockType', 'FromWorkspace');
    savedUD = get_param(fromWsH, 'SigBuilderData');
    %Get signal visibility
    visibility = get_group_visibility(savedUD);
    % create model and/or add signal builder block to model
    create_gui_data(SBSigSuite,visibility);
    savedUD = update_time_range(savedUD, SBSigSuite,groupIdx,guiOpen);
    if savedUD.common.dispMode
        savedUD.common.dispTime = [savedUD.common.minTime,savedUD.common.maxTime];
    end
    activeIdx = savedUD.dataSetIdx;
end

if any(groupIdx == activeIdx)
    activeDataCol = groupIdx == activeIdx;
    ActiveGroup = groupIdx(activeDataCol);
else
    
    ActiveGroup = [];
end

if guiOpen
    % Apply the active data if it exists
    if ~isempty(ActiveGroup)
        for idx = 1:sigCnt
            sigIdx = signalIdx(idx);
            if ~isempty(UD.channels(sigIdx).lineH)
                axIdx = UD.channels(sigIdx).axesInd;
                ptime = SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).XData;
                pdata = SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).YData;
                UD = apply_new_channel_data(UD, sigIdx, ptime, pdata, 1);
                UD = rescale_axes_to_fit_data(UD, axIdx, sigIdx, false);
            end
        end
    end
    UD.sbobj = SBSigSuite;
    UD = cant_undo(UD);
    set(UD.dialog, 'UserData', UD) % Push changes before calling vnv_manager
else  % if GUI is closed
    
    savedUD.sbobj = SBSigSuite;
    set_param(fromWsH, 'SigBuilderData', savedUD);
end
end

%--------------------------------------------------------------------------
% local_validate_dataset_number_elements
%--------------------------------------------------------------------------
function local_validate_dataset_number_elements(numElemDs, numSigGrp, Name)
% check to see if number of dataset elements matches the number of signals in 
% the block per group

% check number of elements is equal to number of signal in sigbldr group
if (numElemDs ~= numSigGrp)
    error(message('sigbldr_api:signalbuilder:DatasetNumElements', Name));
end
end
%--------------------------------------------------------------------------
% local_validate_dataset_elements
%--------------------------------------------------------------------------
function local_validate_dataset_elements(ts, index)
% check to see if dataset elements are valid

% check all element are ML timeseries
if ~isa(ts,'timeseries')
    error(message('sigbldr_api:signalbuilder:NotTimeseries', index));
end

% check for empty data or empty time
if (isempty(ts.Data) || isempty(ts.Time))
    error(message('sigbldr_api:signalbuilder:appendMethod')); 
end

% check data type is double
if ~isa(ts.Data,'double')
    error(message('sigbldr_api:signalbuilder:NotDouble', index));
end

% check size of data in timeseries
if ~isvector(ts.Data)
    error(message('sigbldr_api:signalbuilder:NotVector', index)); 
end
end
