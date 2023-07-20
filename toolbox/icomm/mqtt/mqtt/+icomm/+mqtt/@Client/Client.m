classdef Client<handle











    properties(SetAccess=private,GetAccess=public,Transient=true)
BrokerAddress
Port
ClientID
Timeout
KeepAliveDuration
Subscriptions
    end

    properties(Access=private,Transient=true)
MQTTClient
SubscriptionObj
CARootCertificate
ClientCertificate
ClientKey
SSLPassword
    end

    properties(Dependent=true,SetAccess=private,Transient=true)
Connected
    end

    methods
        function obj=Client(BrokerAddress,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(1,23);


            [parsedInputs,portDefault]=mqttParseInputs(BrokerAddress,varargin);


            obj.BrokerAddress=string(parsedInputs.BrokerAddress);
            obj.ClientID=string(parsedInputs.ClientID);
            obj.Port=parsedInputs.Port;
            obj.Timeout=parsedInputs.Timeout;
            obj.KeepAliveDuration=parsedInputs.KeepAliveDuration;

            if isa(obj.Timeout,'duration')
                obj.Timeout=seconds(obj.Timeout);
            end
            if isa(obj.KeepAliveDuration,'duration')
                obj.KeepAliveDuration=seconds(obj.KeepAliveDuration);
            end






            Username=parsedInputs.Username;
            Password=parsedInputs.Password;


            if isempty(char(Username))&&~isempty(char(Password))
                error(message('icomm_mqtt:MQTTClient:MissingUsername'));
            end


            if~isempty(char(Username))||startsWith(obj.BrokerAddress,'ssl://')||startsWith(obj.BrokerAddress,'wss://')


                if portDefault
                    obj.Port=8883;
                else


                    if obj.Port==1883
                        warnState=warning('backtrace','off');
                        warning(message('icomm_mqtt:MQTTClient:UsingUnsecurePortToConnect'));
                        warning(warnState);
                    end
                end
            end



            initOptions=[];

            splittedBrokerAddress=regexp(obj.BrokerAddress,':','split');







            if sum(isstrprop(splittedBrokerAddress{end},'digit'))==length(splittedBrokerAddress{end})
                initOptions.BrokerAddress=obj.BrokerAddress;
            else
                initOptions.BrokerAddress=obj.BrokerAddress+":"+string(obj.Port);
            end






            initOptions.ClientID=obj.ClientID;


            obj.SubscriptionObj=[];
            obj.Subscriptions=table('Size',[0,3],...
            'VariableTypes',{'string','int8','string'},...
            'VariableNames',{'Topic','QualityOfService','Callback'});


            openOptions=[];
            openOptions.Username=Username;
            openOptions.Password=Password;
            openOptions.Timeout=int32(obj.Timeout);
            openOptions.KeepAlive=int32(obj.KeepAliveDuration);
            openOptions.SSLOptions=int32(0);
            openOptions.PostConnectionVerify=int32(1);
            openOptions.CAFile="";
            openOptions.ClientCertificate="";
            openOptions.ClientKeyFile="";
            openOptions.SSLPassword="";


            if(startsWith(obj.BrokerAddress,'ssl://')||startsWith(obj.BrokerAddress,'wss://'))

                openOptions.SSLOptions=int32(1);
                openOptions.PostConnectionVerify=int32(parsedInputs.PostConnectionVerify);
                openOptions.CAFile=parsedInputs.CARootCertificate;
                openOptions.ClientCertificate=parsedInputs.ClientCertificate;
                openOptions.ClientKeyFile=parsedInputs.ClientKey;
                openOptions.SSLPassword=parsedInputs.SSLPassword;



                if~isempty(char(openOptions.ClientCertificate))&&isempty(char(openOptions.ClientKeyFile))
                    error(message('icomm_mqtt:MQTTClient:MissingClientKey'));
                end


                if~isempty(char(openOptions.SSLPassword))&&isempty(char(openOptions.ClientCertificate))
                    error(message('icomm_mqtt:MQTTClient:MissingClientCrt'));
                end


                if~isempty(char(openOptions.SSLPassword))&&isempty(char(openOptions.ClientKeyFile))
                    error(message('icomm_mqtt:MQTTClient:MissingClientKey'));
                end
            end


            DevicePath=fullfile(toolboxdir('icomm'),'mqtt','mqtt','bin',computer('arch'),'mqttdevice');
            ConverterPath=fullfile(toolboxdir('icomm'),'mqtt','mqtt','bin',computer('arch'),'mqttconverter');
            obj.MQTTClient=matlabshared.asyncio.internal.Channel(DevicePath,ConverterPath,Options=initOptions);


            obj.MQTTClient.DataEventsDisabled=true;


            obj.MQTTClient.open(openOptions);


            while(~obj.Connected)


                drawnow();
                pause(1e-3);

                switch obj.MQTTClient.connectCallbackResponseCode
                case icomm.mqtt.Utility.MW_MQTTASYNC_RESPONSE_CODE_PLACEHOLDER



                case icomm.mqtt.Utility.MQTTASYNC_SUCCESS

                    break;

                case icomm.mqtt.Utility.MQTTASYNC_FAILURE


                    if contains(obj.MQTTClient.connectCallbackMsg,'connect timeout')
                        error(message('icomm_mqtt:MQTTClient:ConnectionTimeout',BrokerAddress));
                    end


                    error(message('icomm_mqtt:MQTTClient:ConnectionAttemptFail',BrokerAddress));

                case{icomm.mqtt.Utility.MQTTASYNC_PERSISTENCE_ERROR,...
                    icomm.mqtt.Utility.MQTTASYNC_DISCONNECTED,...
                    icomm.mqtt.Utility.MQTTASYNC_MAX_MESSAGES_INFLIGHT,...
                    icomm.mqtt.Utility.MQTTASYNC_BAD_UTF8_STRING,...
                    icomm.mqtt.Utility.MQTTASYNC_NULL_PARAMETER,...
                    icomm.mqtt.Utility.MQTTASYNC_TOPICNAME_TRUNCATED,...
                    icomm.mqtt.Utility.MQTTASYNC_BAD_STRUCTURE,...
                    icomm.mqtt.Utility.MQTTASYNC_BAD_QOS,...
                    icomm.mqtt.Utility.MQTTASYNC_NO_MORE_MSGIDS,...
                    icomm.mqtt.Utility.MQTTASYNC_OPERATION_INCOMPLETE,...
                    icomm.mqtt.Utility.MQTTASYNC_MAX_BUFFERED_MESSAGES,...
                    icomm.mqtt.Utility.MQTTASYNC_SSL_NOT_SUPPORTED,...
                    icomm.mqtt.Utility.MQTTASYNC_BAD_PROTOCOL,...
                    icomm.mqtt.Utility.MQTTASYNC_BAD_MQTT_OPTION,...
                    icomm.mqtt.Utility.MQTTASYNC_WRONG_MQTT_VERSION}

                    error(message('icomm_mqtt:MQTTClient:ConnectionAttemptFail',BrokerAddress));

                otherwise
                    error(message('icomm_mqtt:MQTTClient:ConnectionUnknownError',BrokerAddress));
                end
            end
        end

        function write(obj,topic,msg,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(3,7);


            if(~obj.Connected)
                error(message('icomm_mqtt:MQTTClient:NotConnectedWhenWrite'));
            end


            try
                parsedInputs=mqttWriteParseInputs(topic,msg,varargin);
            catch ME
                throwAsCaller(ME);
            end


            writeOptions=[];
            writeOptions.Topic=parsedInputs.Topic;
            writeOptions.Message=parsedInputs.Message;
            writeOptions.QoS=int32(parsedInputs.QualityOfService);
            writeOptions.Retain=int32(parsedInputs.Retain);
            obj.MQTTClient.execute("publishMessage",writeOptions);


            responseCode=obj.MQTTClient.publishResponseCode;
            if(responseCode~=icomm.mqtt.Utility.MQTTASYNC_SUCCESS)
                error(message('icomm_mqtt:MQTTClient:WriteAttemptFail',topic));
            end
        end

        function Subscriptions=subscribe(obj,topic,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(2,6);


            if(~obj.Connected)
                error(message('icomm_mqtt:MQTTClient:NotConnectedWhenSubscribe'));
            end


            try
                parsedInputs=mqttSubscribeParseInputs(topic,varargin);
            catch ME
                throwAsCaller(ME);
            end


            topic=parsedInputs.Topic;
            QoS=parsedInputs.QualityOfService;
            callback=parsedInputs.Callback;


            if~isempty(find(strcmp(topic,obj.Subscriptions.Topic),1))
                warnState=warning('backtrace','off');
                warning(message('icomm_mqtt:MQTTClient:TopicAlreadySubscribed',topic));
                warning(warnState);
                return;
            end


            newSubscriptionObj=icomm.mqtt.Subscription(obj.MQTTClient,...
            topic,...
            QoS,...
            callback);



            obj.SubscriptionObj=[obj.SubscriptionObj,newSubscriptionObj];


            callbackStr=newSubscriptionObj.Callback;
            if isa(callbackStr,"function_handle")
                callbackStr=func2str(callbackStr);
            end
            obj.Subscriptions=[obj.Subscriptions;
            {newSubscriptionObj.Topic,newSubscriptionObj.QualityOfService,callbackStr}];


            Subscriptions=obj.Subscriptions;
        end

        function unsubscribe(obj,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(1,3);


            if(~obj.Connected)
                error(message('icomm_mqtt:MQTTClient:NotConnectedWhenUnsubscribe'));
            end



            if nargin==1
                for ii=1:length(obj.SubscriptionObj)
                    obj.SubscriptionObj(ii).unsubscribe();
                end
                obj.SubscriptionObj=[];
                obj.Subscriptions(:,:)=[];

                return
            end


            try
                parsedInputs=mqttParseTopicNVInputs(varargin);
            catch ME
                throwAsCaller(ME);
            end



            topicIdxToUnsubscribe=find(strcmp(parsedInputs.Topic,obj.Subscriptions.Topic));
            if isempty(topicIdxToUnsubscribe)
                error(message('icomm_mqtt:MQTTClient:UnsubTopicNotSubscribedYet',parsedInputs.Topic));
            end


            obj.SubscriptionObj(topicIdxToUnsubscribe).unsubscribe();
            obj.SubscriptionObj(topicIdxToUnsubscribe)=[];
            obj.Subscriptions(topicIdxToUnsubscribe,:)=[];
        end

        function messages=read(obj,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(1,3);


            messages=timetable();



            if nargin==1
                for ii=1:length(obj.SubscriptionObj)
                    messages=[messages;read(obj.SubscriptionObj(ii),obj.SubscriptionObj(ii).Topic)];
                end

                return
            end


            try
                parsedInputs=mqttParseTopicNVInputs(varargin);
            catch ME
                throwAsCaller(ME);
            end


            topicIdxToRead=getTopicIdx(obj,parsedInputs.Topic);


            if isempty(topicIdxToRead)
                error(message('icomm_mqtt:MQTTClient:ReadTopicNotSubscribedYet',parsedInputs.Topic));
            end


            messages=read(obj.SubscriptionObj(topicIdxToRead),parsedInputs.Topic);
        end

        function messages=peek(obj,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(1,3);


            messages=timetable();



            if nargin==1
                for ii=1:length(obj.SubscriptionObj)
                    messages=[messages;peek(obj.SubscriptionObj(ii),obj.SubscriptionObj(ii).Topic)];
                end

                return
            end


            try
                parsedInputs=mqttParseTopicNVInputs(varargin);
            catch ME
                throwAsCaller(ME);
            end


            topicIdxToPeek=getTopicIdx(obj,parsedInputs.Topic);


            if isempty(topicIdxToPeek)
                error(message('icomm_mqtt:MQTTClient:PeekTopicNotSubscribedYet',parsedInputs.Topic));
            end


            messages=peek(obj.SubscriptionObj(topicIdxToPeek),parsedInputs.Topic);
        end

        function flush(obj,varargin)



            icomm.mqtt.Utility.checkLicense();


            narginchk(1,3);



            if nargin==1
                for ii=1:length(obj.SubscriptionObj)
                    flush(obj.SubscriptionObj(ii),obj.SubscriptionObj(ii).Topic);
                end

                return
            end


            try
                parsedInputs=mqttParseTopicNVInputs(varargin);
            catch ME
                throwAsCaller(ME);
            end


            topicIdxToFlush=getTopicIdx(obj,parsedInputs.Topic);


            if isempty(topicIdxToFlush)
                error(message('icomm_mqtt:MQTTClient:FlushTopicNotSubscribedYet',parsedInputs.Topic));
            end


            flush(obj.SubscriptionObj(topicIdxToFlush),parsedInputs.Topic);
        end




        function value=get.Connected(obj)
            try
                obj.MQTTClient.execute("isConnected",[])
                value=logical(obj.MQTTClient.isConnected);
            catch
                value=false;
            end
        end
    end

    methods(Static,Hidden=true)

        function topics=getSubscribedTopics(obj)
            topics=obj.Subscriptions.Topic;
        end


        function obj=loadobj(s)
            warnState=warning('backtrace','off');
            warning(message('icomm_mqtt:MQTTClient:UnableToLoad'));
            warning(warnState);
        end
    end

    methods(Hidden=true)

        function delete(obj)
            try
                obj.MQTTClient.close()
            catch

            end
        end
    end

end

function[parsedInputs,portDefault]=mqttParseInputs(BrokerAddress,inputArguments)



    p=inputParser;
    p.CaseSensitive=false;
    p.PartialMatching=true;


    addRequired(p,'BrokerAddress',@(x)validateBrokerAddress(x));

    addParameter(p,'Port',1883,@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'}));
    addParameter(p,'Username',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    addParameter(p,'Password',"",@(x)validateattributes(x,{'char','string'},{}));
    addParameter(p,'ClientID',"",@(x)validateClientID(x));
    addParameter(p,'Timeout',5,@(x)validateTimeout(x));
    addParameter(p,'KeepAliveDuration',60,@(x)validateKeepAliveDuration(x));
    addParameter(p,'CARootCertificate',"",@(x)validateFile(x));
    addParameter(p,'ClientCertificate',"",@(x)validateFile(x));
    addParameter(p,'ClientKey',"",@(x)validateFile(x));
    addParameter(p,'SSLPassword',"",@(x)validateattributes(x,{'char','string'},{}));




    addParameter(p,'PostConnectionVerify',1,@(x)validateattributes(x,{'numeric'},{'scalar','integer','>=',0,'<=',1}));


    p.parse(BrokerAddress,inputArguments{:});
    parsedInputs=p.Results;


    portDefault=any(strcmpi('Port',p.UsingDefaults));
end

function parsedInputs=mqttWriteParseInputs(topic,msg,inputArguments)



    p=inputParser;
    p.CaseSensitive=false;
    p.PartialMatching=true;


    addRequired(p,'Topic',@(x)validateWriteTopic(x));
    addRequired(p,'Message',@(x)validateattributes(x,{'char','string'},{'scalartext'}));

    addParameter(p,'QualityOfService',0,@(x)validateQualityOfService(x));
    addParameter(p,'Retain',false,@(x)validateattributes(x,{'logical','binary'},{'scalar'}));


    p.parse(topic,msg,inputArguments{:});
    parsedInputs=p.Results;
end

function parsedInputs=mqttSubscribeParseInputs(topic,inputArguments)



    p=inputParser;
    p.CaseSensitive=false;
    p.PartialMatching=true;


    addRequired(p,'Topic',@(x)validateSubscribeTopic(x))

    addParameter(p,'QualityOfService',0,@(x)validateQualityOfService(x));
    addParameter(p,'Callback','',@(x)validateCallback(x));


    p.parse(topic,inputArguments{:});
    parsedInputs=p.Results;
end

function parsedInputs=mqttParseTopicNVInputs(inputArguments)



    p=inputParser;
    p.CaseSensitive=false;
    p.PartialMatching=true;


    addParameter(p,'Topic',"",@(x)validateattributes(x,{'char','string'},{'scalartext'}));


    p.parse(inputArguments{:});
    parsedInputs=p.Results;
end


function validateBrokerAddress(BrokerAddress)

    validateattributes(BrokerAddress,{'char','string'},{'scalartext'});


    connectionProtocol=regexp(BrokerAddress,'^(.*)://','match');
    if isempty(connectionProtocol)
        error(message('icomm_mqtt:MQTTClient:MissingProtocol'));
    end


    supportedProtocolSet=["tcp://","ws://","ssl://","wss://"];
    if~matches(connectionProtocol,supportedProtocolSet)
        error(message('icomm_mqtt:MQTTClient:InvalidProtocol'));
    end
end


function validateClientID(ClientID)


    validateattributes(ClientID,{'char','string'},{'scalartext'});
    if sum(isstrprop(ClientID,'alphanum'))~=length(char(ClientID))
        error(message('icomm_mqtt:MQTTClient:InvalidClientID',ClientID));
    end
end


function validateTimeout(Timeout)

    validateattributes(Timeout,{'numeric','duration'},{});
    if isa(Timeout,'duration')
        Timeout=seconds(Timeout);
    end
    validateattributes(Timeout,{'numeric'},{'scalar','integer','real','finite','nonnan','positive'});
end


function validateKeepAliveDuration(KeepAliveDuration)

    validateTimeout(KeepAliveDuration);
end


function validateSubscribeTopic(topic)

    validateattributes(topic,{'char','string'},{'scalartext'})
    topic=convertStringsToChars(topic);


    pat="+"|"#";
    indices=strfind(topic,pat);


    if isempty(indices)
        return
    end


    for i=indices
        if topic(i)=='+'

            if(i-1>0)&&topic(i-1)~='/'
                error(message('icomm_mqtt:MQTTClient:InvalidWildCardsForSubscribe',topic));
            end

            if(i+1<=length(topic))&&topic(i+1)~='/'
                error(message('icomm_mqtt:MQTTClient:InvalidWildCardsForSubscribe',topic));
            end
        end

        if topic(i)=='#'

            if(i-1>0)&&topic(i-1)~='/'
                error(message('icomm_mqtt:MQTTClient:InvalidWildCardsForSubscribe',topic));
            end

            if i+1<=length(topic)
                error(message('icomm_mqtt:MQTTClient:InvalidWildCardsForSubscribe',topic));
            end
        end

    end
end


function validateWriteTopic(topic)

    validateattributes(topic,{'char','string'},{'scalartext'})
    if contains(char(topic),{'#','+'})
        error(message('icomm_mqtt:MQTTClient:NoWildCardsForWrite'));
    end
end


function validateQualityOfService(QoS)

    validateattributes(QoS,{'numeric'},{'scalar','integer','nonnegative'});
    if QoS<0||QoS>2
        error(message('icomm_mqtt:MQTTClient:InvalidQoS'));
    end

end


function validateFile(value)

    validateattributes(value,{'char','string'},{'scalartext'});

    if~isempty(char(value))&&exist(value,'file')~=2
        error(message('icomm_mqtt:MQTTClient:InvalidFile'));
    end
end


function validateCallback(callback)

    if~isa(callback,'function_handle')&&~isa(callback,'char')&&~isa(callback,'string')
        error(message('icomm_mqtt:MQTTClient:InvalidCallback'));
    end

    if~isempty(char(callback))&&~isa(callback,'function_handle')
        try
            validateFile(callback);
        catch
            error(message('icomm_mqtt:MQTTClient:NoCallbackFound'));
        end
    end

end


function topicIdx=getTopicIdx(mqttClient,topic)




    topicIdx=find(strcmp(topic,mqttClient.Subscriptions.Topic));



    if isempty(topicIdx)


        for jj=1:length(mqttClient.SubscriptionObj)

            if contains(mqttClient.SubscriptionObj(jj).Topic,'+')
                topics=strsplit(mqttClient.SubscriptionObj(jj).Topic,'+');
                if~isempty(regexp(topic,[topics{1},'\w*',topics{2}],'once'))
                    topicIdx=jj;
                    return
                end
            end

            if contains(mqttClient.SubscriptionObj(jj).Topic,'#')
                topics=strsplit(mqttClient.SubscriptionObj(jj).Topic,'#');
                if contains(topic,topics{1})
                    topicIdx=jj;
                    return
                end
            end
        end
    end

end