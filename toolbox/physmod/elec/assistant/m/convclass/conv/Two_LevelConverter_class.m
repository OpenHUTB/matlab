classdef Two_LevelConverter_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ron',[],...
        'Rs',[],...
        'Cs',[],...
        'Vforward',[],...
        'Ron_Diode',[],...
        'Rs_Diode',[],...
        'Cs_Diode',[],...
        'Vf_Diode',[],...
        'Rs_CurrentSource',[]...
        )


        OldDropdown=struct(...
        'ModelType',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Ron',[],...
        'Goff',[],...
        'Vf',[],...
        'diode_Vf',[],...
        'diode_Goff',[],...
        'diode_Ron',[],...
        'Rs',[],...
        'Cs',[]...
        )


        NewDropdown=struct(...
        'snubber_type',[]...
        )


        BlockOption={...
        {'ModelType','Switching devices'},'sd';...
        {'ModelType','Switching function'},'sf';...
        {'ModelType','Average model (Uref-controlled)'},'Uref';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Power Electronics/Two-Level Converter'
        NewPath='elec_conv_Two_LevelConverter/Two_LevelConverter'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=Two_LevelConverter_class(ModelType,Ron,Rs,Cs,Ron_Diode,Rs_Diode,Cs_Diode,Vf_Diode)
            if nargin>0
                obj.OldDropdown.ModelType=ModelType;
                obj.OldParam.Ron=Ron;
                obj.OldParam.Rs=Rs;
                obj.OldParam.Cs=Cs;
                obj.OldParam.Ron_Diode=Ron_Diode;
                obj.OldParam.Rs_Diode=Rs_Diode;
                obj.OldParam.Cs_Diode=Cs_Diode;
                obj.OldParam.Vf_Diode=Vf_Diode;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.ModelType
            case 'Switching devices'
                obj.NewDerivedParam.Vf=1e-6;
                obj.NewDerivedParam.Ron=obj.OldParam.Ron;
                obj.NewDerivedParam.diode_Vf=1e-6;
                obj.NewDerivedParam.diode_Ron=obj.OldParam.Ron;
                if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                    obj.NewDerivedParam.Goff=1e-6;
                    obj.NewDerivedParam.diode_Goff=1e-6;
                elseif obj.OldParam.Cs==inf
                    obj.NewDerivedParam.Goff=max(1/obj.OldParam.Rs,1e-6);
                    obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.Rs,1e-6);
                else
                    obj.NewDerivedParam.Goff=1e-6;
                    obj.NewDerivedParam.diode_Goff=1e-6;
                    obj.NewDerivedParam.Rs=obj.OldParam.Rs;
                    obj.NewDerivedParam.Cs=obj.OldParam.Cs;
                end

            case 'Switching function'
                obj.NewDerivedParam.Ron=obj.OldParam.Ron_Diode;
                obj.NewDerivedParam.diode_Vf=obj.OldParam.Vf_Diode;
                obj.NewDerivedParam.diode_Ron=obj.OldParam.Ron_Diode;
                if obj.OldParam.Rs_Diode==inf||obj.OldParam.Cs_Diode==0
                    obj.NewDerivedParam.diode_Goff=1e-6;
                elseif obj.OldParam.Cs_Diode==inf
                    obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.Rs_Diode,1e-6);
                else
                    obj.NewDerivedParam.diode_Goff=1e-6;
                end

            otherwise

            end

        end

        function obj=objDropdownMapping(obj)

            logObj=ElecAssistantLog.getInstance();

            switch obj.OldDropdown.ModelType

            case 'Switching devices'

                if ischar(obj.OldParam.Rs)
                    obj.OldParam.Rs=evalin('base',obj.OldParam.Rs);
                end

                if ischar(obj.OldParam.Cs)
                    obj.OldParam.Cs=evalin('base',obj.OldParam.Cs);
                end

                if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                    obj.NewDropdown.snubber_type='0';
                    logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                elseif obj.OldParam.Cs==inf
                    obj.NewDropdown.snubber_type='0';
                else
                    obj.NewDropdown.snubber_type='1';
                end

            case 'Switching function'

                if ischar(obj.OldParam.Rs_Diode)
                    obj.OldParam.Rs_Diode=evalin('base',obj.OldParam.Rs_Diode);
                end

                if ischar(obj.OldParam.Cs_Diode)
                    obj.OldParam.Cs_Diode=evalin('base',obj.OldParam.Cs_Diode);
                end

                if obj.OldParam.Rs_Diode==inf||obj.OldParam.Cs_Diode==0
                    logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-conductance of device is set to be 1e-6.');
                elseif obj.OldParam.Cs_Diode==inf

                else
                    logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-conductance of device is set to be 1e-6.');
                end
                logObj.addMessage(obj,'ParameterNotSupported','Current source snubber resistance (Ohms)');

            otherwise
                logObj.addMessage(obj,'ParameterNotSupported','Diode on-state resistance (Ohms)');
                logObj.addMessage(obj,'ParameterNotSupported','Diode snubber resistance (Ohms)');
                logObj.addMessage(obj,'ParameterNotSupported','Diode snubber capacitance (F)');
                logObj.addMessage(obj,'ParameterNotSupported','Diode forward voltage (V)');
                logObj.addMessage(obj,'ParameterNotSupported','Current source snubber resistance (Ohms)');
            end
        end
    end

end
