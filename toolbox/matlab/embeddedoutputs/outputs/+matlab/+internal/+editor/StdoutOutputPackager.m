classdef(Sealed,Hidden)StdoutOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)


        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,~,~)
            import matlab.internal.editor.StdoutOutputPackager

            valueString=evalStruct.payload;

            [valueString,truncationInfo]=StdoutOutputPackager.applyStdOutSizeLimits(valueString);

            outputData=struct(...
            'text',valueString,...
            'truncationInfo',truncationInfo...
            );

            outputType='text';


            lineNumbers=[];
        end
    end

    methods(Static,Hidden)
















        function[truncatedString,truncationInfo]=applyStdOutSizeLimits(string)
            import matlab.internal.editor.OutputPackagerUtilities
            import matlab.internal.editor.StdoutOutputPackager

            if length(string)>OutputPackagerUtilities.MAX_STRING_LENGTH
                truncatedString=string(1:(OutputPackagerUtilities.MAX_STRING_LENGTH));
                truncationInfo=struct('wasTruncatedAtLineBreak',false,'wasTruncatedMidLine',true);
            else
                truncatedString=string;
                truncationInfo=struct('wasTruncatedAtLineBreak',false,'wasTruncatedMidLine',false);
            end
        end
    end
end
