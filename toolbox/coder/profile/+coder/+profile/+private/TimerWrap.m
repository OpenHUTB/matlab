classdef TimerWrap < handle
%TIMERWRAP wrapper around a TFL table containing a timer definition

%   Copyright 2012-2019 The MathWorks, Inc.
    
    properties(Access=private)
        TflTableTimer;
        
        % List of timers that may be used by a target that without requiring and
        % Embedded Coder license
        NoTflTimers = {'XpcTimer', 'HXpcTimer', 'Timer64BitNoTfl'...
            'slrealtime.internal.ProfileTimer'}; 
        
        CoderProfileTimer;
    end
    
    methods(Access=private, Static=true)
    
        function validateTflTimer(tflTimerTable)

            % Check for a valid TFL specification
            tflValid = false;
            numEntries = length(tflTimerTable.AllEntries);
            if numEntries == 1
                fcn_entry = tflTimerTable.AllEntries(1);
                key = fcn_entry.Key;
                conceptualArgs = fcn_entry.ConceptualArgs;
                impl = fcn_entry.Implementation;
                tflValid = ...
                    strcmp(key, 'code_profile_read_timer') ...
                    && ~isempty(impl) ...
                    && isempty(impl.Arguments) ...
                    && isequal(conceptualArgs, impl.Return) ...
                    && strcmp(impl.Return.IOType, 'RTW_IO_OUTPUT');
            end
            
            if ~tflValid
                DAStudio.error...
                    ('CoderProfile:ExecutionTime:InvalidCrlTimer')
            end
            
            ticksPerSecond = fcn_entry.EntryInfo.TicksPerSecond;
            if ~isscalar(ticksPerSecond) ...
                    || ticksPerSecond < 0
                DAStudio.error...
                    ('CoderProfile:ExecutionTime:InvalidCrlTimerTicksPerSecond')
            end
            
            argType = impl.Return.Type;
            validWordLengths = [8 16 32 64];
            
            if isa(argType, 'embedded.complextype') || ...
                    ~strcmp(argType.Signedness, 'Unsigned') ...
                    || ~any(argType.WordLength==validWordLengths) ...
                    || ~argType.FractionLength==0
                DAStudio.error...
                    ('CoderProfile:ExecutionTime:InvalidTimerDataTypeCrl');
            end
                
        end
        
        function hLib = convertOldTimerToTfl(oldTimer)               
            
            key = 'code_profile_read_timer';
            
            oldFullHeader = oldTimer.HeaderFile;
            if ~isempty(oldFullHeader)
                [oldHeaderFilePath,f,e] = fileparts(oldFullHeader);
                oldHeaderFile=[f e];
            else
                oldHeaderFilePath='';
                oldHeaderFile = '';
            end
            oldFullSource=oldTimer.SourceFile;
            if ~isempty(oldFullSource)
                [oldSourceFilePath,f,e] = fileparts(oldFullSource);
                oldSourceFile=[f e];
            else
                oldSourceFilePath='';
                oldSourceFile='';
            end
            
            implName = oldTimer.ReadTimerExpression;
            implName = strtrim(implName);
            [matchstart, matchend] = regexp(implName, '\(\s*\)\s*$');
            if ~isempty(matchstart)
                % Strip the trailing ()
                implName(matchstart:matchend) = '';
                implType = 'FCN_IMPL_FUNCT';
            else
                implType = 'FCN_IMPL_MACRO';
            end            
            
           % convert defines to compiler flags
           oldDefines = oldTimer.Defines;
           for i=1:length(oldDefines)
               % The compiler must support -D
               oldDefines{i} = sprintf('-D%s', oldDefines{i});
           end
           compileFlags = oldDefines;
            
            fcn_entry = RTW.TflCFunctionEntry;
            fcn_entry.setTflCFunctionEntryParameters( ...
                'Key',                      key, ...
                'ImplementationName',       implName, ...
                'ImplType',                 implType, ...
                'ImplementationHeaderFile', oldHeaderFile, ...
                'AdditionalCompileFlags',   compileFlags, ...
                'ImplementationSourceFile', oldSourceFile, ...
                'AdditionalLinkFlags',      oldTimer.LinkFlags);

            if ~isempty(oldHeaderFilePath)
                addAdditionalIncludePath(fcn_entry, oldHeaderFilePath);
            end
            if ~isempty(oldSourceFilePath)
                addAdditionalSourcePath(fcn_entry, oldSourceFilePath);
            end

            hLib = RTW.TflTable;
            arg = hLib.getTflArgFromString('y1',oldTimer.TimerDataType);
            arg.IOType = 'RTW_IO_OUTPUT';
            fcn_entry.addConceptualArg(arg);

            fcn_entry.copyConceptualArgsToImplementation();
            if strcmp(oldTimer.CountDirection, 'up')
                fcn_entry.EntryInfo.CountDirection = 'RTW_TIMER_UP';
            else
                assert(strcmp(oldTimer.CountDirection, 'down'), 'Must be up or down');
                fcn_entry.EntryInfo.CountDirection = 'RTW_TIMER_DOWN';
            end
            if ~isempty(oldTimer.TicksPerSecond)
                fcn_entry.EntryInfo.TicksPerSecond = oldTimer.TicksPerSecond;
            end

            hLib.addEntry( fcn_entry );

        end
    
    end
    
    methods(Access=public)
        
        
        function isXpc = getIsXpcMode(this)
            % Handle xPC Target as a special case
            timerClass = lower(class(this.CoderProfileTimer));
            isXpc = contains(timerClass, 'xpctimer') || contains(timerClass, 'slrealtime');
        end
        
        function tps = getTicksPerSecond(this)
            if ~isempty(this.TflTableTimer)
                tps = this.TflTableTimer.AllEntries(1).EntryInfo.TicksPerSecond;
                if tps <= 0
                    tps = [];
                end
            else
                tps = this.CoderProfileTimer.getTicksPerSecond;
            end
        end

        function incPaths = getTimerIncludePaths(this)
            if ~isempty(this.TflTableTimer)
                addIncPaths = this.TflTableTimer.AllEntries(1).AdditionalIncludePaths;
                incPath = this.TflTableTimer.AllEntries(1).Implementation.HeaderPath;
                incPaths = [{incPath} addIncPaths(:)'];
            else
                incPaths = {fileparts(this.CoderProfileTimer.HeaderFile)};
            end
            % discard empty elements
            emptyIdx = false(size(incPaths));
            for i=1:length(emptyIdx)
                emptyIdx(i) = isempty(incPaths{i});
            end
            incPaths = incPaths(~emptyIdx);
        end

        function srcPaths = getSourcePaths(this)
            if ~isempty(this.TflTableTimer)
                addSrcPaths = this.TflTableTimer.AllEntries(1).AdditionalSourcePaths;
                srcPath = this.TflTableTimer.AllEntries(1).Implementation.SourcePath;
                srcPaths = [{srcPath} addSrcPaths(:)'];
            else
                srcPaths = {fileparts(this.CoderProfileTimer.SourceFile)};
            end
            % discard empty elements
            emptyIdx = false(size(srcPaths));
            for i=1:length(emptyIdx)
                emptyIdx(i) = isempty(srcPaths{i});
            end
            srcPaths = srcPaths(~emptyIdx);
        end

        function flags = getCompileFlags(this)
            if ~isempty(this.TflTableTimer)
                flags = this.TflTableTimer.AllEntries(1).AdditionalCompileFlags;
            else
                % Not supported for non-CRL timers
                flags = {};
            end
        end
        
        function linkFlags = getLinkFlags(this)
            if ~isempty(this.TflTableTimer)
                linkFlags = this.TflTableTimer.AllEntries(1).AdditionalLinkFlags;
            else 
                linkFlags = this.CoderProfileTimer.LinkFlags;
            end
        end

        function fileName = getTimerSource(this)
            if ~isempty(this.TflTableTimer)
                fileName = this.TflTableTimer.AllEntries(1).Implementation.SourceFile;
            else
                [~,f,e] = fileparts(this.CoderProfileTimer.SourceFile);
                fileName=[f e];
            end
        end

        function fileName = getTimerHeader(this)
            if ~isempty(this.TflTableTimer)
                fileName = this.TflTableTimer.AllEntries(1).Implementation.HeaderFile;
            else
                [~,f,e] = fileparts(this.CoderProfileTimer.HeaderFile);
                fileName=[f e];
            end
        end

        function fileNames = getTimerAdditionalSources(this)
            if ~isempty(this.TflTableTimer)
                fileNames = this.TflTableTimer.AllEntries(1).AdditionalSourceFiles;
            else
                fileNames = cell(0, 1);
            end
        end
        
        function fileNames = getTimerAdditionalHeaders(this)
            if ~isempty(this.TflTableTimer)
                fileNames = this.TflTableTimer.AllEntries(1).AdditionalHeaderFiles;
            else
                fileNames = cell(0, 1);
            end
        end
        
        function expr = getReadTimerExpression(this)
            if ~isempty(this.TflTableTimer)
                implName = this.TflTableTimer.AllEntries(1).Implementation.Name;
                implType = this.TflTableTimer.AllEntries(1).ImplType;
                if strcmp(implType, 'FCN_IMPL_MACRO')
                    expr=implName;
                else
                    assert(strcmp(implType, 'FCN_IMPL_FUNCT'), ...
                           'Bad implementation type %s', implType);
                    expr = sprintf('%s()', implName);
                end
            else
                expr = this.CoderProfileTimer.ReadTimerExpression;
            end
        end
        
        function direction = getCountDirection(this) 
            if ~isempty(this.TflTableTimer)
                countDirn = this.TflTableTimer.AllEntries(1).EntryInfo.CountDirection;
                if strcmp(countDirn, 'RTW_TIMER_UP')
                    direction = 'up';
                else
                    assert(strcmp(countDirn, 'RTW_TIMER_DOWN'), 'invalid count direction');
                    direction = 'down';
                end
            else
                direction = this.CoderProfileTimer.CountDirection;
            end
        end
        
        function cType = getTimerCType(this)
            type = this.getTimerType;
            cType = sprintf('%s%s', type, '_T');
        end
        
        function wordLen = getTimerWordLength(this)
            if isempty(this.TflTableTimer)
                assert(strcmp(this.getTimerType, 'uint64'),...
                       'Limited timer data type support when not using TFL/CRL');
                wordLen = 64;
            else
                wordLen = this.getTimerNumericType.WordLength;
            end
        end
        
        function numericType = getTimerNumericType(this)
            assert(~isempty(this.TflTableTimer), 'Only supported for TFL timers');
            numericType = this.TflTableTimer.AllEntries(1).ConceptualArgs(1).Type;
        end
        
        function type = getTimerType(this)
            if ~isempty(this.TflTableTimer)
                numericType = this.TflTableTimer.AllEntries(1).ConceptualArgs(1).Type;
                wordLenStr = sprintf('%d', numericType.WordLength);
                type = sprintf('uint%s', wordLenStr);
            else
                type = this.CoderProfileTimer.TimerDataType;
            end
        end
        
        function this = TimerWrap(timer)
            
            if isa(timer, 'coder.profile.Timer')
                timerClass = class(timer);
                if any(strcmp(timerClass, this.NoTflTimers))
                    % We have timer that does not require an Embedded Coder license
                    this.CoderProfileTimer = timer;
                else
                    tflTimer = coder.profile.private.TimerWrap.convertOldTimerToTfl(timer);
                    coder.profile.private.TimerWrap.validateTflTimer(tflTimer);
                    this.TflTableTimer = tflTimer;
                end
            else
                assert(isa(timer, 'RTW.TflTable'), 'Must be an RTW.TflTable object');
                coder.profile.private.TimerWrap.validateTflTimer(timer);
                this.TflTableTimer = timer;
            end
        end
        
    end
end

