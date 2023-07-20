classdef Three_PhaseSeriesRLCBran_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Resistance',[],...
        'Inductance',[],...
        'Capacitance',[]...
        )


        OldDropdown=struct(...
        'BranchType',[],...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'R',[],...
        'L',[],...
        'C',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'component_structure',[]...
        )


        BlockOption={...
        {'BranchType','Open circuit';},'OpenCircuit';...
        {},'Normal';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Series RLC Branch'
        NewPath='elec_conv_Three_PhaseSeriesRLCBran/Three_PhaseSeriesRLCBran'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.R=obj.OldParam.Resistance;
            obj.NewDirectParam.L=obj.OldParam.Inductance;
            obj.NewDirectParam.C=obj.OldParam.Capacitance;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Branch voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages');
            case 'Branch currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch currents');
            case 'Branch voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages and currents');
            end


            switch obj.OldDropdown.BranchType
            case 'RLC'
                obj.NewDropdown.component_structure='7';
            case 'R'
                obj.NewDropdown.component_structure='1';
            case 'L'
                obj.NewDropdown.component_structure='2';
            case 'C'
                obj.NewDropdown.component_structure='3';
            case 'RL'
                obj.NewDropdown.component_structure='4';
            case 'RC'
                obj.NewDropdown.component_structure='5';
            case 'LC'
                obj.NewDropdown.component_structure='6';
            case 'Open circuit'

            otherwise

            end

            switch obj.OldDropdown.BranchType
            case{'L','RL'}
                logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
            case{'C','RC'}
                logObj.addMessage(obj,'CustomMessage','The capacitor voltage might start from an undesired value.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
            case{'LC','RLC'}
                logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                logObj.addMessage(obj,'CustomMessage','The capacitor voltage might start from an undesired value.');
                logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
            otherwise

            end

        end
    end

end
