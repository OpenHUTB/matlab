classdef CustomMap<lutdesigner.lutfinder.datafinder.InstanceDataMap
    properties(SetAccess=immutable)
Config
    end

    methods
        function this=CustomMap(aConfig)
            this.Config=aConfig;
        end
    end

    methods(Access=protected)
        function dataMap=blockDataMap(this,~)
            dataMap.numdims=this.Config.NumDims;
            dataMap.table=this.Config.Table;
            dataMap.axes=this.Config.Axes;
            dataMap.type="explicit";
        end

        function dataSrc=blockDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.CompoundLookupTable

            if strcmp(dataMap.table,"")
                tableSrc=lutdesigner.data.source.UnknownDataSource('lutdesigner:data:unspecifiedParameterSource');
            else
                tableSrc=this.getParameterSource(blockHandle,dataMap.table);
            end
            table=this.createMatrixParameterProxy(tableSrc);

            numdims=numel(dataMap.axes);
            axes=cell(1,numdims);
            for idx=1:numdims
                if strcmp(dataMap.axes{idx},"")
                    axisSrc=lutdesigner.data.source.UnknownDataSource('lutdesigner:data:unspecifiedParameterSource');
                else
                    axisSrc=this.getParameterSource(blockHandle,dataMap.axes{idx});
                end
                axis=this.createMatrixParameterProxy(axisSrc);
                axes{idx}=axis;
            end
            dataSrc=CompoundLookupTable(axes,table);
        end
    end
end
