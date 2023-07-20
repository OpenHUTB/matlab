classdef LookupndMap<lutdesigner.lutfinder.datafinder.InstanceDataMap

    methods(Access=protected)
        function dataMap=blockDataMap(this,blockHandle)

            dataspec=get_param(blockHandle,'DataSpecification');
            if strcmp(dataspec,'Table and breakpoints')
                dataMap=this.tableAndBreakpointsDataMap(blockHandle);
            else
                dataMap=this.objectDataMap();
            end
        end

        function dataSrc=blockDataSrc(this,dataMap,blockHandle)

            mode=dataMap.type;

            if strcmp(mode,'object')
                dataSrc=this.objectDataSrc(dataMap,blockHandle);
            elseif strcmp(mode,'explicit')
                dataSrc=this.explicitDataSrc(dataMap,blockHandle);
            else
                dataSrc=this.evenDataSrc(dataMap,blockHandle);
            end
        end

        function dataSrc=objectDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.LookupTableObject

            lutoSrc=this.getParameterSource(blockHandle,dataMap.table);
            dataSrc=LookupTableObject(lutoSrc);
        end

        function dataSrc=explicitDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.CompoundLookupTable

            tableSrc=this.getExplicitMatrixParameterSource(blockHandle,dataMap.table);
            table=this.createMatrixParameterProxy(tableSrc);
            numdims=str2double(get_param(blockHandle,dataMap.numdims));
            axes=cell(1,numdims);
            for idx=1:numdims
                axisSrc=this.getExplicitMatrixParameterSource(blockHandle,dataMap.axes{idx});
                axis=this.createMatrixParameterProxy(axisSrc);
                axes{idx}=axis;
            end
            dataSrc=CompoundLookupTable(axes,table);
        end

        function dataSrc=evenDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.CompoundLookupTable
            import lutdesigner.data.proxy.CompoundEvenSpacing

            tableSrc=this.getExplicitMatrixParameterSource(blockHandle,dataMap.table);
            table=this.createMatrixParameterProxy(tableSrc);
            numdims=str2double(get_param(blockHandle,dataMap.numdims));
            axes=cell(1,numdims);
            for idx=1:numdims
                axisFirstPointSrc=this.getParameterSource(blockHandle,dataMap.axes{idx}(1));
                axisSpacingSrc=this.getParameterSource(blockHandle,dataMap.axes{idx}(2));
                axis=CompoundEvenSpacing(axisFirstPointSrc,axisSpacingSrc);
                axes{idx}=axis;
            end
            dataSrc=CompoundLookupTable(axes,table);
        end

        function datamap=tableAndBreakpointsDataMap(this,blockHandle)
            bpspec=get_param(blockHandle,'BreakpointsSpecification');
            numdims=str2double(get_param(blockHandle,'NumberOfTableDimensions'));
            datamap.numdims='NumberOfTableDimensions';
            tableViaInput=get_param(blockHandle,'TableSource');
            if strcmp(tableViaInput,'Input port')
                datamap.table='Input port';
            else
                datamap.table='Table';
            end
            if(strcmp(bpspec,'Explicit values'))
                datamap.type='explicit';
                datamap.axes=this.explicitBpDataMap(numdims,blockHandle);
            else
                datamap.type='even';
                datamap.axes=this.evenBpDataMap(numdims);
            end
        end

        function axes=explicitBpDataMap(~,numdims,blockHandle)

            blockObject=get_param(blockHandle,'Object');
            axes=strings(1,numdims);
            for idx=1:numdims
                bpSource="BreakpointsForDimension"+idx+"Source";
                if blockObject.isValidProperty(bpSource)&&strcmp(blockObject.(bpSource),'Input port')
                    axes(idx)='Input port';
                else
                    axes(idx)="BreakpointsForDimension"+idx;
                end
            end
        end

        function axes=evenBpDataMap(~,numdims)

            axes=cell(1,numdims);
            for idx=1:numdims
                axes{idx}=["BreakpointsForDimension"+idx+"FirstPoint",...
                "BreakpointsForDimension"+idx+"Spacing"];
            end
        end

        function datamap=objectDataMap(~)

            datamap.numdims="NumberOfTableDimensions";
            datamap.table="LookupTableObject";
            datamap.axes=[];
            datamap.type="object";
        end
    end

    methods(Access=private)
        function dataSource=getExplicitMatrixParameterSource(this,blockHandle,sourceLocation)
            if strcmp(sourceLocation,'Input port')
                dataSource=lutdesigner.data.source.UnknownDataSource('lutdesigner:data:parameterPortSupportLimitation');
            else
                dataSource=this.getParameterSource(blockHandle,sourceLocation);
            end
        end
    end
end
