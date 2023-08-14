classdef ReleaseMgrListener<handle




    properties(Access=private)
        releaseRegListenerId=[]
    end

    methods(Access=private)
        function obj=ReleaseMgrListener
        end
    end

    methods(Static)

        function singleObj=getInstance()
            mlock;
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=stm.internal.ReleaseMgrListener;
            end
            singleObj=localObj;
        end

        function updateReleaseInfo(~)
            releaseListStruct=stm.internal.util.getRegisteredReleases;
            stm.internal.setReleases(releaseListStruct);
        end

        function attach()
            obj=stm.internal.ReleaseMgrListener.getInstance();
            obj.releaseRegListenerId=...
            Simulink.CoSimServiceUtils.attachView(@()stm.internal.ReleaseMgrListener.updateReleaseInfo(...
            '/STM/ReleaseList'));
        end

        function detach()
            obj=stm.internal.ReleaseMgrListener.getInstance();
            if~isempty(obj.releaseRegListenerId)
                Simulink.CoSimServiceUtils.detachView(obj.releaseRegListenerId);
            end
            obj.releaseRegListenerId=[];
        end
    end
end

