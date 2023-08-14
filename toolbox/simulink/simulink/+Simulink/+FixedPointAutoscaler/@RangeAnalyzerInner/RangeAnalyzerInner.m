


classdef RangeAnalyzerInner<handle

    properties(GetAccess='private',SetAccess='private')
        model;
        subsystem;
        target;
        status;
        oldValGenExecGraph;
        oldValUpdateSortedOrder;
        oldValSortNDFBlks;
        compatCheckOnly;
    end

    methods(Access='protected')
        cleanupModels(obj)
    end

    methods(Access='public')

        function obj=RangeAnalyzerInner(model,subsystem,target,compatCheckOnly)
            obj.model=model;
            obj.subsystem=subsystem;
            obj.target=target;
            obj.compatCheckOnly=compatCheckOnly;

            obj.oldValGenExecGraph=slfeature('GenerateExecGraph');
            obj.oldValUpdateSortedOrder=slfeature('UpdateSortedOrderFromExecGraph');
            obj.oldValSortNDFBlks=slfeature('SortNDFBlksByGraphicalOrder');

            if slfeature('RANDFGraphicalSort')
                slfeature('GenerateExecGraph',1);
                slfeature('UpdateSortedOrderFromExecGraph',1);
                slfeature('SortNDFBlksByGraphicalOrder',1);
            end
        end

        fileNames=analyze(obj)

        function delete(obj)
            cleanupObj=obj.enterTracePoint('Model Cleanup');%#ok<NASGU>

            slfeature('GenerateExecGraph',obj.oldValGenExecGraph);
            slfeature('UpdateSortedOrderFromExecGraph',obj.oldValUpdateSortedOrder);
            slfeature('SortNDFBlksByGraphicalOrder',obj.oldValSortNDFBlks);


            Sldv.Token.get.release;
            obj.cleanupModels;
        end
    end

    methods(Access='private')
        function cleanupObj=enterTracePoint(obj,point)

            PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
            obj.model,...
            obj.target,...
            point,...
            true);


            cleanupObj=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
            obj.model,...
            obj.target,...
            point,...
            false));
        end
    end
end


