classdef ExecProfInstrumenter < internal.cxxfe.FrontEndHandler
    % The class ExecProfInstrumenter allows performing execution profile
    % instrumentation within the C front end

    %  Copyright 2013-2022 The MathWorks, Inc.

    properties (Access = private)
        ComponentRegistry;
        TraceInfo;
        WordSize;
        FrontEndOptions;
        Callback;
        InstrumentWithinFunctions;
        CustomFileList;
    end

    methods
        function afterParsing(this, ilPtr, ~, origFileName, ~)
            % 2nd parameter: FEOpts
            isEmptyTraceInfo = ~this.TraceInfo.isKey(origFileName) || isempty(this.TraceInfo(origFileName));
            pstestCustomFile = false;
            if ~isEmptyTraceInfo
                traceInfo = this.TraceInfo(origFileName);
                if isstruct(traceInfo) && isfield(traceInfo, 'Group')
                    isEmptyTraceInfo = true;
                    pstestCustomFile = true;
                end
            end
            allowEmptySIDs = any(strcmp(origFileName, this.CustomFileList)) || pstestCustomFile;
            if isEmptyTraceInfo && ~allowEmptySIDs
                return;
            end
            if isEmptyTraceInfo
                traceInfo = struct('CallSiteName', {}, 'CallSiteLine', {}, 'CallSiteSID', {});
            else
                traceInfo = this.TraceInfo(origFileName);
            end
            coder.profile.private.exec_prof_mex(...
                ilPtr, ...
                this.ComponentRegistry,...
                traceInfo, ...
                this.WordSize, ...
                this.Callback, ...
                allowEmptySIDs, ...
                this.InstrumentWithinFunctions);
        end

        function this = ExecProfInstrumenter(componentRegistry, traceInfo, ...
                            wordSize, frontEndOptions, callback, ...
                            instrumentWithinFunctions, customFileList)
            this.ComponentRegistry = componentRegistry;
            this.TraceInfo = traceInfo;
            this.WordSize = wordSize;
            this.FrontEndOptions = frontEndOptions;
            this.Callback = callback;
            this.InstrumentWithinFunctions = instrumentWithinFunctions;
            this.CustomFileList = customFileList;
        end
    end
end

% LocalWords:  lang WORDSIZES EDG
