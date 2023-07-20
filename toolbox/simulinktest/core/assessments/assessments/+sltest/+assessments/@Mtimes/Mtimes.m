


classdef(Sealed)Mtimes<sltest.assessments.BinaryNumeric
    methods
        function self=Mtimes(left,right)
            try
                [left,right]=sltest.assessments.Mtimes.validateInputs(mfilename(),left,right);
            catch ME
                ME.throwAsCaller();
            end
            self@sltest.assessments.BinaryNumeric(left,right);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.left.internal*self.right.internal;
        end
    end
end
