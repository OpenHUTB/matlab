classdef(Sealed)RelativeErrorCalculatorResult<fixed.internal.errorcalculator.AbsoluteErrorCalculatorResult





    properties(SetAccess={?fixed.internal.errorcalculator.RelativeErrorCalculator,...
        ?fixed.internal.errorcalculator.RelativeErrorCalculatorResult})
RelativeError
RelativeErrorInDouble
RelativeErrorBitsOfAccuracy
RelativeErrorValueTypes
    end

    properties(Dependent)
RelativeErrorDigitsOfAccuracy
    end

    methods
        function transferData(this,absErrorResult)
            mc=metaclass(absErrorResult);
            props={mc.PropertyList.Name};
            for i=1:numel(props)
                this.(props{i})=absErrorResult.(props{i});
            end
        end

        function digits=get.RelativeErrorDigitsOfAccuracy(this)
            digits=max(round(this.RelativeErrorBitsOfAccuracy*log10(2)),1);
        end
    end

    methods(Access=protected)
        function s=getFooter(this)
            s='';
            hasInfs=any(this.RelativeErrorValueTypes.Infs,'all');
            hasNans=any(this.RelativeErrorValueTypes.NaNs,'all');
            if hasInfs
                s=sprintf('%s\n\tThere are infs in the result for relative error.',s);
            end
            if hasNans
                s=sprintf('%s\n\tThere are nans in the result for relative error.',s);
            end
            if~isempty(s)
                s=sprintf('%s\n\tSee RelativeErrorValueTypes.\n',s);
            end
            s=sprintf('%s%s',s,getFooter@fixed.internal.errorcalculator.AbsoluteErrorCalculatorResult(this));
        end
    end
end


