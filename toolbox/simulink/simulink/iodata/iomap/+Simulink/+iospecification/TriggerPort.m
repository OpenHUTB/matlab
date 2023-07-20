classdef TriggerPort<Simulink.iospecification.Inport





    methods(Static)


        function bool=isa(blockPath)
            try
                portType=get_param(blockPath,'BlockType');
                bool=strcmpi('TriggerPort',portType);
            catch
                bool=false;
            end

        end

    end

    methods



        function create(obj,blockPathToBeCreated)
            add_block('built-in/Inport',blockPathToBeCreated);
        end


        function outSignalType=getSignalType(obj)

            outSignalType='real';

        end


        function setBlockParams(obj,blockPathToBeCreated,isModelCompiled)


            inportHandle=get_param(blockPathToBeCreated','Handle');
            if isModelCompiled






                if strcmpi(get_param(obj.Handle,'OutDataTypeStr'),'Inherit: auto')
                    OutDataTypeStruct=get_param(obj.Handle,'CompiledPortDataTypes');
                    if~isempty(OutDataTypeStruct.Outport)
                        set_param(inportHandle,'OutDataTypeStr',OutDataTypeStruct.Outport{1});
                    end
                else
                    set_param(inportHandle,'OutDataTypeStr',get_param(obj.Handle,'OutDataTypeStr'));
                end


                if strcmp(strtrim(get_param(obj.Handle,'PortDimensions')),'-1')
                    PortDimensionsStruct=get_param(obj.Handle,'CompiledPortDimensions');
                    if~isempty(PortDimensionsStruct.Outport)
                        set_param(inportHandle,'PortDimensions',['[',num2str(PortDimensionsStruct.Outport(2:end)),']']);
                    end
                else
                    set_param(inportHandle,'PortDimensions',get_param(obj.Handle,'PortDimensions'));
                end













                set_param(inportHandle,'OutMin',get_param(obj.Handle,'OutMin'));
                set_param(inportHandle,'OutMax',get_param(obj.Handle,'OutMax'));
                set_param(inportHandle,'Interpolate',get_param(obj.Handle,'Interpolate'));

            else
                set_param(inportHandle,'OutDataTypeStr',get_param(obj.Handle,'OutDataTypeStr'));
                set_param(inportHandle,'PortDimensions',get_param(obj.Handle,'PortDimensions'));
                set_param(inportHandle,'OutMin',get_param(obj.Handle,'OutMin'));
                set_param(inportHandle,'OutMax',get_param(obj.Handle,'OutMax'));
                set_param(inportHandle,'Interpolate',get_param(obj.Handle,'Interpolate'));

            end
        end


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
    end
end
