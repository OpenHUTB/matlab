classdef(Abstract)Interface<handle






    properties(SetAccess=private)
Context
    end
    methods
        function rangeBits=getRangeBits(this,context)
            this.Context=context;
            if isempty(getWordLengths(this.Context))||isempty(getFractionLengths(this.Context))

                rangeBits=Inf;
            else
                rangeBits=0;
            end
        end
    end
end


