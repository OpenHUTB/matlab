classdef(Sealed)DimensionSpecificValidationDataBase<handle








    properties(SetAccess=private)
DimensionValidityMap
    end

    methods
        function this=DimensionSpecificValidationDataBase()
            this.DimensionValidityMap=containers.Map('KeyType','double','ValueType','any');
        end

        function registerValidity(this,iDim,compositeValidity,childValidity)
            validity=[compositeValidity,childValidity(:)'];
            this.DimensionValidityMap(iDim)=validity;
        end

        function flag=areAllValid(this)
            flag=all(cellfun(@(x)x(1),this.DimensionValidityMap.values,'UniformOutput',true));
        end

        function flag=isValidForDim(this,iDim)
            value=this.DimensionValidityMap(iDim);
            flag=value(1);
        end

        function validity=getChildValidity(this,iDim)
            value=this.DimensionValidityMap(iDim);
            validity=value(2:end);
        end
    end
end