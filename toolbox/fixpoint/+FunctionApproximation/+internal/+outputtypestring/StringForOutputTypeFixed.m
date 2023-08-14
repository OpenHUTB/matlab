classdef StringForOutputTypeFixed<FunctionApproximation.internal.outputtypestring.StringsForOutputType



    methods(Static)
        function string=getStringForOutputType(outputType)


            string=['output = zeros(size(inputValues1),''like'',fi([],',outputType.tostring,',f));';];



            fimathString=[newline,'f = fimath(''RoundingMethod'',''Floor'',...',...
            newline,'''OverflowAction'',''Saturate'',...',newline,...
            '''ProductMode'',''SpecifyPrecision'',...',newline,'''ProductWordLength'',',...
            num2str(outputType.WordLength),',...',newline,'''ProductFractionLength'',',...
            num2str(outputType.FractionLength),',...',newline,'''SumMode'',''SpecifyPrecision'',...',...
            newline,'''SumWordLength'',',num2str(outputType.WordLength),',...',newline,...
            '''SumFractionLength'',',num2str(outputType.FractionLength),',...',newline,...
            '''CastBeforeSum'',true);',newline];


            string=[fimathString,string,newline];
        end
    end
end
