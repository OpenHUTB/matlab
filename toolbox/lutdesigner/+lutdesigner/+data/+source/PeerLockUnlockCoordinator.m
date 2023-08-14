classdef PeerLockUnlockCoordinator<lutdesigner.data.source.PeerActionCoordinator

    properties(SetAccess=private,GetAccess={?matlab.unittest.TestCase})
LockInfoMap
    end

    methods(Access=private)
        function this=PeerLockUnlockCoordinator
            this=this@lutdesigner.data.source.PeerActionCoordinator
            this.LockInfoMap=containers.Map;
        end
    end

    methods
        function lockInfo=getLockInfo(this,sourceKey)
            if this.LockInfoMap.isKey(sourceKey)
                lockInfo=this.LockInfoMap(sourceKey);
            else
                lockInfo=[];
            end
        end

        function lock(this,sourceKey,invokerID,invokerTag)
            assert(~this.LockInfoMap.isKey(sourceKey),...
            message('lutdesigner:data:invalidLock'));
            this.LockInfoMap(sourceKey)=struct('OwnerID',invokerID,'OwnerTag',invokerTag);
            this.invokePeerHandlers(sourceKey,invokerID,{'lock'});
        end

        function unlock(this,sourceKey,invokerID)
            assert(this.LockInfoMap.isKey(sourceKey)&&...
            strcmp(this.LockInfoMap(sourceKey).OwnerID,invokerID),...
            message('lutdesigner:data:invalidUnlock'));
            this.LockInfoMap.remove(sourceKey);
            this.invokePeerHandlers(sourceKey,invokerID,{'unlock'});
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=lutdesigner.data.source.PeerLockUnlockCoordinator;
            end
            obj=instance;
        end
    end
end
