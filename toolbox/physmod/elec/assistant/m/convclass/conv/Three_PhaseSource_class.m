classdef Three_PhaseSource_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Voltage',[],...
        'PhaseAngle',[],...
        'Voltage_phases',[],...
        'PhaseAngles_phases',[],...
        'Frequency',[],...
        'Resistance',[],...
        'Inductance',[],...
        'ShortCircuitLevel',[],...
        'BaseVoltage',[],...
        'XRratio',[],...
        'Pref',[],...
        'Qref',[],...
        'Prefabc',[],...
        'Qrefabc',[],...
        'Qmin',[],...
        'Qmax',[]...
        )


        OldDropdown=struct(...
        'InternalConnection',[],...
        'BusType',[],...
        'VoltagePhases',[],...
        'NonIdealSource',[],...
        'SpecifyImpedance',[]...
        )


        NewDirectParam=struct(...
        'vline_rms',[],...
        'shift',[],...
        'freq',[],...
        'SShortCircuit',[],...
        'XR',[]...
        )


        NewDerivedParam=struct(...
        'R',[],...
        'L',[]...
        )


        NewDropdown=struct(...
        'impedance_option',[]...
        )


        BlockOption={...
        {'InternalConnection','Y';},'Y';...
        {'InternalConnection','Yn';},'Yn';...
        {'InternalConnection','Yg';},'Yg';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Electrical Sources/Three-Phase Source'
        NewPath='elec_conv_Three_PhaseSource/Three_PhaseSource'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.vline_rms=obj.OldParam.Voltage;
            obj.NewDirectParam.shift=obj.OldParam.PhaseAngle;
            obj.NewDirectParam.freq=obj.OldParam.Frequency;
            obj.NewDirectParam.SShortCircuit=obj.OldParam.ShortCircuitLevel;
            obj.NewDirectParam.XR=obj.OldParam.XRratio;
        end


        function obj=Three_PhaseSource_class(Voltage,Frequency,Resistance,Inductance,...
            ShortCircuitLevel,BaseVoltage,XRratio,...
            NonIdealSource,SpecifyImpedance)
            if nargin>0
                obj.OldParam.Voltage=Voltage;
                obj.OldParam.Frequency=Frequency;
                obj.OldParam.Resistance=Resistance;
                obj.OldParam.Inductance=Inductance;
                obj.OldParam.ShortCircuitLevel=ShortCircuitLevel;
                obj.OldParam.BaseVoltage=BaseVoltage;
                obj.OldParam.XRratio=XRratio;
                obj.OldDropdown.NonIdealSource=NonIdealSource;
                obj.OldDropdown.SpecifyImpedance=SpecifyImpedance;
            end
        end


        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.R=obj.OldParam.Resistance;
            obj.NewDerivedParam.L=obj.OldParam.Inductance;

            if strcmp(obj.OldDropdown.NonIdealSource,'on')&&...
                strcmp(obj.OldDropdown.SpecifyImpedance,'on')
                if obj.OldParam.Voltage~=obj.OldParam.BaseVoltage
                    [R_value,L_value]=ee.internal.declaration.sources.voltage.shortcircuit(obj.OldParam.BaseVoltage,...
                    obj.OldParam.Frequency,...
                    obj.OldParam.ShortCircuitLevel,...
                    obj.OldParam.XRratio);
                    obj.NewDerivedParam.R=R_value;
                    obj.NewDerivedParam.L=L_value;
                end
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            if strcmp(obj.OldDropdown.VoltagePhases,'on')
                logObj.addMessage(obj,'CheckboxNotSupported','Specify internal voltages for each phase');
            end

            if ischar(obj.OldParam.Resistance)
                ResistanceValue=evalin('base',obj.OldParam.Resistance);
            else
                ResistanceValue=obj.OldParam.Resistance;
            end

            if ischar(obj.OldParam.Inductance)
                InductanceValue=evalin('base',obj.OldParam.Inductance);
            else
                InductanceValue=obj.OldParam.Inductance;
            end

            if ischar(obj.OldParam.Voltage)
                VoltageValue=evalin('base',obj.OldParam.Voltage);
            else
                VoltageValue=obj.OldParam.Voltage;
            end

            if ischar(obj.OldParam.BaseVoltage)
                BaseVoltageValue=evalin('base',obj.OldParam.BaseVoltage);
            else
                BaseVoltageValue=obj.OldParam.BaseVoltage;
            end


            if strcmp(obj.OldDropdown.NonIdealSource,'on')&&...
                strcmp(obj.OldDropdown.SpecifyImpedance,'on')
                if VoltageValue~=BaseVoltageValue
                    obj.NewDropdown.impedance_option='4';
                else
                    obj.NewDropdown.impedance_option='1';
                end
            elseif strcmp(obj.OldDropdown.NonIdealSource,'on')&&...
                strcmp(obj.OldDropdown.SpecifyImpedance,'off')
                obj.NewDropdown.impedance_option='4';
                if ResistanceValue==0
                    obj.NewDropdown.impedance_option='3';
                end
                if InductanceValue==0
                    obj.NewDropdown.impedance_option='2';
                end
                if ResistanceValue==0&&InductanceValue==0
                    obj.NewDropdown.impedance_option='0';
                end
            elseif strcmp(obj.OldDropdown.NonIdealSource,'off')&&...
                strcmp(obj.OldDropdown.SpecifyImpedance,'off')
                obj.NewDropdown.impedance_option='0';
            else
                obj.NewDropdown.impedance_option='0';
            end
        end
    end

end
