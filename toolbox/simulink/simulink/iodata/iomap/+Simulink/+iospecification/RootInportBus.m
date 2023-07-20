classdef RootInportBus<Simulink.iospecification.Inport&Simulink.iospecification.BusObjectCompatibleInterface





    methods(Static)


        function bool=isa(blockPath)
            bool=false;
            try
                portType=get_param(blockPath,'BlockType');
                IS_INPORT=strcmpi('inport',portType);
            catch
                return;
            end

            try
                theBlockPath=[get(blockPath,'Path'),'/',get(blockPath,'Name')];
                boolROOT=Simulink.iospecification.Inport.isAtRootLevel(theBlockPath);
            catch
                boolROOT=false;
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
            bool=IS_INPORT&&boolROOT&&IS_USE_BUS_OBJ&&~boolBusEl&&~boolFCN;

        end

    end


    methods(Hidden,Static)


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableTypeImpl(inputVariableObj)

            IS_VALID_INPUTVAR_TO_COMPARE=false;

            if isa(inputVariableObj,'Simulink.iospecification.LoggedSignalInput')

                IS_VALID_INPUTVAR_TO_COMPARE=Simulink.iospecification.RootInportBus.isValidVariableTypeImpl(inputVariableObj.ValueInputVariable);
                return;
            end

            if isa(inputVariableObj,'Simulink.iospecification.BusInput')||...
                isa(inputVariableObj,'Simulink.iospecification.GroundInput')||...
                isa(inputVariableObj,'Simulink.iospecification.TSArrayInput')

                IS_VALID_INPUTVAR_TO_COMPARE=true;
            end
        end

    end


    methods


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=Simulink.iospecification.RootInportBus.isValidVariableTypeImpl(inputVariableObj);
        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,sigDT,portDT]=isDataTypeCompatible(obj,inputVariableObj)
            IS_DATATYPE_COMPATIBLE.datatype.status=false;
            IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext='';
            dataTypeStr=get_param(obj.Handle,'OutDataTypeStr');
            portDT=dataTypeStr;
            sigDT=inputVariableObj.getDataType();
            BusObjectName=parseBusObjectNameFromDataType(obj,dataTypeStr);

            try
                BusObject=getBusObjectDefinition(obj,BusObjectName);
            catch ME
                errMsg=ME.message;
                return;
            end

            [IS_COMPATIBLE,errMsg]=isInputCompatibleWithTree(obj,BusObject,inputVariableObj);

            IS_DATATYPE_COMPATIBLE.datatype.status=IS_COMPATIBLE;

            if~IS_COMPATIBLE
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:leafSignalMismatch');
            end
        end


        function[ARE_DIMS_COMPATIBLE,sigDims,portDims]=areDimsCompatible(obj,inputVariableObj)

            portDims=obj.getDimensions();
            sigDims=inputVariableObj.getDimensions();
            totalDataElementNumber=prod(sigDims);

            ARE_DIMS_COMPATIBLE.dimension.diagnostictext='';
            if(length(portDims)==1)&&(portDims==-1||(ischar(portDims)&&strcmp(portDims,'-1')))


                if totalDataElementNumber==1



                    ARE_DIMS_COMPATIBLE.dimension.status=true;
                else
                    ARE_DIMS_COMPATIBLE.dimension.status=2;
                    ARE_DIMS_COMPATIBLE.dimension.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDimensionsInherit');
                end


                return;
            end


            totalPortElementNumber=prod(portDims);



            if totalDataElementNumber<=totalPortElementNumber
                ARE_DIMS_COMPATIBLE.dimension.status=true;
                return;
            end

            ARE_DIMS_COMPATIBLE.dimension.status=false;
            portDim=portDims;
            if isnumeric(portDim)
                portDim=num2str(portDim);

                if any(isspace(portDim))
                    portDim=['[',portDim,']'];
                end
            end
            sigDim=sigDims;
            if isnumeric(sigDim)
                sigDim=num2str(sigDim);

                if any(isspace(sigDim))
                    sigDim=['[',sigDim,']'];
                end
            end


            ARE_DIMS_COMPATIBLE.dimension.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDimension',portDim,sigDim);
        end


        function setBlockParams(obj,blockPathToBeCreated,isModelCompiled)
            setBlockParams@Simulink.iospecification.Inport(obj,blockPathToBeCreated,isModelCompiled);

            set_param(blockPathToBeCreated,'useBusObject','on');
            set_param(blockPathToBeCreated,'BusOutputAsStruct','on');
        end


        function outSignalType=getSignalType(obj)

            outSignalType='real';

        end


        function[diagnosticStruct,BAIL_EARLY]=resolveEdgeCase(obj,diagnosticStruct,...
            ARE_DIMS_COMPATIBLE,IS_DATATYPE_COMPATIBLE,IS_SIGNALTYPE_COMPATIBLE,propertiesCompared)
            BAIL_EARLY=false;
        end


        function errMsg=getInvalidVarTypeErrorMessage(obj,portName,varName,inputVariableObj)
            errMsg=DAStudio.message('sl_iospecification:inports:assignNonBusToBusPort',portName);
        end


        function decorateOutportSettings(obj,outport)

            set_param(outport,'OutDataTypeStr',get(obj.Handle,'OutDataTypeStr'));
        end

    end

end
