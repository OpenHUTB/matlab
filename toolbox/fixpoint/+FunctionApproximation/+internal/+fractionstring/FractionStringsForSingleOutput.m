classdef FractionStringsForSingleOutput<FunctionApproximation.internal.fractionstring.FractionStrings




    methods(Static)
        function varargout=getFractionStrings(~)
            varargout{1}='fracType = coder.const(single([]));';
            varargout{2}='frac(:) = numerator * denominatorReciprocal;';
        end
    end
end