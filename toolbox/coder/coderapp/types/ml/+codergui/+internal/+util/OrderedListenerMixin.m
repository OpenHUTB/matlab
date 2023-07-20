classdef OrderedListenerMixin<handle






    properties(Access=private)
        ListenerLookup=cell(0,2)



        IsExternalInvocation=true
    end

    methods(Sealed)
        function listenerHandle=listener(this,varargin)
            origHandle=listener@handle(this,varargin{1:end-1},@noOpHandler);
            idx=this.registerListenerType(varargin{1:end-1});
            this.ListenerLookup{idx,2}(end+1)=struct(...
            'hasHandle',true,...
            'handle',origHandle,...
            'callback',varargin{end});
            listenerHandle=onCleanup(@()this.unregisterHandleListener(idx,origHandle));
        end

        function addlistener(this,varargin)
            if this.IsExternalInvocation
                idx=this.registerListenerType(varargin{1:end-1});
                this.ListenerLookup{idx,2}(end+1)=struct(...
                'hasHandle',false,...
                'handle',origHandle,...
                'callback',varargin{end});
            else
                addlistener@handle(this,varargin{:});
            end
        end
    end

    methods(Access=private)
        function idx=registerListenerType(this,varargin)
            narginchk(2,3);
            query={'<>','<>'};
            query(1:numel(varargin))=varargin;
            query=strjoin(query,'.');
            [~,idx]=intersect(this.ListenerLookup(:,1),query);

            if isempty(idx)
                idx=size(this.ListenerLookup,1)+1;
                this.ListenerLookup(idx,:)={query,struct('hasHandle',{},'handle',{},'callback',{})};
                this.IsExternalInvocation=false;
                this.addlistener(varargin{:},@(~,evt)this.redispatchEvent(idx,evt));
                this.IsExternalInvocation=true;
            end
        end

        function unregisterHandleListener(this,idx,listenerHandle)
            if~isvalid(this)
                return
            end
            listeners=this.ListenerLookup{idx,end};
            handleIndices=find([listeners.hasHandle]);
            [~,clientIdx]=intersect([listeners(handleIndices).handle],listenerHandle);
            this.ListenerLookup{idx,2}(handleIndices(clientIdx))=[];
        end

        function redispatchEvent(this,idx,evt)
            listeners=this.ListenerLookup{idx,2};
            for i=1:numel(listeners)
                feval(listeners(i).callback,this,evt);
            end
        end
    end
end


function noOpHandler(~,~)
end