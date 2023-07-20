classdef BlockParameterValidator<handle




    methods(Static=true,Hidden)
    end
    methods(Access='private')

        function ret=isInRangeNonIncl(h,value,range)
            ret=(value>range(1))&&(value<range(2));
        end

        function ret=isInRangeIncl(h,value,range)
            ret=(value>=range(1))&&(value<=range(2));
        end

        function ret=isInRangeLowIncl(h,value,range)
            ret=(value>=range(1))&&(value<range(2));
        end

        function ret=isInRangeUppIncl(h,value,range)
            ret=(value>range(1))&&(value<=range(2));
        end

        function ret=isRealScalar(h,value)
            ret=isnumeric(value)&&isscalar(value)&&isreal(value);
        end

        function ret=isRealNonInfNonNaNScalar(h,value)
            ret=h.isRealScalar(value)&&~isinf(value)&&~isnan(value);
        end

        function ret=isIntegerNumber(h,value)
            ret=isequal(mod(value,1),0);
        end

        function checkLegalVariableName(~,value)
            if isequal(value,'Inf')||isequal(value,'pi')||...
                isequal(value,'NaN')

            end
        end
    end
    methods

        function h=BlockParameterValidator()
        end
    end
    methods(Static)

        function isInRange(val,range,errMsg)
            h=soc.internal.BlockParameterValidator;
            if~h.isRealScalar(val)||~h.isInRangeIncl(val,range)
                error(errMsg);
            end
        end

        function isInRangeInclusiveLower(val,range,errMsg)
            h=soc.internal.BlockParameterValidator;
            if~h.isRealScalar(val)||~h.isInRangeLowIncl(val,range)
                error(errMsg);
            end
        end

        function isInRangeInclusiveUpper(val,range,errMsg)
            h=soc.internal.BlockParameterValidator;
            if~h.isRealScalar(val)||~h.isInRangeUppIncl(val,range)
                error(errMsg);
            end
        end

        function isMemberOf(val,validValues,errMsg)
            h=soc.internal.BlockParameterValidator;
            classType=class(validValues);
            if~h.isIntegerNumber(val)||~h.isRealScalar(val)||...
                ~ismember(feval(classType,val),validValues)
                error(errMsg);
            end
        end
    end
end