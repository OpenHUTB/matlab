classdef MessageViewerRegistry<handle


    properties
        viewers={};
        blockDetails={};
        blockKeys=[];
        logger=[];
    end

    methods
        function logger=getLogger(this)
            logger=this.logger;
        end

        function registerLogger(this,logger)
            this.logger=logger;
        end

        function unRegisterLogger(this)
            this.logger=[];
        end

        function this=MessageViewerRegistry()
            this.blockKeys=containers.Map('KeyType','double','ValueType','double');
        end

        function addViewer(this,viewer)
            this.viewers{end+1}=viewer;
        end

        function storeBlockDetails(this,details,modelHandle)
            if(this.blockKeys.isKey(modelHandle))
                idx=this.blockKeys(modelHandle);
            else
                idx=length(this.blockDetails)+1;
                this.blockKeys(modelHandle)=idx;
            end
            this.blockDetails{idx}=details;
        end

        function details=retrieveBlockDetails(this,modelHandle)
            details=[];
            if(this.blockKeys.isKey(modelHandle))
                idx=this.blockKeys(modelHandle);
                details=this.blockDetails{idx};
            end
        end

        function removeBlockDetails(this,modelHandle)
            if(this.blockKeys.isKey(modelHandle))
                idx=this.blockKeys(modelHandle);
                this.blockDetails(idx)=[];
                this.blockKeys.remove(modelHandle);
            end
        end

        function removeViewer(this,viewer)
            for si=1:length(this.viewers)
                v=this.viewers{si};
                if viewer==v
                    this.viewers(si)=[];
                    break;
                end
            end
            viewersForThisModel=this.findViewersWithModelHandler(viewer.modelH);
            if isempty(viewersForThisModel)
                this.removeBlockDetails(viewer.modelH);
            end
        end

        function cleanUp(this)
            currentViewerList=this.viewers;
            for si=1:length(currentViewerList)
                v=currentViewerList{si};
                if~isempty(v)&&isvalid(v)
                    v.delete();
                end
            end
            this.viewers={};
            this.blockDetails={};
        end

        function viewer=findViewerFromChannel(this,channel)
            viewer=[];
            for si=1:length(this.viewers)
                v=this.viewers{si};
                if strcmp(v.channel,channel)
                    viewer=v;
                    return;
                end
            end
        end

        function viewers=findViewersWithModelHandler(this,modelHandle)
            viewers={};
            for si=1:length(this.viewers)
                v=this.viewers{si};
                if~isempty(v.modelH)&&v.modelH==modelHandle
                    viewers{end+1}=v;
                end
            end
        end

        function viewer=findViewerOnToolstripWithModelHandler(this,modelHandle)
            viewer={};
            for si=1:length(this.viewers)
                v=this.viewers{si};
                if~isempty(v.modelH)&&v.modelH==modelHandle&&...
                    v.isOnToolstrip
                    viewer=v;
                    return;
                end
            end
        end

        function manageEventLogging(~,modelHandle,isEventLoggingOn)
            builtin('_setEventLogginOnSingletonViewManager',modelHandle,isEventLoggingOn);
        end
    end

    methods(Static)
        function registry=getInstance()
            persistent persistentRegistry;
            if isempty(persistentRegistry)
                persistentRegistry=MessageViewerRegistry();
            end
            registry=persistentRegistry;
        end
    end


end

