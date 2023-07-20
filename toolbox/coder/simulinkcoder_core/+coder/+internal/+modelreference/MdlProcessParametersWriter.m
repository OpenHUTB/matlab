




classdef MdlProcessParametersWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
TunableParameters
        NumberOfTunableParameters=0;
    end


    methods(Access=public)
        function this=MdlProcessParametersWriter(tunableParams,modelInterfaceUtils,codeInfoUtils,writer,functionInterfaces)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterfaces,modelInterfaceUtils,codeInfoUtils,writer);
            this.TunableParameters=coder.internal.modelreference.TunableParameters(this.CodeInfo,modelInterfaceUtils);
            this.TunableParameters=tunableParams.getParameters;
            this.NumberOfTunableParameters=length(this.TunableParameters);
        end


        function write(this)




            if(this.NumberOfTunableParameters>0||length(this.FunctionInterfaces)>1)
                this.writeFunctionHeader(this.FunctionInterfaces);
                this.writeFunctionBody;
                this.writeFunctionTrailer;
            end
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlProcessParameters(SimStruct *S)';
        end

        function writeFunctionHeader(this,functionInterface)
            this.Writer.writeLine('\n#define MDL_PROCESS_PARAMETERS\n');
            this.Writer.writeLine('\n#if defined(MATLAB_MEX_FILE)\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this,functionInterface);
        end

        function writeFunctionBody(this,~)
            if(this.NumberOfTunableParameters>0)
                this.declareTunableVariables;
                this.updateTunableVariables;
            elseif(length(this.FunctionInterfaces)>1)






                actualArguments=this.FunctionInterfaceUtils.getActualArguments(this.FunctionInterfaces);
                parameterIndices=this.declareFunctionArguments(actualArguments);
                if(~isempty(parameterIndices))
                    this.declareMultiInstanceVariables;
                    this.writeModelArguments(actualArguments,parameterIndices);
                    this.Writer.writeLine('%s;',this.FunctionInterfaces(2).getFunctionCall);
                end
            end
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
            this.Writer.writeLine('\n#endif\n');
        end
    end


    methods(Access=private)
        function declareTunableVariables(this)
            for paramIdx=1:this.NumberOfTunableParameters
                dataInterface=this.TunableParameters(paramIdx);
                dataType=this.DataTypeUtils.getBaseType(dataInterface.Implementation.Type);
                this.declareVariable('',dataType.Identifier,this.getVariableName(paramIdx),'NULL');
            end
        end


        function updateTunableVariables(this)
            for paramIdx=1:this.NumberOfTunableParameters
                dataInterface=this.TunableParameters(paramIdx);
                dataType=dataInterface.Implementation.Type;
                baseType=this.DataTypeUtils.getBaseType(dataInterface.Implementation.Type);
                paramName=this.getVariableName(paramIdx);
                this.Writer.writeLine('if (!ssGetModelRefGlobalParamData(S, %d, (void **)(&%s)))',paramIdx-1,paramName);
                this.Writer.writeLine('return;');
                if dataType.isMatrix
                    numberOfElements=prod(dataType.Dimensions);
                    if(numberOfElements==1)
                        blockSizeString=sprintf('sizeof(%s)',baseType.Identifier);
                    else
                        blockSizeString=sprintf('sizeof(%s) * %d',baseType.Identifier,numberOfElements);
                    end
                else
                    blockSizeString=sprintf('sizeof(%s)',baseType.Identifier);
                end


                this.Writer.writeLine('if (%s != NULL) {',paramName);
                this.Writer.writeLine('(void) memcpy(%s, %s, %s);',...
                dataInterface.Implementation.getAddress,paramName,blockSizeString);
                this.Writer.writeLine('}');
            end
        end
    end


    methods(Static,Access=private)
        function paramName=getVariableName(paramIdx)
            paramName=sprintf('GlobalPrm_%d',paramIdx-1);
        end
    end
end


