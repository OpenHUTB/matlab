classdef Subscriber<handle

    properties
        topic
        Reader=[]
        Listener=[]
    end
    

    properties(Constant=true)
        QueueDepth=1
        ReceiveTimeout=0
        ReceiveSampleTime=100
        LeaseDuration=0
        Liveliness=false
    end


    methods
        function delete(self)
            self.Reader.listener();
            self.Listener=[];
            self.Reader=[];
        end

        
        function self=Subscriber(topic,varargin)
            parser=inputParser;
            parser.addParameter('Domain',num2str(uint32(feature('getpid'))));
            parser.addParameter('QueueDepth',sim3d.io.Subscriber.QueueDepth);
            parser.addParameter('LeaseDuration',sim3d.io.Subscriber.LeaseDuration);
            parser.parse(varargin{:});
            self.topic=topic;
            mf0Model=mf.zero.Model;
            qos=liveio.SharedMemorySubsriberQos(mf0Model);
            qos.History.Depth=parser.Results.QueueDepth;
            qos.History.Kind=liveio.shared_memory.subscriber_qos.HistoryKind.KEEP_LAST_HISTORY_QOS;
            qos.Durability.Kind=liveio.shared_memory.subscriber_qos.DurabilityKind.TRANSIENT_LOCAL_DURABILITY_QOS;
            qos.Liveliness.LeaseDuration=parser.Results.LeaseDuration;
            self.Reader=liveio.SharedMemorySubscriber(parser.Results.Domain,topic,qos);
            if parser.Results.LeaseDuration>0
                listener=sim3d.io.Listener;
                listener.topic=self.topic;
                iolistener=liveio.Listener;
                iolistener.OnSubscriptionChanged(@(x)listener.onSubscriptionChanged(x));
                iolistener.OnLivelinessChanged(@(x)listener.onLivelinessChanged(x));
                self.Reader.listener(iolistener);
                self.Listener=listener;
            end
        end


        function result=has_message(self)
            result=self.hasMessage();
        end


        function message=take(self)
            message=self.receive();
        end


        function result=hasMessage(self)
            result=self.Reader.has_message();
        end


        function message=receive(self,varargin)
            narginchk(1,2);
            if nargin>1
                timeout=varargin{1};
            else
                timeout=sim3d.io.Subscriber.ReceiveTimeout;
            end
            if timeout==0
                message=self.Reader.take();
            else
                N=floor(timeout/sim3d.io.Subscriber.ReceiveSampleTime)+1;
                message=[];
                for n=1:N
                    message=self.Reader.take(sim3d.io.Subscriber.ReceiveSampleTime);
                    if~isempty(message)||self.Listener.IsPublisherDisconnected
                        break
                    end
                end
            end
        end

        
        function addListener(listener)
            self.Reader.listener(listener);
        end

    end
end
