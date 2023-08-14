classdef(Abstract)DBUnit<matlab.mixin.Heterogeneous






    properties(Dependent)
        ConstraintMet(1,:)logical
        IndividualConstraintMet(1,:)logical
    end

    properties
        ConstraintValue(1,:)double
        ConstraintValueMustBeLessThan(1,:)double
        ObjectiveValue(1,:)double
        ID(1,:)double
    end

    methods
        function flag=get.ConstraintMet(this)
            flag=all(this.IndividualConstraintMet);
        end

        function flag=get.IndividualConstraintMet(this)
            flag=true(size(this.ConstraintValue));
            for k=1:numel(flag)
                cVal=this.ConstraintValue(k);
                if isnan(cVal)||isinf(cVal)
                    flag(k)=false;
                else
                    upperBound=this.ConstraintValueMustBeLessThan(k);
                    flag(k)=(cVal<=upperBound);
                end
            end
        end
    end

    methods(Abstract)
        header=getHeader(this)
        tableFormatSpec=getFormatSpec(this)
        hexString=getHexString(this,varargin);
    end
end
