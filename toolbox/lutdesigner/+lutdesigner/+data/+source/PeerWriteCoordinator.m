classdef PeerWriteCoordinator<lutdesigner.data.source.PeerActionCoordinator

    methods
        function notifyWrite(this,sourceKey,writerID)
            this.invokePeerHandlers(sourceKey,writerID,{});
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=lutdesigner.data.source.PeerWriteCoordinator;
            end
            obj=instance;
        end
    end
end
