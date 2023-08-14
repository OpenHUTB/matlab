classdef RootInport<Simulink.iospecification.Inport





    methods(Static)


        function bool=isa(blockPath)

            bool=false;
            try
                portType=get_param(blockPath,'BlockType');
                boolInportType=strcmpi('inport',portType);
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
                boolFCN=strcmp(get_param(blockPath,'OutputFunctionCall'),'on');
            catch
                boolFCN=false;
            end

            try
                IS_USE_BUS_OBJ=strcmpi(get_param(blockPath,'UseBusObject'),'on');
            catch
                IS_USE_BUS_OBJ=false;
            end

            try
                boolBusEl=strcmpi(get_param(blockPath,'IsBusElementPort'),'on');
            catch
                boolBusEl=false;
            end
            bool=boolInportType&&boolROOT&&~IS_USE_BUS_OBJ&&~boolFCN&&~boolBusEl;


        end



    end

    methods


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)

            IS_VALID_INPUTVAR_TO_COMPARE=false;

            if isa(inputVariableObj,'Simulink.iospecification.LoggedSignalInput')

                IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj.ValueInputVariable);
                return;
            end

            if isa(inputVariableObj,'Simulink.iospecification.TimeseriesInput')||...
                isa(inputVariableObj,'Simulink.iospecification.TimetableInput')||...
                isa(inputVariableObj,'Simulink.iospecification.SingleInputDataArray')||...
                isa(inputVariableObj,'Simulink.iospecification.GroundInput')

                IS_VALID_INPUTVAR_TO_COMPARE=true;
            end
        end


        function errMsg=getInvalidVarTypeErrorMessage(obj,portName,varName,inputVariableObj)

            errMsg=DAStudio.message('sl_iospecification:inports:invalidTypeToPortAssignment',portName,varName);

            if isa(inputVariableObj,'Simulink.iospecification.BusInput')
                errMsg=DAStudio.message('sl_iospecification:inports:assignBusSigToRootInport',portName);
            elseif isa(inputVariableObj,'Simulink.iospecification.FunctionCallInput')
                errMsg=DAStudio.message('sl_iospecification:inports:assignFunctionCallSigToRootInport',portName);
            end


        end

    end
end
