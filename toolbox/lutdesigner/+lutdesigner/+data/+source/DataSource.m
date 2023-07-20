classdef(Abstract)DataSource<handle


    properties(SetAccess=immutable)
        SourceType(1,:)char
        Source(1,:)char
        Name(1,:)char
    end

    properties(SetAccess=immutable)
SourceKey
InstanceID
    end

    methods
        function this=DataSource(sourceType,source,name)
            this.SourceType=sourceType;
            this.Source=source;
            this.Name=name;

            this.SourceKey=sprintf('%s/%s/%s',sourceType,source,name);
            [~,this.InstanceID]=fileparts(tempname);
        end

        function registerPeerLockUnlockHandler(this,handler)
            coordinator=lutdesigner.data.source.PeerLockUnlockCoordinator.getInstance();
            coordinator.registerHandler(this.SourceKey,this.InstanceID,handler);
        end

        function unregisterPeerLockUnlockHandler(this)
            coordinator=lutdesigner.data.source.PeerLockUnlockCoordinator.getInstance();
            coordinator.unregisterHandler(this.SourceKey,this.InstanceID);
        end

        function registerPeerWriteHandler(this,handler)
            coordinator=lutdesigner.data.source.PeerWriteCoordinator.getInstance();
            coordinator.registerHandler(this.SourceKey,this.InstanceID,handler);
        end

        function unregisterPeerWriteHandler(this)
            coordinator=lutdesigner.data.source.PeerWriteCoordinator.getInstance();
            coordinator.unregisterHandler(this.SourceKey,this.InstanceID);
        end

        function delete(this)
            lockInfo=this.getLockInfo();
            if~isempty(lockInfo)&&strcmp(lockInfo.OwnerID,this.InstanceID)
                this.unlock();
            end

            this.unregisterPeerLockUnlockHandler();
            this.unregisterPeerWriteHandler();
        end

        function tf=isequal(this,that)
            tf=strcmp(this.SourceType,that.SourceType)&&...
            strcmp(this.Source,that.Source)&&...
            strcmp(this.Name,that.Name);
        end

        function tf=isequaln(this,that)
            tf=isequal(this,that);
        end

        function restrictions=getReadRestrictions(this)
            restrictions=getReadRestrictionsImpl(this);
            restrictions=restrictions(:);
        end

        function restrictions=getWriteRestrictions(this)
            restrictions=getWriteRestrictionsImpl(this);
            restrictions=restrictions(:);
            if this.isPeerLocked()
                lockInfo=this.getLockInfo();
                lockMessage=message('lutdesigner:data:peerLocked',lockInfo.OwnerTag);
                restrictions=[
restrictions
                lutdesigner.data.restriction.WriteRestriction(lockMessage)
                ];
            end
        end

        function data=read(this)
            restrictions=this.getReadRestrictions();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end

            data=readImpl(this);

            checkTypeSupport(data);
        end

        function write(this,data)
            checkTypeSupport(data);

            restrictions=this.getWriteRestrictions();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end

            writeImpl(this,data);

            coordinator=lutdesigner.data.source.PeerWriteCoordinator.getInstance();
            coordinator.notifyWrite(this.SourceKey,this.InstanceID);
        end

        function lockInfo=getLockInfo(this)
            coordinator=lutdesigner.data.source.PeerLockUnlockCoordinator.getInstance();
            lockInfo=coordinator.getLockInfo(this.SourceKey);
        end

        function tf=isPeerLocked(this)
            lockInfo=this.getLockInfo();
            tf=~isempty(lockInfo)&&~strcmp(lockInfo.OwnerID,this.InstanceID);
        end

        function lock(this,userTag)
            coordinator=lutdesigner.data.source.PeerLockUnlockCoordinator.getInstance();
            coordinator.lock(this.SourceKey,this.InstanceID,userTag);
        end

        function unlock(this)
            coordinator=lutdesigner.data.source.PeerLockUnlockCoordinator.getInstance();
            coordinator.unlock(this.SourceKey,this.InstanceID);
        end
    end

    methods(Abstract,Access=protected)
        restrictions=getReadRestrictionsImpl(this);

        restrictions=getWriteRestrictionsImpl(this);

        data=readImpl(this);

        writeImpl(this,data);
    end
end

function checkTypeSupport(data)
    assert(~(isfi(data)&&(isfloat(data)||isboolean(data))),...
    'lutdesigner:data:typeSupportLimitation',...
    'Floating point wrapped inside fi is not supported.');
end
