classdef FractionStringsForFixedOutput<FunctionApproximation.internal.fractionstring.FractionStrings




    methods(Static)
        function varargout=getFractionStrings(fracType)
            varargout{1}=['fracType = coder.const(',fracType.tostring,');'];
            varargout{2}='frac(:) = numerator * denominatorReciprocal;';
        end
    end
end
