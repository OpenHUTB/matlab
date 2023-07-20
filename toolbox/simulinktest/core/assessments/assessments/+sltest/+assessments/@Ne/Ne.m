


classdef(Sealed)Ne<sltest.assessments.BinaryNumeric
    methods
        function self=Ne(left,right)
            try
                [left,right]=sltest.assessments.Ne.validateInputs(mfilename(),left,right);
            catch ME
                ME.throwAsCaller();
            end
            self@sltest.assessments.BinaryNumeric(left,right);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.left.internal~=self.right.internal;
        end
    end
end
