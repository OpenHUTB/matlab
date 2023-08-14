classdef SimulationStorageObserverHelper<handle


    properties(Access=protected)
        fMdlHelperHdl=[]
        fMdlObserverHdl=[]
        fBlkHdl=[]
        fStHdl=[]
        fSidx=0
        fListeners=[]
    end
    methods(Access={?slde.SimulationObserverHelper})
        function obj=SimulationStorageObserverHelper(mHelperHdl,mObsHdl,blkHdl,sHdl,sIdx)
            obj.fMdlHelperHdl=mHelperHdl;
            obj.fMdlObserverHdl=mObsHdl;
            obj.fBlkHdl=blkHdl;
            obj.fStHdl=sHdl;
            obj.fSidx=sIdx;
            l1=addlistener(sHdl,'PostEntry',@obj.postEntry);
            l2=addlistener(sHdl,'PreExit',@obj.preExit);
            obj.fListeners=[l1,l2];
        end
        function destroyListeners(obj)
            delete(obj.fListeners);
            obj.fListeners=[];
        end
    end
    methods(Access=private)
        function postEntry(obj,evSrc,~)
            evData=obj.fMdlHelperHdl.getCurrentEntityAndEvent(obj.fBlkHdl);
            evData.Block=obj.fBlkHdl;
            evData.Storage=obj.fStHdl;
            evData.StorageIdx=obj.fSidx;
            obj.fMdlObserverHdl.postEntry(evSrc,evData);
        end

        function preExit(obj,evSrc,~)
            evData=obj.fMdlHelperHdl.getCurrentEntityAndEvent(obj.fBlkHdl);
            evData.Block=obj.fBlkHdl;
            evData.Storage=obj.fStHdl;
            evData.StorageIdx=obj.fSidx;
            obj.fMdlObserverHdl.preExit(evSrc,evData);
        end
    end
end
