classdef DirectLUModelInfo<FunctionApproximation.internal.datatomodeladapter.ModelInfo








    properties(Constant)
        DirectLUBlockLibraryPath='simulink/Lookup Tables/Direct Lookup Table (n-D)'
        DataTypeConversionSIPrefix='DTC_SI'
        SubtractLibraryPath='simulink/Math Operations/Subtract'
        DelayLibraryPath='simulink/Commonly Used Blocks/Delay'
        SubtractBlockPrefix='SubtractLowerBound'
        LowerBoundCorrectionPrefix='LowerBoundCorrection'
        InputTypeCastPrefix='InDataTypeCast'
        OutputTypeCastPrefix='OutDataTypeCast'
        InputDelayPrefix='DelayIn';
        OutputDelayPrefix='DelayOut';
        ProtectInputWithDTC=true;
    end

    properties(SetAccess=immutable)

        ParameterObjectName=['FunctionApproximation_ParameterObject_',datestr(now,'yyyymmddTHHMMSSFFF')]
        LowerBoundVarName=['FunctionApproximation_LB_',datestr(now,'yyyymmddTHHMMSSFFF')]
    end

    methods
        function update(this,blockData)


            for ii=1:blockData.NumberOfDimensions
                str=FunctionApproximation.internal.getDTOOffString(blockData.InputTypes(ii));
                set_param(getSignalSpecificationPath(this,ii),'OutDataTypeStr',str);
            end

            parameterObject=Simulink.Parameter();
            parameterObject.Value=blockData.Data;
            parameterObject.DataType=tostring(blockData.IntermediateTypes(end));


            this.ModelWorkspace.assignin(this.ParameterObjectName,parameterObject)




            for ii=1:blockData.NumberOfDimensions
                dtcType=numerictype(0,blockData.IntermediateTypes(ii).WordLength,0);
                str=FunctionApproximation.internal.getDTOOffString(dtcType);
                set_param(getDataTypeConversionPath(this,ii),...
                'OutDataTypeStr',str);
                if blockData.NeedsTypeCorrectionForInput(ii)


                    if blockData.InputWLCorrection(ii)==1


                        set_param(getDataTypeConversionSIPath(this,ii),...
                        'OutDataTypeStr',...
                        'fixdt(''boolean'')');
                    else

                        dtcStoredInteger=fixdt(0,blockData.InputWLCorrection(ii),0);
                        set_param(getDataTypeConversionSIPath(this,ii),...
                        'OutDataTypeStr',dtcStoredInteger.tostring());
                    end
                end
            end

            this.ModelWorkspace.assignin(this.LowerBoundVarName,blockData.LowerBounds);
        end

        function blockPath=getDataTypeConversionSIPath(this,portNumber)


            blockName=getDataTypeConversionSIName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function name=getDataTypeConversionSIName(this,portNumber)


            name=[this.DataTypeConversionSIPrefix,int2str(portNumber)];
        end

        function blockPath=getSubtractBlockPath(this,portNumber)

            blockName=getSubtractBlockName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockName=getSubtractBlockName(this,portNumber)

            blockName=[this.SubtractBlockPrefix,int2str(portNumber)];
        end

        function blockPath=getLowerBoundCorrectionBlockPath(this,portNumber)


            blockName=getLowerBoundCorrectionBlockName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function blockName=getLowerBoundCorrectionBlockName(this,portNumber)


            blockName=[this.LowerBoundCorrectionPrefix,int2str(portNumber)];
        end

        function blockPath=getDTCInputIntermediateTypePath(this,portNumber)


            blockName=getDTCInputIntermediateTypeName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function name=getDTCInputIntermediateTypeName(this,portNumber)


            name=[this.InputTypeCastPrefix,int2str(portNumber)];
        end

        function blockPath=getDTCOutputIntermediateTypePath(this)


            blockName=getDTCOutputIntermediateTypeName(this);
            blockPath=[this.ModelName,'/',blockName];
        end

        function name=getDTCOutputIntermediateTypeName(this)


            name=this.OutputTypeCastPrefix;
        end

        function blockPath=getInputDelayPath(this,portNumber)

            blockName=getInputDelayName(this,portNumber);
            blockPath=[this.ModelName,'/',blockName];
        end

        function name=getInputDelayName(this,portNumber)

            name=[this.InputDelayPrefix,int2str(portNumber)];
        end

        function blockPath=getOutputDelayPath(this)

            blockName=getOutputDelayName(this);
            blockPath=[this.ModelName,'/',blockName];
        end

        function name=getOutputDelayName(this)

            name=this.OutputDelayPrefix;
        end
    end
end
