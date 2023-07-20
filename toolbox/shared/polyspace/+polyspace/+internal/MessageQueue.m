


classdef MessageQueue<handle
    properties(Access=private,Constant=true)
        MSGQUEUE_OPEN=1;
        MSGQUEUE_CLOSE=2;
        MSGQUEUE_SEND_MSG=3;
        MSGQUEUE_RECEIVE_MSG=4;
        MSGQUEUE_GET_NUM_MSG=5;
        MSGQUEUE_GET_MAX_MSG=6;
        MSGQUEUE_REMOVE=7;
    end

    properties(Access=private)
message_queue_name
msgqueue
closeOnly
    end

    methods(Access=public)
        function this=MessageQueue(message_queue_name,varargin)
            this.message_queue_name=message_queue_name;
            if(nargin>=2)&&islogical(varargin{1})
                openOnly=varargin{1};
            else
                openOnly=false;
            end
            this.closeOnly=openOnly;
            this.msgqueue=msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_OPEN,...
            message_queue_name,varargin{:});
        end

        function delete(this)
            if~isempty(this.msgqueue)
                msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_CLOSE,...
                this.message_queue_name,this.msgqueue,this.closeOnly);
            end
        end

        function varargout=sendMessage(this,msg,varargin)
            varargout=cell(1,nargout);
            [varargout{:}]=...
            msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_SEND_MSG,...
            this.msgqueue,msg,varargin{:});
        end

        function varargout=receiveMessage(this,varargin)
            varargout=cell(1,nargout);
            [varargout{:}]=...
            msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_RECEIVE_MSG,...
            this.msgqueue,varargin{:});
        end

        function n=getNumberOfMessages(this)
            n=msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_GET_NUM_MSG,...
            this.msgqueue);
        end

        function n=getMaximumNumberOfMessages(this)
            n=msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_GET_MAX_MSG,...
            this.msgqueue);
        end
    end

    methods(Access=public,Static=true)
        function removeQueue(message_queue_name)
            msgqueue_mex(polyspace.internal.MessageQueue.MSGQUEUE_REMOVE,...
            message_queue_name);
        end
    end
end
