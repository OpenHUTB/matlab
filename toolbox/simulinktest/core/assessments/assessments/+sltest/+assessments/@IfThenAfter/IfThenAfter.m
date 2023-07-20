


classdef(Sealed)IfThenAfter<sltest.assessments.BinaryDuration
    properties(SetAccess=immutable,Hidden)
isDiscreteTrigger
fromLabel
    end
    methods
        function self=IfThenAfter(left,right,duration,fromLabel,isDiscreteTrigger)
            self@sltest.assessments.BinaryDuration(left,right,duration);
            self.fromLabel=fromLabel;
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
            internal=alias(self.left.internal.implies(self.right.internal.shift(self.duration)),ifkeyword,' ',self.left.internal,' then, starting from ',self.fromLabel,' (after ',self.duration,' seconds has elapsed), ',self.right.internal);
        end
    end
end
