classdef InteractionObjectSender<handle
    properties(SetAccess=protected)
        requestSubscription=[];
        toolEventSubscription=[];
        jsonPath=[];
        requestChannel='/sltraining/slbridge/courseModelRequest';
        dataChannel='/sltraining/slbridge/courseModelData';
        toolEventChannel='/sltraining/slbridge/toolEventCodes';
    end

    properties(Constant)
        TEST_SIMULINK_CONTENT_JSON=fullfile(fileparts(mfilename('fullpath')),'resource','simulinkCourseModelData.json');
        TEST_STATEFLOW_CONTENT_JSON=fullfile(fileparts(mfilename('fullpath')),'resource','stateflowCourseModelData.json');
    end

    methods
        function obj=InteractionObjectSender(varargin)
            if isempty(varargin)
                obj.jsonPath=InteractionObjectSender.TEST_SIMULINK_CONTENT_JSON;
            else
                obj.jsonPath=InteractionObjectSender.getJSONFilePath(varargin{1});
            end
            obj.requestSubscription=message.subscribe(obj.requestChannel,@(msg)obj.handleCourseModelRequest(msg));
            obj.toolEventSubscription=message.subscribe(obj.toolEventChannel,@(msg)obj.handleToolEventCode(msg));
        end

        function delete(obj)
            obj.cleanup();
        end

        function cleanup(obj)
            if~isempty(obj.requestSubscription)
                message.unsubscribe(obj.requestSubscription);
                obj.requestSubscription=[];
            end

            if~isempty(obj.toolEventSubscription)
                message.unsubscribe(obj.toolEventSubscription);
                obj.toolEventSubscription=[];
            end
        end

        function handleCourseModelRequest(obj,msg)
            obj.sendInteractionObj();
        end

        function handleToolEventCode(obj,msg)

        end

        function sendInteractionObj(obj)

            f=fileread(obj.jsonPath);
            jsonObj=jsondecode(f);
            message.publish(obj.dataChannel,jsonObj);
        end
    end

    methods(Static,Access=private)
        function jsonPath=getJSONFilePath(rawPath)
            if endsWith(rawPath,'.json')
                jsonPath=rawPath;
            elseif strcmp(rawPath,learning.simulink.preferences.slacademyprefs.SimulinkOnrampCourseCode)
                jsonPath=InteractionObjectSender.TEST_SIMULINK_CONTENT_JSON;
            elseif strcmp(rawPath,learning.simulink.preferences.slacademyprefs.StateflowOnrampCourseCode)
                jsonPath=InteractionObjectSender.TEST_STATEFLOW_CONTENT_JSON;
            else
                jsonPath=InteractionObjectSender.TEST_SIMULINK_CONTENT_JSON;
            end
        end
    end

    methods(Static,Access=public)
        function dataSrc=getTestDataSrcStringFromJSONFile(varargin)
            if isempty(varargin)
                jsonPath=InteractionObjectSender.TEST_SIMULINK_CONTENT_JSON;
            else
                jsonPath=InteractionObjectSender.getJSONFilePath(varargin{1});
            end
            f=fileread(jsonPath);
            jsonObj=jsondecode(f);
            assert(~isempty(jsonObj)&&isfield(jsonObj,'id'));
            dataSrc=jsonObj.id;
        end
    end


end
