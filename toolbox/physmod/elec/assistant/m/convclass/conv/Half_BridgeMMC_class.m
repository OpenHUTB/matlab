classdef Half_BridgeMMC_class<ConvClass&handle



    properties

        OldParam=struct(...
        'n',[],...
        'C',[],...
        'Vc_Initial',[],...
        'Ron',[],...
        'Rs',[],...
        'Cs',[],...
        'Ron_Diode',[],...
        'Rs_Diode',[],...
        'Cs_Diode',[],...
        'Vf_Diode',[],...
        'Rs_CurrentSource',[],...
        'Ts',[]...
        )


        OldDropdown=struct(...
        'ModelType',[]...
        )


        NewDirectParam=struct(...
        'Nsm',[]...
        )


        NewDerivedParam=struct(...
        'Csm',[],...
        'vc_init',[],...
        'IGBT_Ron',[],...
        'IGBT_Goff',[],...
        'diode_Vf',[],...
        'diode_Ron',[],...
        'diode_Goff',[],...
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
        {'ModelType','Aggregate model'},'Agg';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Power Electronics/Half-Bridge MMC'
        NewPath='elec_conv_Half_BridgeMMC/Half_BridgeMMC'
    end
    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Nsm=obj.OldParam.n;
        end


        function obj=Half_BridgeMMC_class(ModelType,C,Vc_Initial,Ron,Rs,Cs,Ron_Diode,Rs_Diode,Cs_Diode,Vf_Diode)
            if nargin>0
                obj.OldDropdown.ModelType=ModelType;
                obj.OldParam.C=C;
                obj.OldParam.Vc_Initial=Vc_Initial;
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

            if strcmp(obj.OldDropdown.ModelType,'Switching devices')
                obj.NewDerivedParam.Csm=obj.OldParam.C;
                obj.NewDerivedParam.vc_init=obj.OldParam.Vc_Initial;
                obj.NewDerivedParam.diode_Vf=1e-3;
                obj.NewDerivedParam.IGBT_Ron=max(obj.OldParam.Ron,1e-3);
                obj.NewDerivedParam.diode_Ron=max(obj.OldParam.Ron,1e-3);
                if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                    obj.NewDerivedParam.IGBT_Goff=1e-6;
                    obj.NewDerivedParam.diode_Goff=1e-6;
                elseif obj.OldParam.Cs==inf
                    obj.NewDerivedParam.IGBT_Goff=max(1/obj.OldParam.Rs,1e-6);
                    obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.Rs,1e-6);
                else
                    obj.NewDerivedParam.IGBT_Goff=1e-6;
                    obj.NewDerivedParam.diode_Goff=1e-6;
                    obj.NewDerivedParam.Rs=obj.OldParam.Rs;
                    obj.NewDerivedParam.Cs=obj.OldParam.Cs;
                end

            elseif strcmp(obj.OldDropdown.ModelType,'Switching function')||strcmp(obj.OldDropdown.ModelType,'Average model (Uref-controlled)')

                if ischar(obj.OldParam.C)
                    obj.OldParam.C=evalin('base',obj.OldParam.C);
                end
                if length(obj.OldParam.C)~=1
                    obj.NewDerivedParam.Csm=obj.OldParam.C(1);
                else
                    obj.NewDerivedParam.Csm=obj.OldParam.C;
                end

                if ischar(obj.OldParam.Vc_Initial)
                    obj.OldParam.Vc_Initial=evalin('base',obj.OldParam.Vc_Initial);
                end
                if length(obj.OldParam.Vc_Initial)~=1
                    obj.NewDerivedParam.vc_init=obj.OldParam.Vc_Initial(1);
                else
                    obj.NewDerivedParam.vc_init=obj.OldParam.Vc_Initial;
                end

                obj.NewDerivedParam.diode_Vf=max(obj.OldParam.Vf_Diode,1e-3);
                obj.NewDerivedParam.diode_Ron=max(obj.OldParam.Ron_Diode,1e-3);
                if obj.OldParam.Rs_Diode==inf||obj.OldParam.Cs_Diode==0
                    obj.NewDerivedParam.diode_Goff=1e-6;
                elseif obj.OldParam.Cs_Diode==inf
                    obj.NewDerivedParam.diode_Goff=max(1/obj.OldParam.Rs_Diode,1e-6);
                else
                    obj.NewDerivedParam.diode_Goff=1e-6;
                end
            else

            end

        end

        function obj=objDropdownMapping(obj)

            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.ModelType,'Switching devices')
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

            elseif strcmp(obj.OldDropdown.ModelType,'Switching function')||strcmp(obj.OldDropdown.ModelType,'Average model (Uref-controlled)')
                if ischar(obj.OldParam.C)
                    obj.OldParam.C=evalin('base',obj.OldParam.C);
                end
                if length(obj.OldParam.C)~=1
                    logObj.addMessage(obj,'CustomMessage','The vector of Capacitor value is not supported. The first element of the capacitance vector is imported.');
                end

                if ischar(obj.OldParam.Vc_Initial)
                    obj.OldParam.Vc_Initial=evalin('base',obj.OldParam.Vc_Initial);
                end
                if length(obj.OldParam.Vc_Initial)~=1
                    logObj.addMessage(obj,'CustomMessage','The vector of Capacitor initial voltage is not supported. The first element of the initial voltage vector is imported.');
                end

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
                logObj.addMessage(obj,'ParameterNotSupported','Sample time (s)');

            else
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Model type','Aggregate model')
            end

        end
    end

end
