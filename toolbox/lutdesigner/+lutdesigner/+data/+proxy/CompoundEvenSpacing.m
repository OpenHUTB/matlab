classdef CompoundEvenSpacing<lutdesigner.data.proxy.CompoundMatrixParameter

    properties(SetAccess=immutable,GetAccess=private)
FirstPointSource
SpacingSource
    end

    properties(SetAccess=private)
TableProxy
DimensionIndex
    end

    methods
        function this=CompoundEvenSpacing(firstPointSource,spacingSource,varargin)
            this=this@lutdesigner.data.proxy.CompoundMatrixParameter(varargin{:});
            this.FirstPointSource=firstPointSource;
            this.SpacingSource=spacingSource;
        end

        function attachToTableDimension(this,tableProxy,dimensionIndex)
            this.TableProxy=tableProxy;
            this.DimensionIndex=dimensionIndex;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            dataUsage=[
            listDataUsageImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this)
            lutdesigner.data.proxy.DataUsage(this.FirstPointSource,'/Value/FirstPoint')
            lutdesigner.data.proxy.DataUsage(this.SpacingSource,'/Value/Spacing')
            ];
        end


        function restrictions=getValueReadRestrictionsImpl(this)
            restrictions=[
            this.FirstPointSource.getReadRestrictions()
            this.SpacingSource.getReadRestrictions()
            this.TableProxy.getReadRestrictionsFor('Value')
            ];
        end

        function restrictions=getValueWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:evenSpacingWriteLimitation');
        end

        function value=getValueImpl(this)
            firstPoint=this.readNumericSource(this.FirstPointSource);
            spacing=this.readNumericSource(this.SpacingSource);
            numPoints=lutdesigner.data.proxy.internal.getSizeOnDimension(this.TableProxy.Value,this.DimensionIndex);
            value=lutdesigner.data.proxy.internal.populateEvenSpacingValue(firstPoint,spacing,numPoints);
        end

        function setValueImpl(~,~)
        end
    end
end
