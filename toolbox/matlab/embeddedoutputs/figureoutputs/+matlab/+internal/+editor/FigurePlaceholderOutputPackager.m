classdef(Sealed,Hidden)FigurePlaceholderOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)



        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,~,~)

            outputData.figurePlaceHolderId=evalStruct.payload;
            outputType='figure';


            lineNumbers=[];
        end
    end
end
