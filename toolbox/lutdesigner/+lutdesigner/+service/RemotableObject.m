classdef RemotableObject<handle




    properties(SetAccess=immutable)
RemoteID
    end

    methods
        function this=RemotableObject()
            remoteServer=lutdesigner.service.ObjectRemoteServer.getInstance();
            this.RemoteID=remoteServer.registerRemotableObject(this);
        end

        function delete(this)
            remoteServer=lutdesigner.service.ObjectRemoteServer.getInstance();
            remoteServer.unregisterRemotableObject(this.RemoteID);
        end
    end
end
