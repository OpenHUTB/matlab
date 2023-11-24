classdef ObjectRemoteServer<handle

    properties(SetAccess=private)
ObjectMap
    end

    methods(Access=private)
        function this=ObjectRemoteServer()
            this.ObjectMap=containers.Map;
        end

        function id=generateRemoteID(~)
            [~,id]=fileparts(tempname);
        end
    end

    methods
        function id=registerRemotableObject(this,obj)
            id=this.generateRemoteID();
            this.ObjectMap(id)=obj;
        end

        function unregisterRemotableObject(this,id)
            if this.ObjectMap.isKey(id)
                this.ObjectMap.remove(id);
            end
        end

        function obj=getRemotableObject(this,id)
            obj=this.ObjectMap(id);
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent instance
            if isempty(instance)
                instance=lutdesigner.service.ObjectRemoteServer();
            end
            obj=instance;
        end
    end

    methods(Static)
        function varargout=invokeObjectMethod(id,method,varargin)
            server=lutdesigner.service.ObjectRemoteServer.getInstance();
            remotableObject=server.getRemotableObject(id);
            varargout=cell(1,nargout);
            [varargout{:}]=remotableObject.(method)(varargin{:});
        end
    end
end
