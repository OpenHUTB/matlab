classdef SSEClient<handle

    properties(Hidden,Access=private)
        instanceID;
        artifactLocation;
        allReaderIDs;
        allWriterIDs;
        isRunning;
    end

    methods
        function obj=SSEClient(actorID)

            errMsg=message(...
            'ssm:sseclient:UnrecognizedConstructorArgument',...
            actorID);
            assert(isa(actorID,'char')||isa(actorID,'string'),...
            errMsg);


            obj.instanceID=actorID;
            obj.allReaderIDs=[];
            obj.allWriterIDs=[];
            obj.isRunning=false;
        end
        function delete(obj)
            if obj.isRunning

                for i=obj.allReaderIDs
                    ssm.SSEService.unregisterScenarioReader(...
                    obj.instanceID,i);
                end
                for i=obj.allWriterIDs
                    ssm.SSEService.unregisterScenarioWriter(...
                    obj.instanceID,i);
                end


                ssm.SSEService.terminate(obj.instanceID);
            end
        end
    end

    methods(Static)

        function uploadScenario(scenario)
            try
                ssm.SSEService.uploadScenario(scenario.getStruct);
            catch
                error(message(...
                'ssm:mcosMessages:ScenarioUploadError'));
            end
        end
        function cleanupScenario()
            try
                ssm.SSEService.cleanupScenario();
            catch
                error(message(...
                'ssm:mcosMessages:ScenarioUploadError'));
            end
        end
    end

    methods(Static,Access=private)
        function ret=generateNewHandleInstanceID()
            persistent num;
            if isempty(num)
                num=uint32(0);
            end
            num=num+1;
            ret=num;
        end
    end

    methods

        function readerID=registerQuery(obj,query)
            errMsg=message(...
            'ssm:mcosMessages:ReaderRegistrationQueryError');
            assert(isa(query,'string')||isa(query,'char'),errMsg);
            readerID=ssm.SSEService.registerScenarioReader(...
            obj.instanceID,query);
            obj.allReaderIDs(end+1)=readerID;


            obj.isRunning=true;
        end


        function writerID=registerWriter(obj,varargin)
            nVarargs=length(varargin);
            IC=struct();
            if nVarargs==0
                IC=struct();
            elseif nVarargs==1
                IC=varargin{1};
            else
                matlab.system.internal.error(...
                'ssm:mcosMessages:IncorrectArgumentNum',...
                'registerScenarioWriter');
            end
            writerID=ssm.SSEService.registerScenarioWriter(...
            obj.instanceID,IC);
            obj.allWriterIDs(end+1)=writerID;


            obj.isRunning=true;
        end


        function actors=query(obj,readerID,varargin)
            response=ssm.SSEService.readScenarioState(...
            obj.instanceID,readerID,varargin);
            actors=cell(size(response));
            for i=1:length(response)
                actors{i}=ssm.Actor('vehicle',response(i));
            end
        end


        function write(obj,writerID,varargin)
            if length(varargin)==1
                errMsg=message(...
                'ssm:mcosMessages:WriteErrorExpectingActor');
                assert(isa(varargin{1},'ssm.Actor'),errMsg);
                ssm.SSEService.writeScenarioState(...
                obj.instanceID,writerID,actor.getStruct);
            else
                errMsg=message(...
                'ssm:mcosMessages:NameValuePairExpected');
                assert(mod(length(varargin),2)==0,errMsg);
                data=struct();
                for i=1:2:length(varargin)
                    if strcmp(varargin{i},'pose')
                        value=ssm.Actor.createPoseStructFromMatrix(varargin{i+1});
                    elseif strcmp(varargin{i},'velocity')||strcmp(varargin{i},'angular_velocity')
                        value=ssm.Actor.createVelocityStructFromArray(varargin{i+1});
                    elseif strcmp(varargin{i},'wheels')
                        value=ssm.Actor.createWheelsStructFromStruct(varargin{i+1});
                    else
                        value=varargin{i+1};
                    end
                    data.(varargin{i})=value;
                end
                ssm.SSEService.writeScenarioState(...
                obj.instanceID,writerID,data);
            end
        end


        function[eventEnums,eventIDs,n]=getActionEvents(obj)
            [eventEnums,eventIDs]=ssm.SSEService.getActionEvents(...
            obj.instanceID);
            n=length(eventIDs);
        end
        function action=getLaneChangeActionEvent(obj,eventID)
            action=ssm.SSEService.getLaneChangeActionEvent(...
            obj.instanceID,eventID);
        end
        function action=getSpeedActionEvent(obj,eventID)
            action=ssm.SSEService.getSpeedActionEvent(...
            obj.instanceID,eventID);
        end
        function action=getPathActionEvent(obj,eventID)
            action=ssm.SSEService.getPathActionEvent(...
            obj.instanceID,eventID);
        end
        function action=getPositionActionEvent(obj,eventID)
            action=ssm.SSEService.getPositionActionEvent(...
            obj.instanceID,eventID);
        end


        function unregister(obj,clientID)
            if max(ismember(obj.allReaderIDs,clientID))
                ssm.SSEService.unregisterScenarioReader(...
                obj.instanceID,clientID);
                obj.allReaderIDs(obj.allReaderIDs==clientID)=[];
            elseif max(ismember(obj.allWriterIDs,clientID))
                ssm.SSEService.unregisterScenarioWriter(...
                obj.instanceID,clientID);
                obj.allWriterIDs(obj.allWriterIDs==clientID)=[];
            else
                error(message('ssm:mcosMessages:IdNotRegistered',...
                clientID))
            end
        end
    end
end
