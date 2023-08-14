


classdef PortInfoWriter<handle
    properties(Access=protected)
Ports
Writer
CodeWriter
ModelInterface
CodeInfo
        NumberOfPorts=0
PortUnitsWriter
PortDimensionsWriter
    end


    methods(Access=public)
        function this=PortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter)
            this.Ports=ports;
            this.Writer=writer;
            this.ModelInterface=modelInterface;
            this.CodeInfo=codeInfo;
            this.NumberOfPorts=length(this.Ports);
            this.PortUnitsWriter=coder.internal.modelreference.PortUnitsWriter(writer);
            this.PortDimensionsWriter=dimensionsWriter;
        end

        function[numberOfPorts]=getNumberOfPorts(this)
            numberOfPorts=this.NumberOfPorts;
        end
    end


    methods(Static,Access=public)
        function obj=createInputPortInfoWriter(modelInterface,codeInfo,writer)
            ports=coder.internal.modelreference.Utilities.getFieldData(modelInterface,'Inports');
            dimensionsWriter=coder.internal.modelreference.PortDimensionsWriter(modelInterface,writer);
            obj=coder.internal.modelreference.InputPortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter);
        end


        function obj=createOutputPortInfoWriter(modelInterface,codeInfo,writer)
            ports=coder.internal.modelreference.Utilities.getFieldData(modelInterface,'Outports');
            dimensionsWriter=coder.internal.modelreference.PortDimensionsWriter(modelInterface,writer);
            obj=coder.internal.modelreference.OutputPortInfoWriter(ports,modelInterface,codeInfo,writer,dimensionsWriter);
        end
    end


    methods(Access=protected)
        function writeSfunctionPortDimensions(this,portType,port,portIdxStr,portCodeInfo)
            this.PortDimensionsWriter.write(portType,port,portIdxStr,portCodeInfo);
        end


        function writeSfunctionPortDimensionsMode(this,portType,port,portIdxStr)
            if this.isDynamicArray(port)
                this.Writer.writeLine('ssSet%sPortDimensionsMode(S, %s, FIXED_DIMS_MODE);',portType,portIdxStr);
            elseif port.IsVarDim&&~port.IsStruct
                this.Writer.writeLine('ssSet%sPortDimensionsMode(S, %s, VARIABLE_DIMS_MODE);',portType,portIdxStr);
            else
                this.Writer.writeLine('ssSet%sPortDimensionsMode(S, %s, FIXED_DIMS_MODE);',portType,portIdxStr);
            end
        end

        function writeSfunctionPortSymbolicDimensions(this,portType,portCodeInfo,portIdxStr)
            portDT=portCodeInfo.Type;
            if~isempty(portDT)&&portDT.isMatrix&&portDT.HasSymbolicDimensions
                varName=[lower(portType),'put',portIdxStr,'DimsId'];
                symbDims=rtw.connectivity.CodeInfoUtils.getArray(portDT.SymbolicDimensions);
                numSymbDims=length(symbDims);
                if numSymbDims>1
                    symbDimsStr=['[',symbDims{1}];
                    for dimsIdx=2:numSymbDims
                        symbDimsStr=[symbDimsStr,', ',symbDims{dimsIdx}];
                    end
                    symbDimsStr=[symbDimsStr,']'];
                else
                    symbDimsStr=symbDims{1};
                end
                this.Writer.writeLine('{');
                this.Writer.writeLine(...
                ['const SymbDimsId ',varName,...
                ' = ssRegisterSymbolicDimsExpr(S, "',symbDimsStr,'");']);
                this.Writer.writeLine(...
                ['ssSet',portType,'putPortSymbolicDimsId(S, ',...
                portIdxStr,', ',varName,');']);
                this.Writer.writeLine('}');
            end
        end


        function writeSetPortFrameData(this,portType,port,portIdxStr)
            if port.IsFrame
                this.Writer.writeLine('ssSet%sPortFrameData(S, %s, FRAME_YES);',...
                portType,portIdxStr);
            else
                this.Writer.writeLine('ssSet%sPortFrameData(S, %s, FRAME_NO);',...
                portType,portIdxStr);
            end
        end


        function writeSfunctionRegisterAndSetDataType(this,portType,port,portIdxStr)
            fcnCallStr=['ssSet',portType,'PortDataType'];
            this.Writer.writeString('if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {');
            if port.IsBuiltin
                if(this.isDynamicArray(port))
                    this.Writer.writeChar('{');
                    this.Writer.writeLine('DTypeId dataTypeIdReg = %s;',...
                    port.DataTypeName);
                    this.processDynamicArrayOfTypes(port);
                    this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',...
                    fcnCallStr,portIdxStr);
                    this.Writer.writeChar('}');
                else
                    this.Writer.writeLine('%s(S, %s, %s);',...
                    fcnCallStr,portIdxStr,port.DataTypeName);
                end
            else
                this.Writer.writeLine('\n#if defined (MATLAB_MEX_FILE)\n','');
                if port.IsHalfPrecision&&~port.IsAlias
                    regFcnCallStr='ssRegisterDataTypeHalfPrecision';
                    this.Writer.writeChar('{');
                    this.Writer.writeLine('DTypeId dataTypeIdReg = \n%s(S, %d);',...
                    regFcnCallStr,0);
                    this.Writer.writeString('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
                    this.processDynamicArrayOfTypes(port);
                    this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',fcnCallStr,portIdxStr);
                    this.Writer.writeChar('}');
                elseif port.IsFixpt&&~port.IsAlias
                    if port.IsScaledFloat
                        regFcnCallStr='ssRegisterDataTypeFxpScaledDouble';
                    else
                        regFcnCallStr='ssRegisterDataTypeFxpFSlopeFixExpBias';
                    end
                    this.Writer.writeChar('{');
                    this.Writer.writeLine('DTypeId dataTypeIdReg = \n%s(\nS, \n%d, \n%d, \n%s, \n%d, \n%s, \n%d );',...
                    regFcnCallStr,...
                    port.IsSigned,...
                    port.RequiredBits,...
                    port.FracSlope,...
                    port.FixedExp,...
                    port.Bias,...
                    0);
                    this.processDynamicArrayOfTypes(port);
                    this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',fcnCallStr,portIdxStr);
                    this.Writer.writeChar('}');
                elseif port.IsImage&&~port.IsAlias
                    regFcnCallStr='ssRegisterImageDataType';
                    this.Writer.writeChar('{');
                    this.Writer.writeLine('DTypeId dataTypeIdReg = \n%s(\nS, \n%d, \n%d, \n%d, \nimages::datatypes::ColorFormat::%s, \nimages::datatypes::Layout::%s, \nimages::datatypes::UnderlyingType::%s );',...
                    regFcnCallStr,...
                    port.ImageNumChannels,...
                    port.ImageNumRows,...
                    port.ImageNumCols,...
                    port.ImageColorFormat,...
                    port.ImageLayout,...
                    port.ImageBaseType);
                    this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',fcnCallStr,portIdxStr);
                    this.Writer.writeChar('}');
                else
                    if(port.IsPointer||port.IsInteger||port.IsFcnCall)
                        this.Writer.writeLine('%s(S, %s, %s);',...
                        fcnCallStr,portIdxStr,port.DataTypeName);
                    elseif port.IsString

                        this.Writer.writeChar('{');
                        this.Writer.writeString('DTypeId dataTypeIdReg;');
                        this.Writer.writeLine('ssRegisterTypeFromExpr(\nS, \n"stringtype(%d)", \n&dataTypeIdReg);',port.StringMaxLength);
                        this.Writer.writeString('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
                        this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',fcnCallStr,portIdxStr);
                        this.Writer.writeChar('}');
                    else

                        this.Writer.writeChar('{');
                        this.Writer.writeString('DTypeId dataTypeIdReg;');
                        this.Writer.writeLine('ssRegisterTypeFromNamedObject(\nS, \n"%s", \n&dataTypeIdReg);',port.DataTypeName);
                        this.Writer.writeString('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
                        this.processDynamicArrayOfTypes(port);
                        this.Writer.writeLine('%s(S, %s, dataTypeIdReg);',fcnCallStr,portIdxStr);
                        this.Writer.writeChar('}');
                    end
                end
                this.Writer.writeLine('\n#endif\n','');
            end

            this.Writer.writeChar('}');
        end


        function writePortComplexSignal(this,portType,portIdx)
            if this.isDynamicArray(this.Ports{portIdx})
                this.Writer.writeLine('ssSet%sPortComplexSignal(S, %d, COMPLEX_NO);',portType,portIdx-1);
            elseif this.Ports{portIdx}.IsComplex
                this.Writer.writeLine('ssSet%sPortComplexSignal(S, %d, COMPLEX_YES);',portType,portIdx-1);
            end
        end

        function writeMessageInterface(this,portType,port,portIdxStr)
            if port.IsMessage
                this.Writer.writeLine('slmsg_ssSet%sPortIsMessage(S, %s, 1);',portType,portIdxStr);



                if slfeature('SLMessageService')>=2&&...
                    slfeature('ServiceFunctions')>=1

                    if strcmp(portType,'Input')
                        this.Writer.writeLine('slmsg_ssSetUseInternalQueue(S, %s, false);',portIdxStr);
                    end
                    return;
                end

                if strcmp(portType,'Input')

                    qLen=port.MessageData.QueueLength;
                    this.Writer.writeLine('slmsg_ssSetMessageQueueCapacity(S, SS_INPUT_PORT_MESSAGE_QUEUE, %s, %d);',portIdxStr,qLen);

                    qType=port.MessageData.QueueType;
                    this.Writer.writeLine('slmsg_ssSetMessageQueueType(S, SS_INPUT_PORT_MESSAGE_QUEUE, %s, %s);',portIdxStr,qType);
                    if~isempty(strfind(qType,'PRIORITY'))
                        qOrder=port.MessageData.QueuePriorityOrder;
                        this.Writer.writeLine('slmsg_ssSetMessageQueuePriorityOrder(S, SS_INPUT_PORT_MESSAGE_QUEUE, %s, %s);',portIdxStr,qOrder);
                    end
                end
            end
        end

        function writeSfunctionRegisterAndSetUnit(this,portType,port,portIdxStr)
            this.PortUnitsWriter.writeSfunctionRegisterAndSetUnit(portType,port.UnitExpr,portIdxStr);
        end


        function writeOptimizationParamForPort(this,portType,portIdx)
            optStr=this.getOptimizationParamForPort(this.Ports{portIdx});
            this.Writer.writeLine('ssSet%sPortOptimOpts(S, %d, %s);',portType,portIdx-1,optStr);
        end


        function writeBasedIndexForPort(this,portType,portIdx)
            port=this.Ports{portIdx};
            if port.IsZeroBased
                this.Writer.writeLine('ssSetZeroBasedIndex%sPort(S, %d);',portType,portIdx-1);
            elseif port.IsOneBased
                this.Writer.writeLine('ssSetOneBasedIndex%sPort(S, %d);',portType,portIdx-1);
            end
        end


        function isNormal=hasNormalSampleTimes(this,port)
            isNormal=this.ModelInterface.DisallowSampleTimeInheritance&&...
            ~this.ModelInterface.IsAPeriodicTriggered&&...
            ~port.IsAsyncTriggered&&...
            ~port.IsUnion;
        end

        function WriteControllableRate(this,portType,portIdx)
            port=this.Ports{portIdx};
            portIdxStr=num2str(portIdx-1);

            if(length(this.ModelInterface.ControllableRateUIDs)==1)
                controllableRateUIDs={this.ModelInterface.ControllableRateUIDs};
            else
                controllableRateUIDs=this.ModelInterface.ControllableRateUIDs;
            end

            uid='';
            for idx=1:length(controllableRateUIDs)
                if controllableRateUIDs{idx}.ctrlRateOffset==...
                    str2double(port.SampleTime.Offset)
                    uid=controllableRateUIDs{idx}.uid;
                    break;
                end
            end
            uid=['"',uid,'"'];
            this.Writer.writeString(['ssSet',portType,'ControllableSampleTime(S, ',portIdxStr,', ',port.SampleTime.Period,');']);
            this.Writer.writeString(['ssSet',portType,'ControllableSampleTimeUID(S, ',portIdxStr,', ',uid,');']);
        end

        function hasIRTEvent=WriteInitResetTermEvent(this,portType,portIdx)
            port=this.Ports{portIdx};

            hasIRTEvent=false;
            irtEventTypes={'PowerUpEvent','ResetEvent','ResetWithInitEvent','PowerDownEvent'};

            if~isfield(this.ModelInterface,'ModelWideEvents')
                return;
            elseif(length(this.ModelInterface.ModelWideEvents)==1)
                modelWideEvents={this.ModelInterface.ModelWideEvents};
            else
                modelWideEvents=this.ModelInterface.ModelWideEvents;
            end
            identifier='';
            eventType='';

            containedTs=port.ContainedTs;

            if isnumeric(containedTs)

                for tsIdx=1:length(containedTs)
                    writeIRT=false;
                    for mweIdx=1:length(modelWideEvents)
                        tidInSubMdl=modelWideEvents{mweIdx}.tid;
                        eventType=modelWideEvents{mweIdx}.eventType;
                        if tidInSubMdl==containedTs(tsIdx)&&ismember(eventType,irtEventTypes)
                            identifier=['"',modelWideEvents{mweIdx}.id,'"'];
                            eventType=['"',eventType,'"'];%#ok
                            writeIRT=true;
                            hasIRTEvent=true;
                            break;
                        end
                    end
                end
            end

            if hasIRTEvent
                portIdxStr=num2str(portIdx-1);
                if length(containedTs)==1

                    this.Writer.writeString(['ssSet',portType,'PortSampleTime(S, ',portIdxStr,', ',port.SampleTime.Period,');']);
                    this.Writer.writeString(['ssSet',portType,'PortOffsetTime(S, ',portIdxStr,', ',port.SampleTime.Offset,');']);
                else

                    this.Writer.writeString(['ssSet',portType,'PortSampleTime(S, ',portIdxStr,', -1);']);
                end
            end
        end

        function processDynamicArrayOfTypes(this,port)
            IsDynamicArray=this.isDynamicArray(port);

            if(IsDynamicArray)
                ndims=size(port.SymbolicDims,1);
                dims=cell(ndims,1);
                for idx=1:ndims
                    dims{idx}=port.SymbolicDims(idx,:);
                    if(deblank(dims{idx})=="Inf")
                        dims{idx}='SS_INT32_INF_DIM';
                    end
                end
                dimsStr=strjoin(deblank(dims),', ');
                dimsStr=strcat('{',dimsStr,'}');

                regFcnCallStr='ssRegisterDynamicArrayDataType';
                this.Writer.writeLine('\n#if defined (MATLAB_MEX_FILE)\n','');
                this.Writer.writeChar('{');
                this.Writer.writeLine('DTypeId dynmatContainedDataTypeId = dataTypeIdReg;');
                this.Writer.writeLine('int_T dynmatContainedDataDims[%d] = %s;',ndims,dimsStr);
                this.Writer.writeLine('DTypeId dynmatDataTypeIdReg = \n%s(\nS, \ndynmatContainedDataTypeId, \n%d, \n&dynmatContainedDataDims[0], \n%d);',...
                regFcnCallStr,...
                ndims,...
                port.IsComplex);
                this.Writer.writeString('if(dynmatDataTypeIdReg == INVALID_DTYPE_ID) return;');
                this.Writer.writeString('dataTypeIdReg = dynmatDataTypeIdReg;');
                this.Writer.writeChar('}');
                this.Writer.writeLine('\n#endif\n','');
            end
        end
    end


    methods(Static,Access=protected)
        function paramStr=getOptimizationParamForPort(port)
            if port.IsReusable
                if port.GlobalInRTW
                    paramStr='SS_REUSABLE_AND_GLOBAL';
                else
                    paramStr='SS_REUSABLE_AND_LOCAL';
                end
            else
                if port.GlobalInRTW
                    paramStr='SS_NOT_REUSABLE_AND_GLOBAL';
                else
                    paramStr='SS_NOT_REUSABLE_AND_LOCAL';
                end
            end
        end

        function IsDynamicArray=isDynamicArray(port)
            IsDynamicArray=false;
            for i=1:size(port.SymbolicDims,1)
                if(deblank(port.SymbolicDims(i,:))=="Inf")
                    IsDynamicArray=true;
                    break;
                end
            end
        end
    end
end


