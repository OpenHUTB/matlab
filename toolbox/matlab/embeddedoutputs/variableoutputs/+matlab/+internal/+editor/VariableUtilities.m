classdef VariableUtilities






    properties(Constant)
        VARIABLE_STRING_OUTPUT_TYPE='variableString'
    end

    methods(Static,Hidden)












        function header=getHeader(variableValue)
            import matlab.internal.editor.VariableUtilities

            header='';






            if VariableUtilities.showHeader(variableValue)
                header=matlab.internal.display.getHeader(variableValue,'class="headerDataType"');
                header=strtrim(header);
            end
        end


        function showHeader=showHeader(variableValue)
            valueIsObject=isobject(variableValue);
            isMatrixDisplay=isa(variableValue,...
            'matlab.mixin.internal.MatrixDisplay');
            isTabular=isa(variableValue,'tabular');

            showHeader=~valueIsObject||(valueIsObject&&...
            (isMatrixDisplay||isTabular));
        end



        function result=isValidStructOrClassName(variableName)
            structOrClassName=DataTipUtilities.getStructOrClassName(variableName);
            result=isvarname(structOrClassName);
        end



        function variableString=trimVariableValue(variableName,valueString,header,isStringOrChar)
            import matlab.internal.editor.VariableUtilities



            if~isempty(header)
                regexWithoutVarName='[\n\r]*[^\n\r]*[\n\r]*(.*)';
            else
                regexWithoutVarName='[\n\r]*(.*)';
            end

            regexWithVarName=['[\n\r]*',variableName,'[\s*]=[\s*]',regexWithoutVarName];
            variableString=VariableUtilities.getVariableValue(valueString,...
            regexWithVarName,regexWithoutVarName);

            if isempty(header)&&isStringOrChar
                variableString=VariableUtilities.trimSingleLineOutputs(variableString);
            end
        end



        function variableString=getVariableValue(valueString,...
            regexWithVariableName,regexWithoutVariableName)

            variableValue=regexp(valueString,...
            regexWithVariableName,'tokens');

            if isempty(variableValue)
                variableValue=regexp(valueString,...
                regexWithoutVariableName,'tokens');
            end

            variableString=variableValue{1}{1};
        end




        function variableString=trimSingleLineOutputs(variableString)
            trimmedVariableString=strtrim(variableString);
            newLineChars=find(trimmedVariableString==char(10)|...
            trimmedVariableString==char(13));

            if isempty(newLineChars)
                variableString=trimmedVariableString;
            end
        end
    end
end
