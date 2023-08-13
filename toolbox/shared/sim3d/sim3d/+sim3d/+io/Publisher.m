classdef Publisher<handle

    properties(Constant=true,Access=protected)
        DefaultQueueDepth=1
        DefaultPacketSize=8192
        DefaultLeaseDuration=0
    end

    properties
Domain
Topic
        Writer=[]
        PacketSize=sim3d.io.Publisher.DefaultPacketSize
        QueueDepth=sim3d.io.Publisher.DefaultQueueDepth
        LeaseDuration=sim3d.io.Publisher.DefaultLeaseDuration
    end

    methods(Access=public)
        function self=Publisher(topic,varargin)
            parser=inputParser;
            parser.addParameter('Domain',num2str(uint32(feature('getpid'))));
            parser.addParameter('QueueDepth',self.QueueDepth);
            parser.addParameter('PacketSize',self.PacketSize);
            parser.addParameter('LeaseDuration',self.LeaseDuration);
            parser.addParameter('Packet',[]);
            parser.parse(varargin{:});
            self.Topic=topic;
            mf0Model=mf.zero.Model;
            qos=liveio.SharedMemoryPublisherQos(mf0Model);
            self.QueueDepth=parser.Results.QueueDepth;
            qos.History.Depth=self.QueueDepth;
            if isempty(parser.Results.Packet)
                self.PacketSize=parser.Results.PacketSize;
            else
                self.PacketSize=liveio.ArrayPacketSize(parser.Results.Packet);
            end
            qos.History.PacketSize=self.PacketSize;
            self.LeaseDuration=parser.Results.LeaseDuration;
            qos.Liveliness.LeaseDuration=self.LeaseDuration;
            qos.History.OverflowPolicy=liveio.shared_memory.publisher_qos.OverflowKind.FIFO;
            self.Domain=parser.Results.Domain;
            self.Writer=liveio.SharedMemoryPublisher(self.Domain,self.Topic,qos);
        end

        function delete(self)
            self.Writer.delete();
            self.Writer=[];
        end

        function publish(self,message)
            self.send(message);
        end

        function success=send(self,message)
            messageSize=liveio.ArrayPacketSize(message);
            if messageSize>self.PacketSize
                warning("The published message size %d more than the declared size %d of the topic publisher %s. Updating the publisher QOS\n.",messageSize,self.PacketSize,self.Topic);
                self.PacketSize=messageSize;
                mf0Model=mf.zero.Model;
                qos=liveio.SharedMemoryPublisherQos(mf0Model);
                qos.History.Depth=self.QueueDepth;
                qos.History.PacketSize=self.PacketSize;
                qos.Liveliness.LeaseDuration=self.LeaseDuration;
                qos.History.OverflowPolicy=liveio.shared_memory.publisher_qos.OverflowKind.FIFO;
                self.Writer.delete();
                self.Writer=[];
                self.Writer=liveio.SharedMemoryPublisher(self.Domain,self.Topic,qos);
            end
            success=self.Writer.publish(message);
        end
    end
end
