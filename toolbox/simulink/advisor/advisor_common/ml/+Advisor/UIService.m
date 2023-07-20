classdef(Sealed=true)UIService<handle
    properties(Access=private)
        sessionMap;
        subscriptionsMap;
    end


    methods(Access='protected')


        function obj=UIService()
            obj.sessionMap=containers.Map('KeyType','char','ValueType','any');
            obj.subscriptionsMap=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods(Static=true)
        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=Advisor.UIService;
            end
            singleObj=localStaticObj;
        end
    end

    methods(Access=public)
        function register(this,WindowObj)
            this.sessionMap([WindowObj.App,'_',WindowObj.ID])=WindowObj;
            this.subscriptionsMap([WindowObj.App,'_',WindowObj.ID])=message.subscribe(this.getToUrl(WindowObj.App,WindowObj.ID),@(msg)this.execFunc(msg.appName,msg.sessionId,msg.fName,msg.fArgs,msg.uuid));
        end

        function unregister(this,app,id)
            if this.sessionMap.isKey([app,'_',id])
                this.sessionMap.remove([app,'_',id]);
                message.unsubscribe(this.subscriptionsMap([app,'_',id]));
                this.subscriptionsMap.remove([app,'_',id]);
            end

        end

        function window=getWindowById(this,app,id)
            window=[];
            if this.sessionMap.isKey([app,'_',id])
                window=this.sessionMap([app,'_',id]);
            end
        end

        function reg=getRegistry(this)
            reg=this.sessionMap;
        end

        function result=execFunc(this,appName,sessionID,fName,fArgs,uuid)
            result=struct('Status',false,'Data',[],'Error',[],'uuid',uuid);
            if this.sessionMap.isKey([appName,'_',sessionID])
                WindowObj=this.sessionMap([appName,'_',sessionID]);
                try
                    if~isempty(fArgs)
                        if iscell(fArgs)
                            outP=feval(fName,this.getController(WindowObj),fArgs{:});
                        else
                            outP=feval(fName,this.getController(WindowObj),fArgs);
                        end
                    else
                        outP=feval(fName,this.getController(WindowObj));
                    end
                    result.Status=true;
                    result.Error='';
                    result.Data=outP;
                catch e
                    result.Status=false;
                    result.Error=e.message;
                    result.Data=[];
                end
            else
                result.Status=false;
                result.Error=DAStudio.message('Advisor:ui:advisor_uiservice_nosession');
                result.Data=[];
            end
            message.publish(this.getFromUrl(appName,sessionID),result);
        end

        function publishToUI(this,appName,sessionId,event,data)
            dataPacket=struct();
            dataPacket.Event=event;
            dataPacket.EventData=data;
            message.publish(this.getFromUrl(appName,sessionId),dataPacket);
        end
    end

    methods(Access=private)
        function url=getToUrl(this,app,id)
            url=strcat('/',app,'/',id,'/toController');
        end

        function url=getFromUrl(this,app,id)
            url=strcat('/',app,'/',id,'/fromController');
        end

        function[app,id]=splitSessionID(this,sessionId)
            tokens=strsplit(sessionId,'_');
            app=tokens{1};
            id=tokens{2};
        end

        function controller=getController(this,WindowObj)
            if isprop(WindowObj,'Controller')
                controller=WindowObj.Controller;
            else
                controller=WindowObj;
            end
        end
    end
end