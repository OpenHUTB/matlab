classdef(Abstract)Interface<handle






    properties(SetAccess=protected)
        Context;
    end
    methods
        function signed=getSigned(this)
            signed=getSigned(this.Context);
        end
        function wordLengths=getWordLengths(this)
            wordLengths=getWordLengths(this.Context);
        end
        function fractionLengths=getFractionLengths(this)
            fractionLengths=getFractionLengths(this.Context);
        end
    end
end