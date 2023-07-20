classdef RangeConditionsInterface<handle















    properties(SetAccess=protected)
rangesStrategy
    end

    methods
        function flags=performCheck(this,object)



            [rangesMin,rangesMax]=this.rangesStrategy.getRanges(object);


            flags=false(length(rangesMin),1);


            if this.rangesStrategy.isConditionActive()


                flags=this.checkCondition(rangesMin,rangesMax,this.rangesStrategy.containerInfo);
            end
        end
    end

    methods(Abstract)
        flags=checkCondition(this,rangesMin,rangesMax,containerInfo)
    end

end

