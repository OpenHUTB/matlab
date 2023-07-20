classdef (Sealed) Channel < matlabshared.asyncio.internal.Channel
    % A sub-class of an matlabshared.asyncio.internal.Channel used for OPC UA client communication.
    %
    %   This class is responsible for managing the KeepAlive messaging to connected OPC UA Servers, as well as data
    %   transfer from the OPC UA Device to MATLAB.

    % Copyright 2015-2021 The MathWorks, Inc.
    % Developed by Opti-Num Solutions (Pty) Ltd
    
    %% Lifetime
    methods
        function obj = Channel(varargin)
            
            % For Compiler deployment, we need to specify the plugin folder this way. 
            opcRoot = toolboxdir('icomm/opc');
            pluginDir = fullfile(opcRoot, 'opc', 'bin', computer('arch'));
            deviceName = fullfile(pluginDir, 'opcuadevice');
            converterName = fullfile(pluginDir, 'opcuamlconverter');
            obj@matlabshared.asyncio.internal.Channel(deviceName, converterName, varargin{:});
            
            % To allow for non-block I/O.
            obj.InputStream.Timeout = Inf;
            obj.OutputStream.Timeout = Inf;
            % Allow data events
            obj.DataEventsDisabled = false;
        end
        %% Get/Set
        function [errors, results, continuationPoint]=getBrowseResults(obj)
            %getBrowseResults Translate browse results from Device to MATLAB.
            %   No MATLAB-specific changes required.
            errors = obj.BrowseResults.Success;
            results = obj.BrowseResults.BrowseResults;
            continuationPoint = obj.BrowseResults.ContinuationPoint;
        end
        
        function [errors, results]=getReadResults(obj)
            %getReadResults Translate read results from Device to MATLAB.
            %   MATLAB-specific translation: Use the ServerTimeStamp for TimeStamp.
            errors = obj.ReadResults.Success;
            propertyValue=obj.ReadResults.Results;
            if numel(propertyValue)==0
                results = struct('Value', [], 'TimeStamp', [], 'Quality', []);
                results(1)=[];
            else
                results(numel(propertyValue)) = struct('Value', [], 'TimeStamp', [], 'Quality', []);
                for n=1:numel(propertyValue)
                    % The returned value is translated when a Node is available.
                    results(n).Value=propertyValue(n).Value;
                    results(n).TimeStamp = propertyValue(n).ServerTimeStamp;
                    results(n).Quality = propertyValue(n).Quality;
                end
            end
        end
        
        function [errors, results]=getWriteResults(obj)
            %getWriteResults Translate write results from Device to MATLAB.
            %   No MATLAB-specific changes required.
            errors = obj.OperationalResults.Success;
            propertyValue=obj.OperationalResults.StatusResults;
            % If writing to one node and there is no other error then use that value
            if numel(propertyValue)==1 && errors == 0
                errors = propertyValue;
            end
            results = propertyValue;
        end
        
        function errors=getSuccess(obj)
            %getSuccess Return success flag from Device to MATLAB
            errors = obj.OperationalResults.Success;
        end

        function [errors, results]=getHistoryReadResults(obj)
            %getHistoryReadResults Return HistoryReadResults structure from Device to MATLAB.
            errors = obj.HistoryReadResults.Status;
            propertyValue=obj.HistoryReadResults.Results;
            if numel(propertyValue) == 0
                results = struct('NodeId', [], 'NodeStatus', [], 'Value', [], 'Quality', [], 'SourceTimestamp', [], 'ServerTimestamp', []);
                results(1)=[];
            else
                % Do not translate yet; leave that up to the client, which has the Node information.
                results = propertyValue;
            end
        end
    end
end

