classdef PrelookupMap<lutdesigner.lutfinder.datafinder.InstanceDataMap

    methods(Access=protected)
        function datamap=blockDataMap(this,blockHandle)

            bpspec=get_param(blockHandle,'BreakpointsSpecification');
            if(strcmp(bpspec,'Explicit values'))
                datamap=this.explicitDataMap(blockHandle);
            elseif(strcmp(bpspec,'Even spacing'))
                datamap=this.evenDataMap();
            else
                datamap=this.objectDataMap();
            end
        end

        function dataSrc=blockDataSrc(this,dataMap,blockHandle)

            switch dataMap.type
            case 'object'
                dataSrc=this.objectAxisSrc(dataMap,blockHandle);
            case 'explicit'
                dataSrc=this.explicitAxisSrc(dataMap,blockHandle);
            otherwise
                dataSrc=this.evenAxisSrc(dataMap,blockHandle);
            end
        end


        function axis=objectAxisSrc(this,dataMap,blockHandle)

            bpSrc=this.getParameterSource(blockHandle,dataMap.axes);
            axis=lutdesigner.data.proxy.BreakpointObject(bpSrc);
        end

        function axis=explicitAxisSrc(this,dataMap,blockHandle)

            if strcmp(dataMap.axes,"Input port")
                axisSrc=lutdesigner.data.source.UnknownDataSource('lutdesigner:data:parameterPortSupportLimitation');
            else
                axisSrc=this.getParameterSource(blockHandle,dataMap.axes);
            end
            axis=this.createMatrixParameterProxy(axisSrc);
        end

        function axis=evenAxisSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.CompoundStandaloneEvenSpacing

            axisNumPointsSrc=this.getParameterSource(blockHandle,dataMap.axes(1));
            axisFirstPointSrc=this.getParameterSource(blockHandle,dataMap.axes(2));
            axisSpacingSrc=this.getParameterSource(blockHandle,dataMap.axes(3));

            axis=CompoundStandaloneEvenSpacing(axisFirstPointSrc,axisSpacingSrc,axisNumPointsSrc);
        end

        function datamap=explicitDataMap(~,blockHandle)

            datamap.numDims="";
            datamap.table="";
            bpsource=get_param(blockHandle,'BreakpointsDataSource');
            if(strcmp(bpsource,'Input port'))
                datamap.axes="Input port";
            else
                datamap.axes="BreakpointsData";
            end
            datamap.type="explicit";
        end

        function datamap=evenDataMap(~)

            datamap.numDims="";
            datamap.table="";
            datamap.axes=["BreakpointsNumPoints","BreakpointsFirstPoint","BreakpointsSpacing"];
            datamap.type="even";
        end

        function datamap=objectDataMap(~)

            datamap.numDims="";
            datamap.table="";
            datamap.axes="BreakpointObject";
            datamap.type="object";
        end
    end
end
