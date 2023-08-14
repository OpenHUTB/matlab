



classdef MessageStreamHandler<handle



    properties(Hidden=true,GetAccess=public,SetAccess=private)
        isQueued;
        msgReporter;
        msgs;
    end

    methods(Access=private)



        function self=MessageStreamHandler()
            self.isQueued=false;
            self.msgReporter=autosar.mm.util.MessageReporter();
            self.msgs=autosar.mm.util.Message.empty();


            self.activate();
        end
    end

    methods(Access=public)


        function setReporter(self,aMsgReporter)


            if~isempty(aMsgReporter)&&~isa(aMsgReporter,'autosar.mm.util.MessageReporter')
                DAStudio.error('RTW:autosar:mmInvalidArgObject',1,'autosar.mm.util.MessageReporter');
            end
            self.msgReporter=aMsgReporter;
        end



        function setMessages(self,msgs)
            if~isa(msgs,'autosar.mm.util.Message')
                DAStudio.error('RTW:autosar:mmInvalidArgObject',1,'autosar.mm.util.Message');
            end
            self.msgs=msgs;
        end



        function clear(self)
            if~isempty(self.msgReporter)
                self.msgReporter.clear();
            end
            self.isQueued=false;
            self.msgs=autosar.mm.util.Message.empty();
        end



        function activate(self)
            M3IUserMessageStream.addStreamListener(self);
        end



        function deactivate(self)
            M3IUserMessageStream.removeStreamListener(self);
        end



        function disableQueuingObj=enableQueuing(self)




            disableQueuingObj=onCleanup(@()disableQueuing(self));
            function self=disableQueuing(self)
                self.isQueued=false;
            end

            self.isQueued=true;
        end



        function handleMessage(self,type,classifier,source,summary,reportedBy,details)

            self.msgs(end+1)=autosar.mm.util.Message(type,classifier,details,summary,source,reportedBy);

            if~self.isQueued
                self.flush();
            end
        end



        function createMessage(self,type,identifier,params,source,reportedBy,summary)

            if nargin<4
                params={};
            else
                if ischar(params)||isStringScalar(params)
                    params={params};
                end
            end


            if(length(params)==1)&&isa(params{:},'MException')




                details=params{:};
            else


                details=message(identifier,params{:});
            end

            if nargin<5
                source='';
            end

            if nargin<6
                reportedBy='';
            end

            if nargin<7
                summary=details;
            end


            try

                self.handleMessage(type,identifier,source,summary,reportedBy,details);
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end

        end



        function createInfo(self,identifier,varargin)
            self.createMessage('Info',identifier,varargin{:});
        end



        function createWarning(self,identifier,varargin)
            self.createMessage('Warning',identifier,varargin{:});
        end



        function createError(self,identifier,varargin)
            self.createMessage('Error',identifier,varargin{:});
        end





        function ret=flush(self,headMsgId)

            if nargin<2
                headMsgId='';
            end

            ret=true;
            if~isempty(self.msgReporter)
                msgsToReport=self.msgs;
                self.msgs=autosar.mm.util.Message.empty();
                ok=self.msgReporter.flush(msgsToReport,headMsgId);
                ret=ret&&ok;
            end
            self.msgs=autosar.mm.util.Message.empty();
        end

    end

    methods(Static,Access=public)








        function inst=instance()
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=autosar.mm.util.MessageStreamHandler();
            end
            inst=localObj;
        end

        function msgStream=initMessageStreamHandler()

            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            messageReporter=autosar.mm.util.MessageReporter();
            msgStream.setReporter(messageReporter);
            msgStream.activate();
        end
    end

end


