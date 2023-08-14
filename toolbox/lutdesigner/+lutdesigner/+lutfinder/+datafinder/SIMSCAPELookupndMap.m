classdef SIMSCAPELookupndMap<lutdesigner.lutfinder.datafinder.InstanceDataMap
    methods(Access=protected)
        function dataMap=blockDataMap(this,blockHandle)
            dataMap.type='explicit';
            dataMap.table='f';
            dataMap.axes=this.explicitBpDataMap(blockHandle);
        end

        function dataSrc=blockDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.proxy.*

            tableValueSrc=this.getParameterSource(blockHandle,dataMap.table);
            tableUnitSrc=this.getParameterSource(blockHandle,string(dataMap.table)+'_unit');
            table=CompoundExplicitMatrix(tableValueSrc,'Unit',tableUnitSrc);
            numdims=length(dataMap.axes);
            axes=cell(1,numdims);
            for idx=1:numdims
                axisValueSrc=this.getParameterSource(blockHandle,dataMap.axes{idx});
                axisUnitSrc=this.getParameterSource(blockHandle,string(dataMap.axes{idx})+'_unit');
                axis=CompoundExplicitMatrix(axisValueSrc,'Unit',axisUnitSrc);
                axes{idx}=axis;
            end
            dataSrc=CompoundLookupTable(axes,table);
        end

        function axes=explicitBpDataMap(this,blockHandle)
            numdims=this.getNumDims(blockHandle);
            axes=strings(1,numdims);
            if numdims>1
                for idx=1:numdims
                    axes(idx)="x"+idx;
                end
            else
                axes(1)="x";
            end
        end

        function numdims=getNumDims(~,blockHandle)
            blockName=get_param(blockHandle,'MaskType');
            numbersInName=regexp(blockName,'\d*','Match');
            numdims=str2double(numbersInName{1});
        end
    end
end