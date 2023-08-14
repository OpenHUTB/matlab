classdef DirectLookupMap<lutdesigner.lutfinder.datafinder.InstanceDataMap

    methods(Access=protected)
        function dataMap=blockDataMap(~,~)
            dataMap=struct;
        end

        function dataProxy=blockDataSrc(this,~,blockHandle)
            if strcmp(get_param(blockHandle,'TableIsInput'),'on')
                tableSrc=lutdesigner.data.source.UnknownDataSource('lutdesigner:data:parameterPortSupportLimitation');
            else
                tableSrc=this.getParameterSource(blockHandle,'Table');
            end
            dataProxy=this.createMatrixParameterProxy(tableSrc);
        end
    end
end
