classdef Inport<matlab.mixin.Heterogeneous&Simulink.iospecification.AllowsPartial&Simulink.iospecification.CompatibleInterface&Simulink.iospecification.CreateExternalDataInterface





    methods(Static)


        function boolOut=isIoSpecificationSupportedBuiltInType(dataTypeStringIn)


            boolOut=any(strcmpi(dataTypeStringIn,Simulink.iospecification.Inport.getSupportedBuiltinDataTypes()));

        end


        function boolOut=doesResolveAsString(dataTypeStringIn)


            boolOut=~isempty(strfind(dataTypeStringIn,'str'))&&~contains(dataTypeStringIn,'stringtype');

        end


        function supportedBuiltinDataTypes=getSupportedBuiltinDataTypes()

            supportedBuiltinDataTypes={'double','single','int8','int16','int32','uint8','uint16','uint32','boolean'};



        end


        function bool=isa(blockPath)
            bool=false;
            try
                portType=get_param(blockPath,'BlockType');
                boolInport=strcmpi('inport',portType);
            catch
                return;
            end

            try
                IS_USE_BUS_OBJ=strcmpi(get_param(blockPath,'UseBusObject'),'on');
            catch
                IS_USE_BUS_OBJ=false;
            end

            try
                boolFCN=strcmp(get_param(blockPath,'OutputFunctionCall'),'on');
            catch
                boolFCN=false;
            end

            try
                boolBusEl=strcmpi(get_param(blockPath,'IsBusElementPort'),'on');
            catch
                boolBusEl=false;
            end
            bool=boolInport&&~IS_USE_BUS_OBJ&&~boolFCN&&~boolBusEl;
        end


        function bool=isInport(blockPath)

            bool=false;
            if Simulink.iospecification.Inport.isa(blockPath)
                bool=true;
            end
        end


        function bool=isRootInport(blockPath)

            if(~ishandle({blockPath}))
                blockPath=get_param(blockPath,'Handle');
            end


            bool=false;
            if Simulink.iospecification.RootInport.isa(blockPath)
                bool=true;
            end

        end


        function bool=isTriggerPort(blockPath)

            bool=false;
            if Simulink.iospecification.TriggerPort.isa(blockPath)
                bool=true;
            end
        end


        function bool=isEnablePort(blockPath)
            bool=false;
            if Simulink.iospecification.EnablePort.isa(blockPath)
                bool=true;
            end
        end


        function bool=isFunctionCallPort(blockPath)

            bool=false;
            if Simulink.iospecification.FunctionCallPort.isa(blockPath)
                bool=true;
            end

        end


        function bool=isRootInportBus(blockPath)

            if(~ishandle({blockPath}))
                blockPath=get_param(blockPath,'Handle');
            end


            bool=false;
            if Simulink.iospecification.RootInportBus.isa(blockPath)
                bool=true;
            end
        end


        function bool=isRootInportBusElement(blockPath)


            bool=false;
            if Simulink.iospecification.RootInportBusElement.isa(blockPath)
                bool=true;
            end

        end


        function bool=isAtRootLevel(blockPath)

            if(ishandle(blockPath))
                blockPath=getfullname(blockPath);
            end

            bool=false;

            try
                aBlockPath=Simulink.SimulationData.BlockPath(blockPath);
            catch
                return;
            end

            bool=aBlockPath.getLength()==1;
        end


        function resolvedDTString=resolveCompiledDataTypeString(blockH)
            OutDataTypeStruct=get_param(blockH,'CompiledPortDataTypes');

            if Simulink.iospecification.Inport.isIoSpecificationSupportedBuiltInType(OutDataTypeStruct.Outport{1})

                resolvedDTString=OutDataTypeStruct.Outport{1};
            elseif any(strncmpi(OutDataTypeStruct.Outport{1},'fixdt',5))

                resolvedDTString=OutDataTypeStruct.Outport{1};
            elseif fixed.internal.type.isNameOfTraditionalFixedPointType(OutDataTypeStruct.Outport{1})

                fixptObj=fixdt(OutDataTypeStruct.Outport{1});
                resolvedDTString=fixptObj.tostring;
            elseif~isempty(enumeration(OutDataTypeStruct.Outport{1}))

                resolvedDTString=['Enum: ',OutDataTypeStruct.Outport{1}];
            elseif Simulink.iospecification.Inport.doesResolveAsString(OutDataTypeStruct.Outport{1})

                if strcmp(OutDataTypeStruct.Outport{1},'string')

                    resolvedDTString='string';
                else

                    idxStrFind=strfind(OutDataTypeStruct.Outport{1},'str');
                    outTypeStr=OutDataTypeStruct.Outport{1};
                    bufferSize=outTypeStr(idxStrFind+3:end);
                    outTypeStrFinal=['stringtype(',bufferSize,')'];
                    resolvedDTString=outTypeStrFinal;
                end

            else

                resolvedDTString=OutDataTypeStruct.Outport{1};
            end

        end


        function[paramValueResolved,boolOut]=resolveBlockParameterValue(blockH,parameterValue)

            [paramValueResolved,boolOut]=slResolve(parameterValue,getfullname(blockH));

        end

    end

    properties

Handle
        USE_COMPILED_PARAMS=false

    end

    methods

        function obj=Inport(varargin)

            if~isempty(varargin)

                try
                    obj.Handle=varargin{1};
                catch ME
                    throwAsCaller(ME);
                end

            end

        end


        function outDataType=getDataType(obj)
            try

                dataTypeStr=get_param(obj.Handle,'OutDataTypeStr');
            catch ME
                throwAsCaller(ME);
            end
            origDataTypeStr=dataTypeStr;




            if contains(origDataTypeStr,'stringtype')
                origDataTypeStr='string';
            end
            outDataType=obj.resolveFixedDtAndNumericTypeOnBlock(origDataTypeStr);

            if~obj.USE_COMPILED_PARAMS
                return;
            end

            outDataType=getCompiledDataTypeFromPort(obj);

        end


        function outDims=getDimensions(obj)

            try
                outDims=resolvePortDimension(obj);
            catch ME
                throwAsCaller(ME);
            end

        end


        function outSignalType=getSignalType(obj)
            try
                outSignalType=get_param(obj.Handle,'SignalType');
            catch ME
                throwAsCaller(ME);
            end
            if~obj.USE_COMPILED_PARAMS
                return;
            end


            temp=get_param(obj.Handle,'CompiledPortComplexSignals');

            if isempty(temp.Outport)
                return;
            end

            outSignalType=obj.getComplexString(temp.Outport);
        end


        function set.Handle(obj,blockH)

            if~ishandle(blockH)
                DAStudio.error('sl_iospecification:inports:badBlockHandle');
            end

            try
                get_param(blockH,'BlockType');
                obj.Handle=blockH;
            catch ME
                throwAsCaller(ME);
            end
            return;

        end

    end

    methods


        function create(obj,blockPathToBeCreated,portNumber)


            add_block(obj.Handle,blockPathToBeCreated);
        end


        function setBlockParams(obj,blockPathToBeCreated,isModelCompiled)

            if isModelCompiled




                if strcmpi(get_param(obj.Handle,'OutDataTypeStr'),'Inherit: auto')

                    resolvedDTString=Simulink.iospecification.Inport.resolveCompiledDataTypeString(obj.Handle);
                    set_param(blockPathToBeCreated,'OutDataTypeStr',resolvedDTString);

                    OutDataTypeStruct=get_param(obj.Handle,'CompiledPortDataTypes');

                    if Simulink.iospecification.Inport.doesResolveAsString(OutDataTypeStruct.Outport{1})
                        compiledSampleTime=get_param(obj.Handle,'CompiledSampleTime');
                        set_param(blockPathToBeCreated,'SampleTime',mat2str(compiledSampleTime));
                    end

                elseif contains(get_param(obj.Handle,'OutDataTypeStr'),'stringtype')||contains(get_param(obj.Handle,'OutDataTypeStr'),'string')

                    compiledSampleTime=get_param(obj.Handle,'CompiledSampleTime');
                    try
                        set_param(blockPathToBeCreated,'SampleTime',mat2str(compiledSampleTime));
                    catch ME
                        set(get_param(blockPathToBeCreated,'handle'),'SampleTime','1');
                    end
                end


                if strcmp(strtrim(get_param(obj.Handle,'PortDimensions')),'-1')
                    PortDimensionsStruct=get_param(obj.Handle,'CompiledPortDimensions');
                    set_param(blockPathToBeCreated,'PortDimensions',['[',num2str(PortDimensionsStruct.Outport(2:end)),']']);
                end


                SignalTypeStruct=get_param(obj.Handle,'CompiledPortComplexSignals');
                set_param(blockPathToBeCreated,'SignalType',SignalTypeStruct.Outport(1));

























            else

                if contains(get_param(obj.Handle,'OutDataTypeStr'),'stringtype')||...
                    contains(get_param(obj.Handle,'OutDataTypeStr'),'string')
                    set(get_param(blockPathToBeCreated,'handle'),'SampleTime','1');
                end
            end
        end


        function portDimValue=resolvePortDimension(obj)

            if obj.USE_COMPILED_PARAMS
                temp=get_param(obj.Handle,'CompiledPortDimensions');
                portDimValue=temp.Outport(2:end);
                return;
            end


            portDimsStr=get_param(obj.Handle,'PortDimensions');
            [portDimValue,~]=slResolve(portDimsStr,getfullname(obj.Handle));
            if~isempty(portDimValue)
                portDimValue=resolvePortDimValue(obj,portDimValue,portDimsStr);
            else
                portDimValue=portDimsStr;
            end

        end


        function dataType=resolveDataType(obj)
            try
                dataTypeStr=get_param(obj.Handle,'OutDataTypeStr');
                [dataType,~]=slResolve(dataTypeStr,getfullname(obj.Handle));
            catch ME
                throwAsCaller(ME);
            end
        end


        function portDimVal=resolvePortDimValue(~,portDimVal,portDimValStr)

            if ischar(portDimVal)||isstring(portDimVal)
                portDimVal=str2num(portDimVal);
            elseif~isnumeric(portDimVal)
                portDimVal=portDimValStr;
            end

        end


        function portName=getPortName(obj)
            portName=get_param(obj.Handle,'Name');
        end


        function outDataType=resolveFixedDtAndNumericTypeOnBlock(obj,origDataTypeStr)

            if(~isbuiltin(obj,origDataTypeStr)&&~strcmp(origDataTypeStr,'string'))&&(~isempty(strfind(origDataTypeStr,'fixdt'))||...
                isempty(strfind(origDataTypeStr,'Inherit:')))&&...
                isempty(strfind(origDataTypeStr,'Bus'))&&...
                isempty(strfind(origDataTypeStr,'Enum'))

                compiledDataType='';


                if~isempty(strfind(origDataTypeStr,'fixdt'))
                    outType=eval(origDataTypeStr);
                else
                    outType=evalin('base',origDataTypeStr);
                end


                if isa(outType,'Simulink.NumericType')





                    if license('test','Fixed_Point_Toolbox')&&...
                        (~isempty(strfind(outType.DataTypeMode,'Fixed-point'))||...
                        ~isempty(strfind(outType.DataTypeMode,'Scaled double')))&&...
                        (strcmpi(get(obj.Handle,'DataTypeOverride'),'off')||...
                        strcmpi(get(obj.Handle,'DataTypeOverride'),'UseLocalSettings'))








                        compiledDataType=outType.tostring;







                    elseif~license('test','Fixed_Point_Toolbox')&&...
                        (~isempty(strfind(outType.DataTypeMode,'Fixed-point'))||...
                        ~isempty(strfind(outType.DataTypeMode,'Scaled double')))&&...
                        (strcmpi(get(obj.Handle,'DataTypeOverride'),'off')||...
                        strcmpi(get(obj.Handle,'DataTypeOverride'),'UseLocalSettings'))

                        DAStudio.error('sl_iospecification:inports:noFixedPointNoOverride');





                    elseif~isempty(strfind(outType.DataTypeMode,'Fixed-point'))&&...
                        ~strcmpi(get(obj.Handle,'DataTypeOverride'),'off')&&...
                        ~strcmpi(get(obj.Handle,'DataTypeOverride'),'UseLocalSettings')
                        compiledDataType=lower(get(obj.Handle,'DataTypeOverride'));
                    else


                        compiledDataType=lower(outType.DataTypeMode);
                    end
                end

                if~isempty(compiledDataType)
                    outDataType=compiledDataType;
                else

                    if isa(outType,'Simulink.AliasType')

                        outDataType=obj.resolveFixedDtAndNumericTypeOnBlock(outType.BaseType);
                    else


                        outDataType=obj.resolveFixedDtAndNumericTypeOnBlock(outType.DataTypeMode);
                    end
                end
            else
                outDataType=origDataTypeStr;

                outDataType=formatIfEnum(obj,outDataType);
            end

        end

    end

end
