classdef FunctionCallPort<Simulink.iospecification.Inport





    methods(Static)


        function bool=isa(blockPath)

            try
                bool=...
                strcmpi(get_param(blockPath,'BlockType'),'inport')&&...
                strcmp(get_param(blockPath,'OutputFunctionCall'),'on');
            catch
                bool=false;
            end

        end

    end

    methods

        function outSignalType=getSignalType(obj)

            outSignalType='real';

        end


        function outDataType=getDataType(obj)

            outDataType='fcn_call';
        end


        function outDims=getDimensions(obj)
            outDims=1;
        end


        function[boolOut,err]=copyAndConnect(~,~,~,~,~)


            boolOut=true;
            err=[];
        end


        function diagnosticStruct=areCompatible(obj,inputVariableObj)









            diagnosticStruct.datatype=struct('status','diagnosticstext');
            diagnosticStruct.dimension=struct('status','diagnosticstext');
            diagnosticStruct.signaltype=struct('status','diagnosticstext');
            diagnosticStruct.portspecific='';
            diagnosticStruct.status=false;
            diagnosticStruct.modeldiagnostic=[];


            if isa(inputVariableObj,'Simulink.iospecification.GroundInput')
                diagnosticStruct.status=true;
                return;
            end


            IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj);

            if~IS_VALID_INPUTVAR_TO_COMPARE

                diagnosticStruct.modeldiagnostic=getInvalidVarTypeErrorMessage(obj,getPortName(obj),inputVariableObj.Name,inputVariableObj);
                return;
            end

            diagnosticStruct.status=2;

            diagnosticStruct.portspecific=DAStudio.message('sl_iospecification:inports:fcnCallPortResolveSampleTime');
        end


        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)

            IS_VALID_INPUTVAR_TO_COMPARE=false;
            if isa(inputVariableObj,'Simulink.iospecification.FunctionCallInput')||...
                isa(inputVariableObj,'Simulink.iospecification.GroundInput')

                IS_VALID_INPUTVAR_TO_COMPARE=true;
            end
        end


        function errMsg=getInvalidVarTypeErrorMessage(obj,portName,varName,inputVariableObj)
            errMsg=DAStudio.message('sl_iospecification:inports:assignNonFcnCalltoFcnCallPort',portName);
        end

    end
end
