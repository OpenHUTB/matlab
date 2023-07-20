classdef(Sealed,Hidden)VariableOutputPackager<matlab.internal.editor.BaseOutputPackager





    methods(Static)



        function[outputType,outputData,lineNumbers]=packageOutput(evalStruct,editorId,requestId)



            storeVariable=~isempty(requestId);
            isPreview=~storeVariable;



            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.VariableUtilities

            variableName=evalStruct.payload.name;
            variableValue=evalStruct.payload.value;

            isValidVarName=isvarname(variableName)||...
            VariableUtilities.isValidStructOrClassName(variableName);

            header=VariableUtilities.getHeader(variableValue);


            lineNumbers=[];





            if isa(variableValue,'matlab.mixin.CustomDisplay')&&isValidVarName

                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
            elseif isempty(variableValue)&&isValidVarName


                valueString=VariableOutputPackager.isolatedDisplaying(variableName,variableValue);
                [valueString,truncationInfo]=VariableOutputPackager.applySizeLimits(...
                valueString);





                outputData.text=valueString;
                outputData.truncationInfo=truncationInfo;
                outputType='text';
            elseif InteractiveVariablesPackager.isInteractiveOutput(variableValue)&&isValidVarName
                [outputType,outputData]=InteractiveVariablesPackager.packageVarInteractive(variableName,variableValue,...
                header,editorId,storeVariable,isPreview,requestId);
            elseif isenum(variableValue)&&isValidVarName


                [outputType,outputData]=VariableOutputPackager.packageVarEnum(variableName,...
                variableValue,header);
            elseif isa(variableValue,'numeric')&&~isobject(variableValue)&&isValidVarName
                [outputType,outputData]=VariableOutputPackager.packageVarNumeric(editorId,...
                variableName,variableValue,header,storeVariable,isPreview,requestId);
            elseif(isa(variableValue,'sym')||isa(variableValue,'symfun'))


                [outputType,outputData]=VariableOutputPackager.packageVarSym(variableName,...
                variableValue,header);



            elseif hasDispOverride(variableValue)&&isValidVarName
                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
            elseif isjava(variableValue)
                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
            elseif InteractiveVariablesPackager.isInteractiveObjectArray(variableValue)&&...
                isValidVarName&&...
                InteractiveVariablesPackager.isValidArrayType(variableValue)
                [outputType,outputData]=InteractiveVariablesPackager.packageVarInteractive(variableName,variableValue,...
                header,editorId,storeVariable,isPreview,requestId);
            elseif isValidVarName
                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
            else



                [outputType,outputData,lineNumbers]=VariableOutputPackager.convertAndPackageVarAsStdout(evalStruct,editorId,requestId);
            end

        end
    end

    methods(Static,Hidden)












        function[truncatedString,wasTruncatedMidLine,wasTruncatedAtLineBreak]=limitStringLength(string)
            import matlab.internal.editor.OutputPackagerUtilities

            wasTruncatedMidLine=false;
            wasTruncatedAtLineBreak=false;

            if length(string)>OutputPackagerUtilities.MAX_STRING_LENGTH
                truncatedString=string(1:OutputPackagerUtilities.MAX_STRING_LENGTH);


                lastNewLine=find(truncatedString==newline|truncatedString==char(13),1,'last');

                if isempty(lastNewLine)
                    wasTruncatedMidLine=true;
                else


                    if truncatedString(lastNewLine)==10&&lastNewLine>1&&truncatedString(lastNewLine-1)==13
                        lastNewLine=lastNewLine-1;
                    end
                    truncatedString=truncatedString(1:lastNewLine-1);
                    wasTruncatedAtLineBreak=true;
                end

            else
                truncatedString=string;
            end
        end





















        function[truncatedString,truncationInfo]=applySizeLimits(string)
            import matlab.internal.editor.VariableOutputPackager

            [truncatedString,wasTruncatedMidLine,wasTruncatedAtLineBreak]=VariableOutputPackager.limitStringLength(string);

            truncationInfo.wasTruncatedMidLine=wasTruncatedMidLine;
            truncationInfo.wasTruncatedAtLineBreak=wasTruncatedAtLineBreak;
        end

        function[truncatedString,truncationInfo]=getTruncatedStringFromVar(variableName,variableValue,header)




            import matlab.internal.editor.VariableOutputPackager;

            valueString=VariableOutputPackager.getStringFromVar(variableName,variableValue,header);
            [truncatedString,truncationInfo]=VariableOutputPackager.applySizeLimits(valueString);
        end

        function valueString=getStringFromVar(variableName,variableValue,header)





            import matlab.internal.editor.VariableOutputPackager;
            import matlab.internal.editor.VariableUtilities



            if~isvarname(variableName)&&...
                ~VariableUtilities.isValidStructOrClassName(variableName)
                valueString='';
                return;
            end






            cmdRows=com.mathworks.mde.cmdwin.XCmdWndView.getInstance.getPotentialRows();
            cmdCols=com.mathworks.mde.cmdwin.XCmdWndView.getInstance.getPotentialColumns();
            com.mathworks.mde.cmdwin.CmdWinMLIF.setCWSize(1e4,1e4);

            valueString=VariableOutputPackager.isolatedDisplaying(variableName,variableValue);



            valueString=valueString(1:end-1);



            isStringOrChar=isstring(variableValue)||ischar(variableValue);
            valueString=VariableUtilities.trimVariableValue(variableName,valueString,header,isStringOrChar);



            com.mathworks.mde.cmdwin.CmdWinMLIF.setCWSize(cmdRows,cmdCols);
        end

        function valueString=isolatedDisplaying(variableName,variableValue)%#ok<INUSD>








            if strcmp(variableName,'variableName')


                eval('variableName = variableValue;');
                valueString=evalc('display(variableName);');
            elseif strcmp(variableName,'evalc')
                import matlab.internal.editor.VariableOutputPackager.*;
                valueString=isolatedDisplayingEvalcHelper(variableValue);
            else
                eval([variableName,' = variableValue;']);
                valueString=evalc(['display(',variableName,');']);
            end
        end

        function[outputType,outputData,lineNumbers]=convertAndPackageVarAsStdout(evalStruct,editorId,requestId)
            import matlab.internal.editor.OutputPackagerUtilities

            outputType=OutputPackagerUtilities.CONVERT_OUTPUT;
            evalStruct.type=OutputPackagerUtilities.STRUCT_EVAL_STDOUT_TYPE;
            evalStruct.payload=evalc('display(evalStruct.payload.value)');
            outputData=evalStruct;
            lineNumbers=[];
        end

        function flag=isDefaultFormat
            fmt=get(0,'format');
            flag=strcmp(fmt,'short');
        end

        function[outputType,outputData]=packageVarOther(variableName,variableValue,header)



            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.VariableUtilities
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;



            outputData.name=variableName;
            outputData.header=header;
            outputData.rows=1;
            outputData.columns=1;
            try
                [valueString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);
                outputData.value=valueString;
                outputData.truncationInfo=truncationInfo;
            catch e
                [outputType,outputData]=VariableOutputPackager.packageOutputException(e);
            end
        end
    end

    methods(Static,Access=private)
        function[outputType,outputData]=packageVarNumeric(editorId,variableName,...
            variableValue,header,storeVariable,...
            isPreview,requestId)



            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.VariableOutputPackager




            unsupportedFormat=issparse(variableValue)||(isscalar(variableValue)&&~VariableOutputPackager.isDefaultFormat)||strcmp(get(0,'format'),'rational');
            if unsupportedFormat
                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
                return;
            end

            if isscalar(variableValue)

                summaryValue=VariableManager.getSummaryValue(variableValue);
                outputData.name=variableName;
                outputData.value=char(summaryValue.toString());
                outputData.header=header;
                outputData.rows=1;
                outputData.columns=1;
                outputType='variable';
            elseif ismatrix(variableValue)
                [outputType,outputData]=InteractiveVariablesPackager.packageVarNumeric(variableName,variableValue,...
                header,editorId,storeVariable,isPreview,requestId);
            else

                [outputType,outputData]=VariableOutputPackager.packageVarOther(variableName,...
                variableValue,header);
            end
        end

        function[outputType,outputData]=packageVarCell(variableName,variableValue,...
            header)


            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.VariableUtilities

            [valueString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);

            outputData.name=variableName;
            outputData.value=valueString;
            outputData.header=header;
            outputData.rows=1;
            outputData.columns=1;
            outputData.truncationInfo=truncationInfo;
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
        end

        function[outputType,outputData]=packageVarSym(variableName,variableValue,header)



            outputData.name=variableName;
            outputData.value=getMathMLForSym(variableValue);
            outputData.header=header;
            outputData.rows=1;
            outputData.columns=1;
            outputType='symbolic';
        end

        function[outputType,outputData]=packageOutputException(e)
            import matlab.internal.editor.OutputPackagerUtilities
            outputException=matlab.internal.editor.OutputPackageException(e);
            payload=struct;
            payload.exception=outputException;
            payload.fullFilePath=outputException.stack.file;
            payload.errorType=matlab.internal.editor.ErrorType.Runtime;
            outputData=struct('type',OutputPackagerUtilities.STRUCT_EVAL_ERROR_TYPE,'payload',payload);
            outputType=OutputPackagerUtilities.CONVERT_OUTPUT;
        end

        function[outputType,outputData]=packageVarEnum(variableName,variableValue,header)

            import matlab.internal.editor.VariableUtilities
            import matlab.internal.editor.VariableOutputPackager

            outputData.name=variableName;
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
            outputData.header=header;
            outputData.rows=1;
            outputData.columns=1;
            try
                [valueString,~]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);
                outputData.value=char(valueString);
            catch e
                [outputType,outputData]=VariableOutputPackager.packageOutputException(e);
            end
        end

        function[outputType,outputData]=packageVarString(variableName,variableValue,header)


            import matlab.internal.editor.VariableOutputPackager
            import matlab.internal.editor.VariableUtilities
            outputType=VariableUtilities.VARIABLE_STRING_OUTPUT_TYPE;
            outputData.name=variableName;
            outputData.header=header;
            outputData.rows=1;
            outputData.columns=1;
            try
                [valueString,truncationInfo]=VariableOutputPackager.getTruncatedStringFromVar(variableName,variableValue,header);
                outputData.value=valueString;
                outputData.truncationInfo=truncationInfo;
            catch e
                [outputType,outputData]=VariableOutputPackager.packageOutputException(e);
            end
        end
    end
end


function out=isolatedDisplayingEvalcHelper(variableValue)
    eval 'evalc = variableValue;';
    out=builtin('evalc','display(evalc);');
end


function hasOverride=hasDispOverride(variableValue)
    mc=metaclass(variableValue);
    mm=findobj(mc.MethodList,"Name","disp");
    hasOverride=~isempty(mm);
end

