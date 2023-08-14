classdef Three_LevelBridge_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SnubberResistance',[],...
        'SbubberCapacitance',[],...
        'Ron',[],...
        'ForwardVoltages',[],...
        'Device',[]...
        )


        OldDropdown=struct(...
        'Arms',[],...
        'Device',[],...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Ron',[],...
        'Rds',[],...
        'diode_Ron',[],...
        'Rs',[],...
        'Cs',[],...
        'Vf',[],...
        'diode_Vf',[],...
        'Goff',[],...
        'diode_Goff',[]...
        )


        NewDropdown=struct(...
        'device_type',[],...
        'snubber_type',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Power Electronics/Three-Level Bridge'
        NewPath='elec_conv_Three_LevelBridge/Three_LevelBridge'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=Three_LevelBridge_class(ForwardVoltages,SnubberResistance,SbubberCapacitance,Ron,Device)
            if nargin>0
                obj.OldParam.ForwardVoltages=ForwardVoltages;
                obj.OldParam.SnubberResistance=SnubberResistance;
                obj.OldParam.SbubberCapacitance=SbubberCapacitance;
                obj.OldParam.Ron=Ron;
                obj.OldParam.Device=Device;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
            obj.NewDerivedParam.Rds=max(obj.OldParam.Ron,1e-6);
            obj.NewDerivedParam.diode_Ron=max(obj.OldParam.Ron,1e-6);
            obj.NewDerivedParam.Vf=max(obj.OldParam.ForwardVoltages(1),1e-6);

            switch obj.OldParam.Device
            case{'GTO / Diodes','IGBT / Diodes'}
                obj.NewDerivedParam.diode_Vf=max(obj.OldParam.ForwardVoltages(2),1e-6);
            otherwise
                obj.NewDerivedParam.diode_Vf=1e-6;
            end

            if obj.OldParam.SnubberResistance==inf||obj.OldParam.SbubberCapacitance==0
                obj.NewDerivedParam.Goff=1e-6;
                obj.NewDerivedParam.diode_Goff=1e-6;
            elseif obj.OldParam.SbubberCapacitance==inf
                obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
            else
                obj.NewDerivedParam.Goff=1e-6;
                obj.NewDerivedParam.diode_Goff=1e-6;
                obj.NewDerivedParam.Rs=obj.OldParam.SnubberResistance;
                obj.NewDerivedParam.Cs=obj.OldParam.SbubberCapacitance;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'All device currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All device currents');
            case 'Phase-to-Neutral and DC voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Phase-to-Neutral and DC voltages');
            case 'All voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','All voltages and currents');
            end

            switch obj.OldDropdown.Arms
            case '1'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Number of bridge arms','1');
            case '2'
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Number of bridge arms','2');
            case '3'

            end

            switch obj.OldDropdown.Device
            case 'GTO / Diodes'
                obj.NewDropdown.device_type='1';
            case 'MOSFET / Diodes'
                obj.NewDropdown.device_type='4';
            case 'IGBT / Diodes'
                obj.NewDropdown.device_type='3';
            case 'Ideal Switches'
                obj.NewDropdown.device_type='2';
                logObj.addMessage(obj,'OptionNotSupported','Power Electronic device','Ideal Switches');
            end

            if ischar(obj.OldParam.SnubberResistance)
                obj.OldParam.SnubberResistance=evalin('base',obj.OldParam.SnubberResistance);
            end

            if ischar(obj.OldParam.SbubberCapacitance)
                obj.OldParam.SbubberCapacitance=evalin('base',obj.OldParam.SbubberCapacitance);
            end

            if obj.OldParam.SnubberResistance==inf||obj.OldParam.SbubberCapacitance==0
                obj.NewDropdown.snubber_type='0';
                logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device and diode is set to be 1e-6.');
            elseif obj.OldParam.SbubberCapacitance==inf
                obj.NewDropdown.snubber_type='0';
            else
                obj.NewDropdown.snubber_type='1';
            end

        end
    end

end