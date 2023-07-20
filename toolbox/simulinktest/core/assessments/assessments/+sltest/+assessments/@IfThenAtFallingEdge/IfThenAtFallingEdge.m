


classdef(Sealed)IfThenAtFallingEdge<sltest.assessments.BinaryDuration
    properties(SetAccess=immutable,Hidden)
fallingEdgeCondition
isDiscreteTrigger
    end

    methods
        function self=IfThenAtFallingEdge(left,right,fallingEdgeCondition,duration,isDiscreteTrigger)
            self@sltest.assessments.BinaryDuration(left,right,duration);
            self.fallingEdgeCondition=fallingEdgeCondition;
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
            internal=alias(self.left.internal.implies(self.fallingEdgeCondition.internal.until([0,self.duration],~self.fallingEdgeCondition.internal&self.right.internal)),...
            ifkeyword,' ',self.left.internal,' then, starting from falling edge of trigger, ',self.right.internal);
        end
    end
end
