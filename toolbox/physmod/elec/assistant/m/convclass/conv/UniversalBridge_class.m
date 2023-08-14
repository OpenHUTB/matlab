classdef UniversalBridge_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SnubberResistance',[],...
        'SnubberCapacitance',[],...
        'Ron',[],...
        'Lon',[],...
        'ForwardVoltages',[],...
        'ForwardVoltage',[]...
        )


        OldDropdown=struct(...
        'Arms',[],...
        'Device',[],...
        'Measurements',[],...
        'Measurements_2',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Ron',[],...
        'Rds',[],...
        'Goff',[],...
        'Vf',[],...
        'diode_Vf',[],...
        'diode_Ron',[],...
        'diode_Goff',[],...
        'Rs',[],...
        'Cs',[]...
        )


        NewDropdown=struct(...
        'device_type',[],...
        'diode_param',[],...
        'snubber_type',[]...
        )


        BlockOption={...
        {'Arms','3';'Device','Diodes'},'diodes3';...
        {'Arms','2';'Device','Diodes'},'diodes2';...
        {'Arms','1';'Device','Diodes'},'diodes1';...
        {'Arms','3';'Device','Thyristors'},'converter3_Thyristors';...
        {'Arms','2';'Device','Thyristors'},'converter2_Thyristors';...
        {'Arms','1';'Device','Thyristors'},'converter1_Thyristors';...
        {'Arms','3';'Device','GTO / Diodes'},'converter3';...
        {'Arms','2';'Device','GTO / Diodes'},'converter2_GTO';...
        {'Arms','1';'Device','GTO / Diodes'},'converter1_GTO';...
        {'Arms','3';'Device','MOSFET / Diodes'},'converter3';...
        {'Arms','2';'Device','MOSFET / Diodes'},'converter2_MOSFET';...
        {'Arms','1';'Device','MOSFET / Diodes'},'converter1_MOSFET';...
        {'Arms','3';'Device','IGBT / Diodes'},'converter3';...
        {'Arms','2';'Device','IGBT / Diodes'},'converter2_IGBT';...
        {'Arms','1';'Device','IGBT / Diodes'},'converter1_IGBT';...
        {'Arms','3';'Device','Ideal Switches'},'converter3';...
        {'Arms','2';'Device','Ideal Switches'},'converter2_Ideal';...
        {'Arms','1';'Device','Ideal Switches'},'converter1_Ideal';...
        {'Arms','3';'Device','Switching-function based VSC'},'converter3';...
        {'Arms','2';'Device','Switching-function based VSC'},'converter2_Ideal';...
        {'Arms','1';'Device','Switching-function based VSC'},'converter1_Ideal';...
        {'Arms','3';'Device','Average-model based VSC'},'vsc3';...
        {'Arms','2';'Device','Average-model based VSC'},'vsc2';...
        {'Arms','1';'Device','Average-model based VSC'},'vsc1'
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Power Electronics/Universal Bridge'
        NewPath='elec_conv_UniversalBridge/UniversalBridge'
    end


    methods

        function obj=objParamMappingDirect(obj)
        end


        function obj=UniversalBridge_class(Arms,Device,ForwardVoltages,ForwardVoltage,SnubberResistance,SnubberCapacitance,Ron)
            if nargin>0
                obj.OldDropdown.Arms=Arms;
                obj.OldDropdown.Device=Device;
                obj.OldParam.ForwardVoltages=ForwardVoltages;
                obj.OldParam.ForwardVoltage=ForwardVoltage;
                obj.OldParam.SnubberResistance=SnubberResistance;
                obj.OldParam.SnubberCapacitance=SnubberCapacitance;
                obj.OldParam.Ron=Ron;
            end
        end

        function obj=objParamMappingDerived(obj)


            switch obj.OldDropdown.Device
            case 'Diodes'
                obj.NewDerivedParam.Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.Vf=max(obj.OldParam.ForwardVoltage,1e-6);
                if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                    obj.NewDerivedParam.Goff=1e-6;
                elseif obj.OldParam.SnubberCapacitance==inf
                    obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                else
                    obj.NewDerivedParam.Goff=1e-6;
                end

            case 'Thyristors'
                obj.NewDerivedParam.Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.Vf=max(obj.OldParam.ForwardVoltage,1e-6);
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.Rs=obj.OldParam.SnubberResistance;
                        obj.NewDerivedParam.Cs=obj.OldParam.SnubberCapacitance;
                    end
                end

            case{'GTO / Diodes','IGBT / Diodes'}
                obj.NewDerivedParam.Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.Vf=max(obj.OldParam.ForwardVoltages(1),1e-6);
                obj.NewDerivedParam.diode_Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.diode_Ron=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.diode_Vf=max(obj.OldParam.ForwardVoltages(2),1e-6);
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                        obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                        obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                        obj.NewDerivedParam.Rs=obj.OldParam.SnubberResistance;
                        obj.NewDerivedParam.Cs=obj.OldParam.SnubberCapacitance;
                    end
                end

            case 'MOSFET / Diodes'
                obj.NewDerivedParam.Rds=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.Rds=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.diode_Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.diode_Ron=max(obj.OldParam.Ron,1e-6);
                obj.NewDerivedParam.diode_Vf=1e-6;
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                        obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                        obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.diode_Goff=1e-6;
                        obj.NewDerivedParam.Rs=obj.OldParam.SnubberResistance;
                        obj.NewDerivedParam.Cs=obj.OldParam.SnubberCapacitance;
                    end
                end

            case 'Ideal Switches'
                obj.NewDerivedParam.Ron=min(obj.OldParam.Ron,1e6);
                obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDerivedParam.Goff=1e-6;
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDerivedParam.Goff=max(1/obj.OldParam.SnubberResistance,1e-6);
                    else
                        obj.NewDerivedParam.Goff=1e-6;
                        obj.NewDerivedParam.Rs=obj.OldParam.SnubberResistance;
                        obj.NewDerivedParam.Cs=obj.OldParam.SnubberCapacitance;
                    end
                end

            case 'Switching-function based VSC'
                obj.NewDerivedParam.Ron=1e-6;
                obj.NewDerivedParam.Goff=1e-6;

            otherwise

            end


        end

        function obj=objDropdownMapping(obj)

            logObj=ElecAssistantLog.getInstance();

            if ischar(obj.OldParam.SnubberResistance)
                obj.OldParam.SnubberResistance=evalin('base',obj.OldParam.SnubberResistance);
            end

            if ischar(obj.OldParam.SnubberCapacitance)
                obj.OldParam.SnubberCapacitance=evalin('base',obj.OldParam.SnubberCapacitance);
            end


            switch obj.OldDropdown.Device
            case 'Diodes'
                if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                    logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                elseif obj.OldParam.SnubberCapacitance==inf

                else
                    logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                end
            case 'Thyristors'
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf

                    else
                        logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDropdown.snubber_type='0';
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDropdown.snubber_type='0';
                    else
                        obj.NewDropdown.snubber_type='1';
                    end
                end
            case 'GTO / Diodes'
                obj.NewDropdown.device_type='1';
                obj.NewDropdown.diode_param='2';
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf

                    else
                        logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDropdown.snubber_type='0';
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDropdown.snubber_type='0';
                    else
                        obj.NewDropdown.snubber_type='1';
                    end
                end

            case 'IGBT / Diodes'
                obj.NewDropdown.device_type='3';
                obj.NewDropdown.diode_param='2';
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf

                    else
                        logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDropdown.snubber_type='0';
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDropdown.snubber_type='0';
                    else
                        obj.NewDropdown.snubber_type='1';
                    end
                end

            case 'MOSFET / Diodes'
                obj.NewDropdown.device_type='4';
                obj.NewDropdown.diode_param='2';
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf

                    else
                        logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDropdown.snubber_type='0';
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDropdown.snubber_type='0';
                    else
                        obj.NewDropdown.snubber_type='1';
                    end
                end

            case 'Ideal Switches'
                obj.NewDropdown.device_type='2';
                obj.NewDropdown.diode_param='1';
                switch obj.OldDropdown.Arms
                case{'1','2'}
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf

                    else
                        logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    end
                otherwise
                    if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                        obj.NewDropdown.snubber_type='0';
                        logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                    elseif obj.OldParam.SnubberCapacitance==inf
                        obj.NewDropdown.snubber_type='0';
                    else
                        obj.NewDropdown.snubber_type='1';
                    end
                end

            case 'Switching-function based VSC'
                obj.NewDropdown.device_type='2';
                obj.NewDropdown.diode_param='1';
                if strcmp(obj.OldDropdown.Arms,'3')
                    obj.NewDropdown.snubber_type='0';
                end

            otherwise

            end

            switch obj.OldDropdown.Device
            case{'Diodes','Thyristors'}
                logObj.addMessage(obj,'CustomMessage','Inductance Lon (H) not imported');
            otherwise

            end

        end
    end

end