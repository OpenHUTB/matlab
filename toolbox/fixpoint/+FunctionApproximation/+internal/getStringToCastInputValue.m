function castInputString=getStringToCastInputValue(inputType,breakpointType)





    castInputValueString=convertStringsToChars(strings(numel(inputType),1));

    for i=1:numel(inputType)

        castInputValueString{i}=FunctionApproximation.internal.castinputvaluestring.StringToCastInputValue.getStringToCastInputValue(inputType(i),breakpointType(i),i);

        if inputType(i).isscalingslopebias
            castInputValueString{i}=FunctionApproximation.internal.castinputvaluestring.StringToCastSlopeBiasInputValue.getStringToCastInputValue(inputType(i),breakpointType(i),i);
        end
    end
    castInputString=[castInputValueString{:}];
end
