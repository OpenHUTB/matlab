classdef(Sealed)UpdateNotifier<handle

    methods(Access=private)
        function this=UpdateNotifier()
            this.tmData=this;
        end


        function h=add(this,handlerFnc)
            h=addlistener(this.tmData,'ReqUpdate',handlerFnc);
        end
    end


    properties(Access=private)
tmData
    end


    events
ReqUpdate
    end


    methods(Static,Access=private)
        function instance=getInstance()
            persistent singleObj
            if isempty(singleObj)||~isvalid(singleObj)
                singleObj=rmitm.UpdateNotifier();
            end
            instance=singleObj;
        end
    end


    methods(Static)

        function instance=register(handlerFnc)
            mlock;
            persistent handlers
            if isempty(handlers)
                handlers={};
            end
            instance=rmitm.UpdateNotifier.getInstance();
            if isempty(handlerFnc)
                while~isempty(handlers)
                    delete(handlers{end});
                    handlers(end)=[];
                end
            else
                handlers{end+1}=instance.add(handlerFnc);
            end
        end


        function notifyReqUpdate(testSuite,caseId)
            instance=rmitm.UpdateNotifier.getInstance();
            instance.notify('ReqUpdate',rmitm.RmiTmEvent(testSuite,caseId));
        end
    end
end

