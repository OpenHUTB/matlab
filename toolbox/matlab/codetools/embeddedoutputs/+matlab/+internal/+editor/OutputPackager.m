classdef OutputPackager


    methods(Static)

        function outputsMessage=packageOutputs(editorId,requestId,filePath,outputs,completedRegionNumbers)

            import matlab.internal.editor.OutputPackager;
            import matlab.internal.editor.OutputPackagerUtilities;

            batchedOutputs=OutputPackager.packageEachOutput(editorId,requestId,filePath,outputs);


            outputsMessage.completedRegionNumbers=OutputPackagerUtilities.formatForJsonArray(completedRegionNumbers-1);
            outputsMessage.outputs=batchedOutputs;
            outputsMessage.requestId=requestId;
        end

        function packagedOutputs=packageEachOutput(editorId,requestId,filePath,outputs)


            import matlab.internal.editor.OutputPackager;

            outputCount=numel(outputs);
            validOutputCount=0;
            packagedOutputs=cell(outputCount,1);


            for i=1:outputCount
                [packagedOutput,outputGenerated]=OutputPackager.packageOneOutput(editorId,requestId,filePath,outputs{i}.regionLineNumber,outputs{i}.evalStruct);



                if outputGenerated

                    validOutputCount=validOutputCount+1;
                    packagedOutputs{validOutputCount}=packagedOutput;
                end
            end


            packagedOutputs=packagedOutputs(1:validOutputCount);
        end

        function[output,outputGenerated]=packageOneOutput(editorId,requestId,filePath,regionLineNumber,evalStruct)





            import matlab.internal.editor.ErrorOutputPackager
            import matlab.internal.editor.FigureOutputPackager
            import matlab.internal.editor.FigurePlaceholderOutputPackager
            import matlab.internal.editor.OutputPackager
            import matlab.internal.editor.OutputPackagerUtilities
            import matlab.internal.editor.OutputUtilities
            import matlab.internal.editor.StdoutOutputPackager
            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.WarningOutputPackager

            validateattributes(editorId,{'char'},{'nonempty'},'OutputPackager','editorId',1);
            validateattributes(filePath,{'char'},{'nonempty'},'OutputPackager','filePath',2);
            validateattributes(evalStruct,{'struct'},{'nonempty'},'packageOneOutput','evalStruct',5);
            validateattributes(evalStruct.type,{'char'},{'nonempty'},'packageOneOutput','evalStruct.type',5);


            outputGenerated=true;

            switch evalStruct.type
            case OutputPackagerUtilities.STRUCT_EVAL_VARIABLE_TYPE
                [outputType,outputData,lineNumbers]=VariableOutputPackager.packageOutput(evalStruct,editorId,requestId);

            case OutputPackagerUtilities.STRUCT_EVAL_ERROR_TYPE

                [outputType,outputData,lineNumbers]=ErrorOutputPackager.packageOutput(evalStruct,editorId,requestId,regionLineNumber,filePath);

            case OutputPackagerUtilities.STRUCT_EVAL_WARNING_TYPE
                [outputType,outputData,lineNumbers]=WarningOutputPackager.packageOutput(evalStruct,editorId,requestId);


                if isempty(outputData)
                    outputGenerated=false;
                end

            case OutputPackagerUtilities.STRUCT_EVAL_STDOUT_TYPE
                [outputType,outputData,lineNumbers]=StdoutOutputPackager.packageOutput(evalStruct,editorId,requestId);

            case OutputPackagerUtilities.STRUCT_EVAL_STDERR_TYPE

                [outputType,outputData,lineNumbers]=StdoutOutputPackager.packageOutput(evalStruct,editorId,requestId);

            case OutputPackagerUtilities.FIGURE_TYPE
                [outputType,outputData,lineNumbers]=FigureOutputPackager.packageOutput(evalStruct,editorId,requestId);

            case OutputPackagerUtilities.FIGURE_PLACEHOLDER_TYPE

                [outputType,outputData,lineNumbers]=FigurePlaceholderOutputPackager.packageOutput(evalStruct,editorId,requestId);

            otherwise

                str=['Unexpected type in OutputPackager.packageOneOutput: ',evalStruct.type,'.',10...
                ,'Dump of evalStruct: ',10,evalc('disp(evalStruct)'),10];

                if isfield(evalStruct,'payload')
                    str=[str,'Payload of evalStruct: ',10,evalc('disp(evalStruct.payload)')];
                end
                error(str);
            end




            if strcmp(outputType,OutputPackagerUtilities.CONVERT_OUTPUT)
                [output,outputGenerated]=OutputPackager.packageOneOutput(editorId,requestId,filePath,regionLineNumber,outputData);
                return;
            end

            if isempty(lineNumbers)


                lineNumberInFile=OutputUtilities.getLineNumberForExecutingFileFrame(evalStruct.stack,editorId);

                if lineNumberInFile>0

                    lineNumbers=lineNumberInFile;
                elseif regionLineNumber>0






                    lineNumbers=regionLineNumber;
                else




                    lineNumbers=1;
                end
            end

            output=OutputPackager.createOutput(outputType,outputData,lineNumbers);
        end

    end

    methods(Static,Hidden)
        function output=getPackagedOutputForStdout(displayOfVariableValue)
            import matlab.internal.editor.OutputPackager
            import matlab.internal.editor.StdoutOutputPackager

            evalStruct=struct('payload',displayOfVariableValue);
            [outputType,outputData]=StdoutOutputPackager.packageOutput(evalStruct,'','');


            output=OutputPackager.createOutput(outputType,outputData,[1]);
        end

        function output=getPackagedOutputForVar(variableName,variableValue)
            import matlab.internal.editor.OutputPackager
            import matlab.internal.editor.VariableOutputPackager

            payload=struct('name',variableName,'value',{variableValue});
            evalStruct=struct('payload',payload);

            [outputType,outputData]=VariableOutputPackager.packageOutput(evalStruct,'','');

            output=OutputPackager.createOutput(outputType,outputData,[]);
        end
    end

    methods(Static,Access=private)

        function output=createOutput(outputType,outputData,lineNumbers)
            import matlab.internal.editor.OutputPackagerUtilities

            output.type=outputType;
            output.outputData=outputData;
            output.lineNumbers=OutputPackagerUtilities.formatForJsonArray(lineNumbers);
        end
    end
end
