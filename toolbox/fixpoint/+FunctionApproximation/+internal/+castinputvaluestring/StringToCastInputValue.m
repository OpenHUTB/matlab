classdef StringToCastInputValue<FunctionApproximation.internal.castinputvaluestring.StringToCastInput




    methods(Static)
        function castInputString=getStringToCastInputValue(inputType,~,inputNumber)
            castInputString=[newline,'inputValues',num2str(inputNumber),' = cast(inputValues',num2str(inputNumber),',''like'',',...
            mat2str(fixed.internal.math.castUniversal([],inputType.numerictype,false),'class'),');',newline];
        end
    end
end
