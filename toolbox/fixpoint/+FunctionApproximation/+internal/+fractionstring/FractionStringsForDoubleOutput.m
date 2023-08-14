classdef FractionStringsForDoubleOutput<FunctionApproximation.internal.fractionstring.FractionStrings




    methods(Static)
        function varargout=getFractionStrings(~)
            varargout{1}='fracType = coder.const(double([]));';
            varargout{2}='frac(:) = numerator * denominatorReciprocal;';
        end
    end
end