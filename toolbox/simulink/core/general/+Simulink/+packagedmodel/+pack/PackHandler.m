classdef PackHandler<handle




    properties(Hidden)
SlxcMasterData
OkToThrow
Results
    end

    methods(Access=public)
        function this=PackHandler(tSlxcMasterData,okToThrow)
            this.SlxcMasterData=tSlxcMasterData;
            this.OkToThrow=okToThrow;
        end

        function execute(this)
            if this.returnEarly()
                return;
            end

            this.Results=cell(size(this.SlxcMasterData));
            this.process();
            this.throwIfNeeded();
        end
    end

    methods(Abstract,Access=protected)
        process(this)
    end

    methods(Access=protected)
        function data=prepareData(this,i)
            data=this.SlxcMasterData(i);
            if strcmp(data.targetType,'SIM')
                data.modelInstances{end+1}={slcache.Modes.SIM,...
                builtin('_getSLCacheSerializedModel',data.model,slcache.Modes.SIM),...
                'SimPreparer'};
            else
                data.modelInstances{end+1}={slcache.Modes.CODER,...
                builtin('_getSLCacheSerializedModel',data.model,slcache.Modes.CODER),...
                'CoderPreparer'};
            end
        end
    end

    methods(Access=private)
        function result=returnEarly(this)
            result=isempty(this.SlxcMasterData)||...
            Simulink.ModelReference.ProtectedModel.protectingModel(...
            this.SlxcMasterData(1).topModel);
        end

        function throwIfNeeded(this)
            this.Results=this.Results(~cellfun('isempty',this.Results));
            if this.OkToThrow&&~isempty(this.Results)
                rethrow(this.Results{1});
            end
        end
    end

    methods(Static)
        function result=loc_parPackSLCache(tSLXCData)
            try
                PerfTools.Tracer.logSimulinkData('SLbuild',tSLXCData.model,tSLXCData.targetName,...
                'Pack Simulink Cache',true);

                ocPerfTracer=onCleanup(@()PerfTools.Tracer.logSimulinkData('SLbuild',...
                tSLXCData.model,tSLXCData.targetName,'Pack Simulink Cache',false));
                if strcmp(tSLXCData.targetType,'SIM')
                    builtin('_packSLCacheSIM',tSLXCData.model,tSLXCData.updatePackagedArtifacts,tSLXCData.modelInstances);
                else
                    builtin('_packSLCacheCoder',tSLXCData.model,tSLXCData.updatePackagedArtifacts,tSLXCData.modelInstances,tSLXCData.objExt);
                end
                ocPerfTracer.delete();

                result=[];
            catch me



                result=me;
            end
        end

    end
end


