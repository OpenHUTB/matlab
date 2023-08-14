


classdef(Sealed)IfThenAtRisingEdge<sltest.assessments.Binary
    properties(SetAccess=immutable,Hidden)
isDiscreteTrigger
    end
    methods
        function self=IfThenAtRisingEdge(left,right,isDiscreteTrigger)
            self@sltest.assessments.Binary(left,right);
            self.isDiscreteTrigger=isDiscreteTrigger;
            self=self.initializeInternal();
        end


        function res=getResultData(self,startTime,endTime)
            res=self.internal.resultsIf(self.left.internal,startTime,endTime);
            assert(length(res.Time)>1||startTime==endTime||(isinf(startTime)&&isinf(endTime)));
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            if self.isDiscreteTrigger
                ifkeyword='if';
            else
                ifkeyword='whenever';
            end
            internal=alias(self.left.internal.implies(self.right.internal),ifkeyword,' ',self.left.internal,' then, starting from rising edge of trigger, ',self.right.internal);
        end
    end
end
