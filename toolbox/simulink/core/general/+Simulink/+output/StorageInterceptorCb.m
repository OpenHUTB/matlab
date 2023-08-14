classdef StorageInterceptorCb<handle

    properties(Access='private')
        mMsgStorage='';
    end

    methods

        function result=process(this,aMsgRecord)
            this.mMsgStorage=[this.mMsgStorage,aMsgRecord];

            result=[];
        end


        function returnMsgRecord=getInterceptedMsg(this)
            returnMsgRecord=this.mMsgStorage;
        end


        function returnMsgRecord=lastInterceptedMsg(this)
            returnMsgRecord='';
            if(~isempty(this.mMsgStorage))
                returnMsgRecord=this.mMsgStorage(length(this.mMsgStorage));
            end
        end
    end
end
