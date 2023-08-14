


classdef InputPortInfoWriter<coder.internal.modelreference.PortInfoWriter
    properties(Access=private)
FcnCallArgWriter
    end


    methods(Access=public)
        function this=InputPortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter)
            this@coder.internal.modelreference.PortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter);
        end
    end


    methods(Access=public)
        function write(this)
            inputPortsCodeInfo=this.CodeInfo.Inports;
            dataPortIdx=0;
            this.Writer.writeLine('if (!ssSetNumInputPorts(S, %d)) return;',this.NumberOfPorts);
            for portIdx=1:this.NumberOfPorts
                port=this.Ports{portIdx};

                portIdxStr=num2str(portIdx-1);

                isDataPort=~(port.FunctionCallInitiator||port.IsFcnCall);
                if isDataPort
                    dataPortIdx=dataPortIdx+1;
                    portCodeInfo=inputPortsCodeInfo(dataPortIdx);
                else
                    portCodeInfo=[];
                end
                this.writeSfunctionPortDimensions('In',port,portIdxStr,portCodeInfo);
                this.writeSfunctionPortDimensionsMode('Input',port,portIdxStr);

                this.writeSetPortFrameData('Input',port,portIdxStr);

                if port.FunctionCallInitiator
                    this.Writer.writeLine('ssSetInputPortDataType(S, %s, SS_FCN_CALL);',portIdxStr);
                else
                    this.writeSfunctionRegisterAndSetDataType('Input',port,portIdxStr);
                end

                if isDataPort
                    this.writeSfunctionPortSymbolicDimensions('In',portCodeInfo,portIdxStr);
                end

                this.writePortComplexSignal('Input',portIdx);
                this.writeSfunctionRegisterAndSetUnit('Input',port,portIdxStr);
                this.writeMessageInterface('Input',port,portIdxStr);
                this.writeSetInputPortDirectFeedThrough(port,portIdxStr);
                this.writeOptimizationParamForPort('Input',portIdx);
                this.writeSetInputPortOverWritable(port,portIdxStr);
                this.writeSetPortSampleTime(port,portIdx,portIdxStr);
                this.writeBasedIndexForPort('Input',portIdx);
            end
            assert(dataPortIdx==length(inputPortsCodeInfo));
        end
    end


    methods(Access=protected)
        function writeSetPortSampleTime(this,port,portIdx,portIdxStr)
            if this.WriteInitResetTermEvent('Input',portIdx)



            elseif port.IsControllableRate

                this.WriteControllableRate('InputPort',portIdx);

            else
                if this.hasNormalSampleTimes(port)&&~port.FunctionCallInitiator&&~this.ModelInterface.IsExportFcnDiagram
                    this.Writer.writeString(['ssSetInputPortSampleTime(S, ',portIdxStr,', ',port.SampleTime.Period,');']);
                    this.Writer.writeString(['ssSetInputPortOffsetTime(S, ',portIdxStr,', ',port.SampleTime.Offset,');']);
                elseif port.IsAsyncTriggered
                    this.Writer.writeString(['ssSetInputPortSampleTime(S, ',portIdxStr,', -1);']);
                    if~this.ModelInterface.IsExportFcnDiagram
                        this.Writer.writeString(['ssSetInputPortOffsetTime(S, ',portIdxStr,', ',...
                        coder.internal.modelreference.DataTypeUtils.getMinusInfinite,');']);
                    end
                else
                    this.Writer.writeString(['ssSetInputPortSampleTime(S, ',portIdxStr,', -1);']);
                end
            end
        end


        function writeSetInputPortDirectFeedThrough(this,port,portIdxStr)
            if port.DirectFeedThrough
                this.Writer.writeString(['ssSetInputPortDirectFeedThrough(S, ',portIdxStr,', 1);']);
            else
                this.Writer.writeString(['ssSetInputPortDirectFeedThrough(S, ',portIdxStr,', 0);']);
            end
            this.Writer.writeString(['ssSetInputPortRequiredContiguous(S, ',portIdxStr,', 1);']);
        end


        function writeSetInputPortOverWritable(this,port,portIdxStr)
            this.Writer.writeString(['ssSetInputPortOverWritable(S, ',portIdxStr,', ',port.OverWritable,');']);
        end
    end
end


