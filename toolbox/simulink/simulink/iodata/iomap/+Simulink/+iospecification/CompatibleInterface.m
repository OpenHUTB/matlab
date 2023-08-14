classdef CompatibleInterface<handle





    methods(Abstract)

        outDataType=getDataType(obj)
        outDims=getDimensions(obj)
        outSignalType=getSignalType(obj)

    end


    methods


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)

            IS_VALID_INPUTVAR_TO_COMPARE=true;
        end


        function errMsg=getInvalidVarTypeErrorMessage(obj,portName,varName,inputVariableObj)
            errMsg=DAStudio.message('sl_iospecification:inports:invalidTypeToPortAssignment',portName,varName);
        end



        function diagnosticStruct=areCompatible(obj,inputVariableObj)









            diagnosticStruct.datatype=struct('status',0,'diagnosticstext','');
            diagnosticStruct.dimension=struct('status',0,'diagnosticstext','');
            diagnosticStruct.signaltype=struct('status',0,'diagnosticstext','');
            diagnosticStruct.portspecific='';
            diagnosticStruct.status=false;
            diagnosticStruct.modeldiagnostic=[];


            if isa(inputVariableObj,'Simulink.iospecification.GroundInput')
                diagnosticStruct.datatype.status=true;
                diagnosticStruct.dimension.status=true;
                diagnosticStruct.signaltype.status=true;
                diagnosticStruct.status=true;
                return;
            end


            if isa(inputVariableObj,'Simulink.iospecification.NullInput')
                diagnosticStruct.datatype.status=2;
                diagnosticStruct.dimension.status=2;
                diagnosticStruct.signaltype.status=2;
                diagnosticStruct.status=2;
                return;
            end


            IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj);

            if~IS_VALID_INPUTVAR_TO_COMPARE

                if~ischar(inputVariableObj.Name)
                    varName='';
                else
                    varName=inputVariableObj.Name;
                end


                diagnosticStruct.modeldiagnostic=getInvalidVarTypeErrorMessage(obj,getPortName(obj),varName,inputVariableObj);
                return;
            end

            [diagnosticStructDims,sigDim,portDim]=areDimsCompatible(obj,inputVariableObj);
            ARE_DIMS_COMPATIBLE=diagnosticStructDims.dimension.status;
            diagnosticStruct.dimension=diagnosticStructDims.dimension;

            [diagnosticStructDT,errMsg,sigDT,portDT]=isDataTypeCompatible(obj,inputVariableObj);

            IS_DATATYPE_COMPATIBLE=diagnosticStructDT.datatype.status;
            diagnosticStruct.datatype=diagnosticStructDT.datatype;

            if~IS_DATATYPE_COMPATIBLE
                if~isempty(errMsg)
                    diagnosticStruct.modeldiagnostic=errMsg;
                    return;
                end
            end

            [diagnosticStructSigType,sigST,portST]=isSignalTypeCompatible(obj,inputVariableObj);
            IS_SIGNALTYPE_COMPATIBLE=diagnosticStructSigType.signaltype.status;
            diagnosticStruct.signaltype=diagnosticStructSigType.signaltype;

            if~isempty(diagnosticStructSigType.signaltype.modeldiagnostic)
                diagnosticStruct.modeldiagnostic=diagnosticStructSigType.signaltype.modeldiagnostic;
            end


            ANY_ZERO=any([ARE_DIMS_COMPATIBLE,IS_DATATYPE_COMPATIBLE,IS_SIGNALTYPE_COMPATIBLE]==0);
            ANY_TWO=any([ARE_DIMS_COMPATIBLE,IS_DATATYPE_COMPATIBLE,IS_SIGNALTYPE_COMPATIBLE]==2);

            if ANY_ZERO
                diagnosticStruct.status=false;
                return;
            end

            if ANY_TWO

                if isfield(diagnosticStructDT,'portspecific')&&~isempty(diagnosticStructDT.portspecific)
                    diagnosticStruct.portspecific=diagnosticStructDT.portspecific;
                end

                diagnosticStruct.status=2;
                return;
            end


            diagnosticStruct.status=true;
        end


        function[ARE_DIMS_COMPATIBLE,inputVar_DIMS,plugin_DIMS]=areDimsCompatible(obj,inputVariableObj)



            dims1vs1xNEqual=false;

            inputVar_DIMS=inputVariableObj.getDimensions();
            plugin_DIMS=obj.getDimensions();
            ARE_DIMS_COMPATIBLE.dimension.diagnosticstext='';
            if plugin_DIMS==-1
                ARE_DIMS_COMPATIBLE.dimension.status=2;
                ARE_DIMS_COMPATIBLE.dimension.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDimensionsInherit');
                return;
            end

            if(length(inputVar_DIMS)==1&&length(plugin_DIMS)==2)




                isEQUAL_N_1=isequal([inputVar_DIMS,1],plugin_DIMS);
                isEQUAL_1_N=isequal([1,inputVar_DIMS],plugin_DIMS);

                dims1vs1xNEqual=isEQUAL_N_1||isEQUAL_1_N;
            end

            dims1vs1xNEqual_inport=false;

            if(length(plugin_DIMS)==1&&length(inputVar_DIMS)==2)




                isEQUAL_N_1_inport=isequal([plugin_DIMS,1],inputVar_DIMS);
                isEQUAL_1_N_inport=isequal([1,plugin_DIMS],inputVar_DIMS);

                dims1vs1xNEqual_inport=isEQUAL_N_1_inport||isEQUAL_1_N_inport;
            end


            dimsShapedDimEqual=false;

            try

                dimsShapedDimEqual=isequal(inputVar_DIMS,plugin_DIMS');

            catch

            end


            ARE_DIMS_COMPATIBLE.dimension.status=isequal(inputVar_DIMS,plugin_DIMS)||...
            dims1vs1xNEqual||dimsShapedDimEqual||dims1vs1xNEqual_inport;

            if~ARE_DIMS_COMPATIBLE.dimension.status
                portDim=plugin_DIMS;
                if isnumeric(portDim)
                    portDim=num2str(portDim);

                    if any(isspace(portDim))
                        portDim=['[',portDim,']'];
                    end
                end
                sigDim=inputVar_DIMS;
                if isnumeric(sigDim)
                    sigDim=num2str(sigDim);

                    if any(isspace(sigDim))
                        sigDim=['[',sigDim,']'];
                    end
                end


                ARE_DIMS_COMPATIBLE.dimension.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDimension',portDim,sigDim);

            end

        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,inputDataType,blockDT]=isDataTypeCompatible(obj,inputVariableObj)
            errMsg=[];
            blockDT=obj.getDataType();
            inputDataType=inputVariableObj.getDataType();
            IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext='';
            if contains(lower(blockDT),'inherit')
                IS_DATATYPE_COMPATIBLE.datatype.status=2;
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDataTypeInherit');
                return;
            end


            IS_DATATYPE_COMPATIBLE.datatype.status=isequal(blockDT,...
            inputDataType);

            IS_DATATYPE_COMPATIBLE.datatype.status=IS_DATATYPE_COMPATIBLE.datatype.status||...
            (strcmp(inputDataType,'logical')&&strcmp(blockDT,'boolean'));

            if~IS_DATATYPE_COMPATIBLE.datatype.status
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDataType',blockDT,inputDataType);
            end
        end


        function[IS_SIGNALTYPE_COMPATIBLE,inputVar_ST,port_ST]=isSignalTypeCompatible(obj,inputVariableObj)



            inputVar_ST=inputVariableObj.getSignalType();
            port_ST=obj.getSignalType();

            IS_SIGNALTYPE_COMPATIBLE.signaltype.diagnosticstext='';
            IS_SIGNALTYPE_COMPATIBLE.signaltype.modeldiagnostic='';
            if isInputDataTypeEnumeration(obj,inputVariableObj)

                if strcmp(obj.getSignalType(),'complex')
                    IS_SIGNALTYPE_COMPATIBLE.signaltype.status=false;
                    IS_SIGNALTYPE_COMPATIBLE.signaltype.signaltype.diagnosticstext=DAStudio.message('sl_iospecification:inports:enumsMustBeReal');
                    IS_SIGNALTYPE_COMPATIBLE.signaltype.modeldiagnostic=DAStudio.message('sl_iospecification:inports:enumsMustBeReal');
                end

            end




            if(strcmpi(port_ST,'auto')&&strcmp(inputVar_ST,'complex'))

                IS_SIGNALTYPE_COMPATIBLE.signaltype.status=2;
                IS_SIGNALTYPE_COMPATIBLE.signaltype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceSignalTypeInherit');
                return;
            end

            IS_SIGNALTYPE_COMPATIBLE.signaltype.status=isequal(port_ST,inputVar_ST)||...
            (strcmp(port_ST,'complex')&&strcmp(inputVar_ST,'real'))||...
            (strcmpi(port_ST,'auto')&&strcmp(inputVar_ST,'real'));

            if~IS_SIGNALTYPE_COMPATIBLE.signaltype.status
                IS_SIGNALTYPE_COMPATIBLE.signaltype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchSignalType',port_ST,inputVar_ST);
            end

        end


        function bool=isbuiltin(~,valueStr)
            bool=false;

            if isstring(valueStr)&&isscalar(valueStr)
                valueStr=char(valueStr);
            end


            if~ischar(valueStr)
                return;
            end

            builtIns={'double'
'single'
'int'
'int8'
'uint8'
'int16'
'uint16'
'int32'
'uint32'
'int64'
'uint64'
'boolean'
'logical'
            'half'};

            if any(ismember(builtIns,valueStr))
                bool=true;
            end

        end


        function diagnosticStruct=edgeCaseUpdates(obj,inputVariableObj,diagnosticStruct)


            if isInputDataTypeEnumeration(obj,inputVariableObj)

                if strcmp(obj.getSignalType(),'complex')
                    diagnosticStruct.status=false;
                    diagnosticStruct.modeldiagnostic=DAStudio.message('sl_iospecification:inports:enumsMustBeReal');
                end

                if(strcmp(obj.getSignalType(),'auto')||...
                    strcmp(obj.getSignalType(),'real'))&&...
                    ~strcmp(inputVariableObj.getSignalType(),'complex')


                    diagnosticStruct.status=boolDataType&&boolDimension;

                end
            end




            if strcmp(obj.getDataType(),'logical')||strcmp(obj.getDataType(),'boolean')
                if(~isa(obj.getDataType(),'struct')&&...
                    ~isempty(strfind(lower(obj.getDataType()),'inherit')))||...
                    (numel(obj.getDimensions())==1&&obj.getDimensions()==-1)


                    diagnosticStruct.status=2;
                end
            else
                if(~isa(obj.getDataType(),'struct')&&...
                    ~isempty(strfind(lower(obj.getDataType()),'inherit')))||...
                    ~isempty(strfind(lower(obj.getSignalType()),'auto'))||...
                    (numel(obj.getDimensions())==1&&obj.getDimensions()==-1)


                    diagnosticStruct.status=2;
                end
            end
        end


        function bool=isInputDataTypeEnumeration(~,inputVariableObj)
            bool=false;

            varDT=inputVariableObj.getDataType();
            if(exist(varDT,'file')==2)&&~isempty(enumeration(varDT))
                bool=true;
            end

        end


        function[diagnosticStruct,BAIL_EARLY]=resolveEdgeCase(obj,diagnosticStruct,...
            ARE_DIMS_COMPATIBLE,IS_DATATYPE_COMPATIBLE,IS_SIGNALTYPE_COMPATIBLE,propertiesCompared)

            portDataType=propertiesCompared.Inport.DataType;
            portDimension=propertiesCompared.Inport.Dimension;

            IS_PORT_BUILTIN=isbuiltin(obj,portDataType);
            IS_PORT_DATATYPE_AFILE=(exist(portDataType,'file')==2);

            portComplexity=obj.getSignalType();

            dataComplexity=propertiesCompared.Inport.SignalType;

            BAIL_EARLY=false;

            if~isstruct(portDataType)&&~IS_PORT_BUILTIN&&IS_PORT_DATATYPE_AFILE

                if strcmpi(portComplexity,'complex')
                    diagnosticStruct.signaltype.status=false;

                    diagnosticStruct.signaltype.diagnosticstext=DAStudio.message('sl_iospecification:inports:enumsMustBeReal');
                    diagnosticStruct.status=false;

                end

                if(strcmp(portComplexity,'auto')||...
                    strcmp(portComplexity,'real'))&&~strcmp(dataComplexity,'complex')

                    diagnosticStruct.datatype.status=IS_DATATYPE_COMPATIBLE;

                    if diagnosticStruct.datatype.status==2

                        diagnosticStruct.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleInterfaceDataTypeInherit');
                    elseif~diagnosticStruct.datatype.status


                        sigDT=propertiesCompared.Variable.DataType;

                        diagnosticStruct.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDataType',portDataType,sigDT);
                    end

                    diagnosticStruct.dimension.status=ARE_DIMS_COMPATIBLE;
                    diagnosticStruct.status=IS_DATATYPE_COMPATIBLE&&ARE_DIMS_COMPATIBLE;
                    BAIL_EARLY=true;


                end

            end

            [BAIL_EARLY,diagnosticStruct.status]=...
            resolveStatusForLogicalAndInHeritCases(obj,portDataType,...
            portDimension,portComplexity,diagnosticStruct.status,BAIL_EARLY);

        end


        function[BAIL_EARLY,statusUpdate]=resolveStatusForLogicalAndInHeritCases(obj,portDataType,portDimension,portComplexity,statusUpdate,BAIL_EARLY)

            if strcmp(portDataType,'logical')||strcmp(portDataType,'boolean')
                if(~isa(portDataType,'struct')&&...
                    ~isempty(strfind(lower(portDataType),'inherit')))||...
                    (numel(portDimension)==1&&portDimension==-1)
                    statusUpdate=2;
                    BAIL_EARLY=true;
                end
            else

                if(~isa(portDataType,'struct')&&~isempty(strfind(lower(portDataType),'inherit')))

                    statusUpdate=2;
                    BAIL_EARLY=true;
                end

            end
        end


        function dataTypeStr=formatIfEnum(~,dataTypeStr)

            enumIdx=strfind(dataTypeStr,'?');
            if~isempty(enumIdx)
                dataTypeStr=strtrim(dataTypeStr(strfind(dataTypeStr,'?')+1:length(dataTypeStr)));
            else

                if~isempty(strfind(dataTypeStr,'Enum:'))

                    dataTypeStr=strtrim(dataTypeStr(strfind(dataTypeStr,'Enum:')+length('Enum:'):length(dataTypeStr)));
                end
            end
        end


        function outDataType=getCompiledDataTypeFromPort(obj)

            temp=get_param(obj.Handle,'CompiledPortDataTypes');

            if isempty(temp.Outport)
                return;
            end

            compiledDataType=temp.Outport{1};
            s=regexp(compiledDataType,'str\d+');
            if~isempty(s)
                compiledDataType='string';
            end

            if~isempty(compiledDataType)&&(isbuiltin(obj,compiledDataType)||strcmp(compiledDataType,'string'))
                outDataType=compiledDataType;
                return;
            end




            if~isbuiltin(obj,origDataTypeStr)&&...
                ~isempty(compiledDataType)&&...
                ~strcmp(compiledDataType,origDataTypeStr)&&...
                (~isempty(strfind(origDataTypeStr,'fixdt'))||...
                isempty(strfind(origDataTypeStr,'Inherit:')))&&...
                isempty(strfind(origDataTypeStr,'Bus'))&&...
                isempty(strfind(origDataTypeStr,'Enum'))

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

                        OVERRIDE_INPORT_PROP_DATATYPE=false;
                        switch dataProps.DataType

                        case 'uint8'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(0,8,0)');
                        case 'int8'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(1,8,0)');
                        case 'uint16'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(0,16,0)');
                        case 'int16'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(1,16,0)');
                        case 'uint32'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(0,32,0)');
                        case 'int32'
                            OVERRIDE_INPORT_PROP_DATATYPE=strcmp(compiledDataType,'fixdt(1,32,0)');
                        end

                        if OVERRIDE_INPORT_PROP_DATATYPE
                            compiledDataType=dataProps.DataType;
                        end





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
                outDataType=compiledDataType;

            end
        end


        function result=getComplexString(~,isComplex)

            if isComplex
                result='complex';
            else
                result='real';
            end
        end
    end

end
