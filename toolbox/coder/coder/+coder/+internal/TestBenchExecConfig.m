




classdef TestBenchExecConfig<handle
    properties(SetAccess=private,GetAccess=private)

isMexInEntryPtPath


isEntryPtCompiled





logFcnNameMap




        inLogIndicesMap;
        outLogIndicesMap;

hasMultipleEntryPoints



outputParamCountMap






actualEntryPointNamesMap


suppressOutput
    end
    methods(Access=public)
        function this=TestBenchExecConfig(isMexInEntryPtPath,isEntryPtCompiled)
            this.isMexInEntryPtPath=logical(isMexInEntryPtPath);
            this.isEntryPtCompiled=logical(isEntryPtCompiled);
            this.logFcnNameMap=containers.Map('KeyType','char','ValueType','char');
            this.inLogIndicesMap=containers.Map();
            this.outLogIndicesMap=containers.Map();
            this.hasMultipleEntryPoints=false;
            this.outputParamCountMap=containers.Map();
            this.actualEntryPointNamesMap=containers.Map();
            this.suppressOutput=false;
        end

        function setActualEntryPointNamesMap(this,m)
            if isempty(m)
                return;
            end
            assert(isa(m,'containers.Map'));
            this.actualEntryPointNamesMap=m;
        end

        function altEpName=getActualEntryPointToCall(this,epName)
            altEpName='';
            if this.actualEntryPointNamesMap.isKey(epName)
                altEpName=this.actualEntryPointNamesMap(epName);
            end
        end

        function res=isEntryPointCompiled(this)
            res=this.isEntryPtCompiled;
        end

        function res=isMexInEntryPointPath(this)
            res=this.isMexInEntryPtPath;
        end

        function setEntryPointCompiled(this,isEntryPtCompiled)
            this.isEntryPtCompiled=isEntryPtCompiled;
        end

        function setMexInEntryPointPath(this,isMexInEntryPtPath)
            this.isMexInEntryPtPath=isMexInEntryPtPath;
        end

        function setLogFcnName(this,entryPoint,logFcn)
            this.logFcnNameMap(entryPoint)=logFcn;
        end

        function logFcn=getLogFcnName(this,entryPoint)
            logFcn='';
            if this.logFcnNameMap.isKey(entryPoint)
                logFcn=this.logFcnNameMap(entryPoint);
            end
        end

        function[inLogIndicesMap,outLogIndicesMap]=getInputOutputLogIndices(this,entryPoint)
            inLogIndicesMap=this.inLogIndicesMap(entryPoint);
            outLogIndicesMap=this.outLogIndicesMap(entryPoint);
        end

        function setInputOutputLogIndices(this,entryPoint,inputLogIndices,outputLogIndices)
            this.inLogIndicesMap(entryPoint)=logical(inputLogIndices);
            this.outLogIndicesMap(entryPoint)=logical(outputLogIndices);
        end

        function setHasMultipleEntryPoints(this,hasMultiEntryPts)
            this.hasMultipleEntryPoints=hasMultiEntryPts;
        end

        function hasMultiEntryPts=getHasMultipleEntryPoints(this)
            hasMultiEntryPts=this.hasMultipleEntryPoints;
        end

        function count=getOutputParamCount(this,entryPoint)
            count=this.outputParamCountMap(entryPoint);
        end

        function setOutputParamCount(this,entryPoint,count)
            if isempty(count)
                count=-1;
            end
            this.outputParamCountMap(entryPoint)=count;
        end

        function setSuppressOutput(this,suppress)
            this.suppressOutput=suppress;
        end

        function shouldSuppress=getSuppressOutput(this)
            shouldSuppress=this.suppressOutput;
        end
    end
end
