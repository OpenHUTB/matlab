classdef QuantizedEvenSpacingCartesianGrid<FunctionApproximation.internal.gridcreator.GridingStrategy






    properties(Access=protected)
        UseLUTSettings logical;
    end

    methods
        function this=QuantizedEvenSpacingCartesianGrid(dataTypes,useLUTSettings)
            if(nargin<2)
                useLUTSettings=false;
            end
            this=this@FunctionApproximation.internal.gridcreator.GridingStrategy(dataTypes);
            this.UseLUTSettings=useLUTSettings;
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

                v=fixed.internal.math.evenspace(ulo,uhi,numberOfGridPoints(ii),false);

                grid{ii}=double(v);
            end
        end
    end
end


