classdef InstanceDataMap<handle

    methods
        function dataProxy=getBlockDataProxy(this,block)
            blockHandle=get_param(block,'Handle');
            dataMap=this.blockDataMap(blockHandle);
            dataProxy=this.blockDataSrc(dataMap,blockHandle);
        end
    end

    methods(Abstract,Access=protected)
        blockDataMap(this);
        blockDataSrc(this,dataMap);
    end

    methods(Static,Access=protected)
        function dataSource=getParameterSource(blockHandle,paramName)
            import lutdesigner.lutfinder.datafinder.internal.findParameterStringSource

            paramStr=get_param(blockHandle,paramName);
            dataSource=findParameterStringSource(blockHandle,paramName,paramStr);
        end

        function propProxy=createMatrixParameterProxy(dataSource)
            if isempty(dataSource.getReadRestrictions())&&isa(dataSource.read(),'Simulink.Parameter')
                propProxy=lutdesigner.data.proxy.SimulinkParameter(dataSource);
            else
                propProxy=lutdesigner.data.proxy.CompoundExplicitMatrix(dataSource);
            end
        end
    end
end
