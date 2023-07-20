classdef Three_PhaseHarmonicFilte_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ParNom',[],...
        'Qc',[],...
        'Fr',[],...
        'Frd',[],...
        'Q',[]...
        )


        OldDropdown=struct(...
        'FilterType',[],...
        'FilterConnection',[],...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'QRated',[],...
        'VRated',[],...
        'FRated',[],...
        'qfactor',[],...
        'ftuned',[],...
        'ftuned1',[],...
        'ftuned2',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'type_option',[],...
        'connection_option',[]...
        )


        BlockOption={...
        {'FilterConnection','Y (grounded)'},'noneutral';...
        {'FilterConnection','Y (floating)'},'noneutral';...
        {'FilterConnection','Y (neutral)'},'neutral';...
        {'FilterConnection','Delta'},'noneutral';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Harmonic Filter'
        NewPath='elec_conv_Three_PhaseHarmonicFilte/Three_PhaseHarmonicFilte'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.VRated=ConvClass.mapDirect(obj.OldParam.ParNom,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.ParNom,2);
            obj.NewDirectParam.QRated=obj.OldParam.Qc;
            obj.NewDirectParam.ftuned=obj.OldParam.Fr;
            obj.NewDirectParam.ftuned1=ConvClass.mapDirect(obj.OldParam.Frd,1);
            obj.NewDirectParam.ftuned2=ConvClass.mapDirect(obj.OldParam.Frd,2);
            obj.NewDirectParam.qfactor=obj.OldParam.Q;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'Branch voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages')
            case 'Branch currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch currents')
            case 'Branch voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltages and currents')
            end


            switch obj.OldDropdown.FilterType
            case 'Single-tuned'
                obj.NewDropdown.type_option='1';
            case 'Double-tuned'
                obj.NewDropdown.type_option='2';
            case 'High-pass'
                obj.NewDropdown.type_option='3';
            case 'C-type High-pass'
                obj.NewDropdown.type_option='4';
            end

            switch obj.OldDropdown.FilterConnection
            case 'Y (grounded)'
                obj.NewDropdown.connection_option='3';
            case 'Y (floating)'
                obj.NewDropdown.connection_option='1';
            case 'Y (neutral)'
                obj.NewDropdown.connection_option='2';
            case 'Delta'
                obj.NewDropdown.connection_option='4';
            end

        end
    end

end
