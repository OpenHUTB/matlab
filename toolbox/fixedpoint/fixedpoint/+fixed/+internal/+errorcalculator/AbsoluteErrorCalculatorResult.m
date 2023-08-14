classdef AbsoluteErrorCalculatorResult<fixed.internal.errorcalculator.ErrorCalculatorResult&matlab.mixin.CustomDisplay







    properties(SetAccess={?fixed.internal.errorcalculator.AbsoluteErrorCalculator,...
        ?fixed.internal.errorcalculator.AbsoluteErrorCalculatorResult})
Error
ErrorInDouble
AbsoluteError
AbsoluteErrorInDouble
AbsoluteErrorValueTypes
    end

    methods(Access=protected)
        function s=getFooter(this)
            s='';
            hasInfs=any(this.AbsoluteErrorValueTypes.Infs,'all');
            hasNans=any(this.AbsoluteErrorValueTypes.NaNs,'all');
            if hasInfs
                s=sprintf('%s\n\tThere are infs in the result for absolute error.',s);
            end
            if hasNans
                s=sprintf('%s\n\tThere are nans in the result for absolute error.',s);
            end
            if~isempty(s)
                s=sprintf('%s\n\tSee AbsoluteErrorValueTypes.\n',s);
            end
        end
    end
end


