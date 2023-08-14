classdef CompoundStandaloneEvenSpacing<lutdesigner.data.proxy.CompoundMatrixParameter

    properties(SetAccess=immutable,GetAccess=private)
FirstPointSource
SpacingSource
NumPointsSource
    end

    methods
        function this=CompoundStandaloneEvenSpacing(firstPointSource,spacingSource,numPointsSource,varargin)
            this=this@lutdesigner.data.proxy.CompoundMatrixParameter(varargin{:});
            this.FirstPointSource=firstPointSource;
            this.SpacingSource=spacingSource;
            this.NumPointsSource=numPointsSource;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            dataUsage=[
            listDataUsageImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this)
            lutdesigner.data.proxy.DataUsage(this.FirstPointSource,'/Value/FirstPoint')
            lutdesigner.data.proxy.DataUsage(this.SpacingSource,'/Value/Spacing')
            lutdesigner.data.proxy.DataUsage(this.NumPointsSource,'/Value/NumPoints')
            ];
        end


        function restrictions=getValueReadRestrictionsImpl(this)
            restrictions=[
            this.FirstPointSource.getReadRestrictions()
            this.SpacingSource.getReadRestrictions()
            this.NumPointsSource.getReadRestrictions()
            ];
        end

        function restrictions=getValueWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:evenSpacingWriteLimitation');
        end

        function value=getValueImpl(this)
            firstPoint=this.readNumericSource(this.FirstPointSource);
            spacing=this.readNumericSource(this.SpacingSource);
            numPoints=this.readNumericSource(this.NumPointsSource);
            value=lutdesigner.data.proxy.internal.populateEvenSpacingValue(firstPoint,spacing,numPoints);
        end

        function setValueImpl(~,~)
        end
    end
end
