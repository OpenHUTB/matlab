classdef CompoundLookupTable<lutdesigner.data.proxy.LookupTableProxy

    properties(SetAccess=immutable,GetAccess=private)
AxisProxies
TableProxy
    end

    methods
        function this=CompoundLookupTable(axisProxies,tableProxy)
            for i=1:numel(axisProxies)
                if isa(axisProxies{i},'lutdesigner.data.proxy.CompoundEvenSpacing')
                    axisProxies{i}.attachToTableDimension(tableProxy,i);
                end
            end
            this.AxisProxies=axisProxies(:);
            this.TableProxy=tableProxy;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            bpDataUsage=cellfun(@(x)x.listDataUsage(),this.AxisProxies,'UniformOutput',false);
            for i=1:numel(bpDataUsage)
                for j=1:numel(bpDataUsage{i})
                    bpDataUsage{i}(j).UsedAs=['/Axes/',num2str(i),bpDataUsage{i}(j).UsedAs];
                end
            end
            tableDataUsage=this.TableProxy.listDataUsage();
            for j=1:numel(tableDataUsage)
                tableDataUsage(j).UsedAs=['/Table',tableDataUsage(j).UsedAs];
            end
            dataUsage=vertcat(bpDataUsage{:},tableDataUsage);
        end

        function restrictions=getNumDimsReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction.empty();
        end

        function restrictions=getNumDimsWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:numDimsChangeLimitation');
        end

        function numDims=getNumDimsImpl(this)
            numDims=numel(this.AxisProxies);
        end

        function setNumDimsImpl(~,~)
        end

        function axisProxy=getAxisProxyImpl(this,dimensionIndex)
            axisProxy=this.AxisProxies{dimensionIndex};
        end

        function tableProxy=getTableProxyImpl(this)
            tableProxy=this.TableProxy;
        end
    end
end
