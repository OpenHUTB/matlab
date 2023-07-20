classdef DatasetStorage<handle&matlab.mixin.Copyable















    methods

        function obj=DatasetStorage(runID,domain,logIntervals,dlo)
            obj.DatasetRef=Simulink.sdi.DatasetRef(runID,domain);
            setIntervalsAndOverride(obj.DatasetRef,logIntervals,dlo);
            obj.RunID=runID;
            obj.ElementCache=[];

            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            obj.PreDeleteListener=fw.createPreRunDeleteListener(...
            @(x,y)preRepositoryDeleteCallback(obj,x,y));
        end


        function delete(this)
            if~isempty(this.PreDeleteListener)
                delete(this.PreDeleteListener);
            end
        end
    end


    methods(Access=protected)


        function cpObj=copyElement(this)
            fullFlushIfNeeded(this);

            cpObj=copyElement@matlab.mixin.Copyable(this);
            if~isempty(this.PreDeleteListener)

                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                cpObj.PreDeleteListener=fw.createPreRunDeleteListener(...
                @(x,y)preRepositoryDeleteCallback(cpObj,x,y));
            end
        end
    end


    methods(Hidden=true)
        nelem=numElements(this)
        meta=getMetaData(this,idx,prop)
        elem=getElements(this,idx)
        this=addElements(this,idx,elem)
        this=setElements(this,idx,elem)
        this=removeElements(this,idx)
        this=sortElements(this)
        obj=constructMcosLeafFromStructStorage(this,strct,varargin)
        this=convertTStoTTatLeaf(this)
        obj=getElementAsDatastore(this,varargin)
        [values,names,propNames,blockPaths]=utGetMetadataForDisplay(this)

        obj=saveobj(this)
        obj=getMemoryResidentStorage(this)
        fullyLoadCache(this,startIdx)
        ret=getCache(this)
        ret=validateOverride(this)
        preRepositoryDeleteCallback(this,h,evt)
        fullFlushIfNeeded(this);

        function runID=getRunID(this)
            runID=this.RunID;
        end

        function checkIdxRange(this,idx,maxIdx,err)



            fullFlushIfNeeded(this);

            if length(this)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end

            if~isnumeric(idx)||~isreal(idx)||...
                any(idx~=uint32(idx))||min(idx)<1||max(idx)>maxIdx
                Simulink.SimulationData.utError(err,maxIdx);
            end
        end

        function ret=getSortedSignalIDs(this)
            ret=this.DatasetRef.getSortedSignalIDs();
        end

        function setSortStatesForLegacyFormats(this,flag)
            this.DatasetRef.SortStatesForLegacyFormats=flag;
        end
    end


    methods(Static,Hidden=true)
        obj=constructMcosTimeseriesFromStructStorage(strct,varargin)
        obj=constructMcosTimetableFromStructStorage(strct,varargin)
    end


    methods(Access=private)
        cacheElementIfNeeded(this,idx);
    end


    properties(Hidden)
        ReturnAsDatastore=false;
    end


    properties(Access=private)
RunID
DatasetRef
ElementCache
    end

    properties(Transient=true,Access=private)
PreDeleteListener
        HasAnyElementBeenCached=false
    end
end
