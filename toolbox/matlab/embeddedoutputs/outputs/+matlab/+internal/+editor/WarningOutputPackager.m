classdef(Sealed,Hidden)WarningOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)



        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,~,~)
            import matlab.internal.editor.DiagnosticOutputUtilities

            outputType='warning';


            lineNumbers=[];




            if evalStruct.payload.wasDisabled
                outputData=[];
                return;
            end




            cleanMessage=DiagnosticOutputUtilities.cleanMessage(evalStruct.payload.message);



            outputData.text=[getString(message('MATLAB:matrix:warning_message_prefix'))...
            ,' ',cleanMessage];
        end
    end
end
