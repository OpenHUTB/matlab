


classdef OutputPortInfoWriter<coder.internal.modelreference.PortInfoWriter
    properties(Access=private)
FcnCallArgWriter
    end


    methods(Access=public)
        function this=OutputPortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter)
            this@coder.internal.modelreference.PortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter);
        end
    end


    methods(Access=public)
        function write(this)
            outputPortsCodeInfo=this.CodeInfo.Outports;
            assert(this.NumberOfPorts==length(outputPortsCodeInfo));
            this.Writer.writeLine('if (!ssSetNumOutputPorts(S, %d)) return;',this.NumberOfPorts);
            for portIdx=1:this.NumberOfPorts
                port=this.Ports{portIdx};
                portCodeInfo=outputPortsCodeInfo(portIdx);
                portIdxStr=num2str(portIdx-1);

                this.writeSfunctionPortDimensions('Out',port,portIdxStr,portCodeInfo);
                this.writeSfunctionPortDimensionsMode('Output',port,portIdxStr);
                this.writeSfunctionPortSymbolicDimensions('Out',portCodeInfo,portIdxStr);
                this.writeSetPortFrameData('Output',port,portIdxStr);


                this.writeSfunctionRegisterAndSetDataType('Output',port,portIdxStr);


                this.writePortComplexSignal('Output',portIdx);
                this.writeSfunctionRegisterAndSetUnit('Output',port,portIdxStr);
                this.writeSetPortSampleTime(port,portIdx,portIdxStr);

                this.writeMessageInterface('Output',port,portIdxStr);
                this.writeDiscreteValuedOutput(port,portIdxStr);
                this.writeOkToMerge(port,portIdxStr);
                this.writeOutputPortICAttributes(portIdx);

                this.writeOptimizationParamForPort('Output',portIdx);
                this.writeBasedIndexForPort('Output',portIdx);
            end
        end
    end


    methods(Access=protected)
        function writeSetPortSampleTime(this,port,portIdx,portIdxStr)
            if port.IsConstant
                sampleTime='mxGetInf()';
                sampleOffset='0';
            else
                sampleTime=port.SampleTime.Period;
                sampleOffset=port.SampleTime.Offset;
            end

            if this.WriteInitResetTermEvent('Output',portIdx)



            elseif port.IsControllableRate

                this.WriteControllableRate('OutputPort',portIdx);

            elseif this.hasNormalSampleTimes(port)||port.IsConstant



                if this.ModelInterface.IsExportFcnDiagram
                    this.Writer.writeLine('ssSetOutputPortSampleTime(S, %s, -1);',portIdxStr);
                else
                    this.Writer.writeLine('ssSetOutputPortSampleTime(S, %s, %s);',portIdxStr,sampleTime);
                    this.Writer.writeLine('ssSetOutputPortOffsetTime(S, %s, %s);',portIdxStr,sampleOffset);
                end
            elseif port.IsAsyncTriggered
                this.Writer.writeLine('ssSetOutputPortSampleTime(S, %s, -1);',portIdxStr);
                if~this.ModelInterface.IsExportFcnDiagram
                    this.Writer.writeLine('ssSetOutputPortOffsetTime(S, %s, %s);',portIdxStr,...
                    coder.internal.modelreference.DataTypeUtils.getMinusInfinite);
                end
            else
                this.Writer.writeLine('ssSetOutputPortSampleTime(S, %s, -1);',portIdxStr);
            end
        end


        function writeOkToMerge(this,port,portIdxStr)
            okToMerge=port.OkToMerge;
            switch okToMerge
            case 'yes'
                okToMergeStr='SS_OK_TO_MERGE';
            case 'conditional'
                okToMergeStr='SS_OK_TO_MERGE_CONDITIONAL';
            otherwise
                okToMergeStr='SS_NOT_OK_TO_MERGE';
            end

            this.Writer.writeLine('ssSetOutputPortOkToMerge(S, %s, %s);',portIdxStr,okToMergeStr)
        end


        function writeDiscreteValuedOutput(this,port,portIdxStr)
            this.Writer.writeLine('ssSetOutputPortDiscreteValuedOutput(S, %s, %d);',...
            portIdxStr,port.DiscreteValuedOutput);
        end


        function writeOutputPortICAttributes(this,portIdx)
            port=this.Ports{portIdx};
            if(port.HasICAtributes)
                isDisable=coder.internal.modelreference.DataTypeUtils.getBooleanString(port.ICAttributes.Disable);
                isFirstInitialize=coder.internal.modelreference.DataTypeUtils.getBooleanString(port.ICAttributes.FirstInitialize);
                isStart=coder.internal.modelreference.DataTypeUtils.getBooleanString(port.ICAttributes.Start);
                this.Writer.writeLine('ssSetOutputPortICAttributes(S, %d, %s, %s, %s);',...
                portIdx-1,isStart,isFirstInitialize,isDisable);
            end
        end
    end
end


