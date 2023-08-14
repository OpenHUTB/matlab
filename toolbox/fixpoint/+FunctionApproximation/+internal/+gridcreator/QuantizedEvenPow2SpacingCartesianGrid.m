classdef QuantizedEvenPow2SpacingCartesianGrid<FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid







    methods
        function this=QuantizedEvenPow2SpacingCartesianGrid(varargin)
            this=this@FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(varargin{:});
        end
    end

    methods(Access=protected)
        function grid=execute(this,rangeObject,numberOfGridPoints)
            rangeMinimum=rangeObject.Minimum;
            rangeMaximum=rangeObject.Maximum;
            nDimensions=rangeObject.NumberOfDimensions;
            for ii=nDimensions:-1:1
                dataType=this.DataTypes(ii);

                [ulo,uhi]=fixed.internal.math.castToUniquePair(...
                rangeMinimum(ii),...
                rangeMaximum(ii),...
                dataType,true);

                v=fixed.internal.math.evenspace(ulo,uhi,numberOfGridPoints(ii),true);

                grid{ii}=double(v);
            end
        end
    end
end


