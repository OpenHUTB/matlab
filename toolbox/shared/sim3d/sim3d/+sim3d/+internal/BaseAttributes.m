classdef BaseAttributes<handle

    properties(Access=protected)
        MessageTopic=''
        AttributesPublisher=[];
        AttributesBuffer=[];
    end

    properties(Hidden,Constant)
        All=0;
    end

    methods

        function self=BaseAttributes()
            self.AttributesBuffer=zeros(1,self.getTotalAttributes());
        end

        function setup(self,messageTopicOut)
            message=self.createMessage();
            packetSize=liveio.ArrayPacketSize(message);
            self.AttributesPublisher=sim3d.io.Publisher(messageTopicOut,'PacketSize',packetSize);
        end

        function publish(self)


            message=self.createMessage();
            self.publishMessage(message);
            self.emptyAttributesBuffer();
        end

        function delete(self)

            if~isempty(self.AttributesPublisher)
                self.AttributesPublisher.delete();
                self.AttributesPublisher=[];
            end
            self.emptyAttributesBuffer();
        end
    end

    methods(Access=protected)


        function publishMessage(self,message)
            if nargin==1
                message=self.getAttributes();
            end
            if~isempty(message)
                self.AttributesPublisher.publish(message);
            end
        end

        function selectedMessage=createMessage(self)
            selectedMessage=[];
            if(all(~self.AttributesBuffer))
                return;
            end
            selectedMessage=self.getSelectedAttributes(self.AttributesBuffer);
        end


        function add2Buffer(self,attributesID)
            self.AttributesBuffer(attributesID)=1;
        end

        function buffer=getAttributesBuffer(self)
            buffer=self.AttributesBuffer;
        end

        function emptyAttributesBuffer(self)
            self.AttributesBuffer=zeros(1,self.getTotalAttributes());
        end

    end

    methods(Hidden)
        function totalAttributes=getTotalAttributes(self)
            totalAttributes=self.All;
        end

        function selectedAttributes=getSelectedAttributes(~)
            selectedAttributes=[];
        end
    end
end