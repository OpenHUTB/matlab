classdef Three_PhaseDynamicLoad_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NominalVoltage',[],...
        'ActiveReactivePowers',[],...
        'PositiveSequence',[],...
        'NpNq',[],...
        'TimeConstants',[],...
        'MinimumVoltage',[],...
        'Tfilter',[],...
        'LoadFlowParameters',[]...
        )


        OldDropdown=struct(...
        'ExternalControl',[]...
        )


        NewDirectParam=struct(...
        'P',[],...
        'FRated',[],...
        'VRatedMea',[],...
        'Vang0',[]...
        )


        NewDerivedParam=struct(...
        'Qpos',[],...
        'Qneg',[],...
        'Vline_rms_min',[],...
        'VRated',[],...
        'Vmag0',[],...
        'consumed_current_rms',[]...
        )


        NewDropdown=struct(...
        'component_structure_PQ',[]...
        )


        BlockOption={...
        {'ExternalControl','on'},'ext';...
        {'ExternalControl','off';'NpNq','[2 2]'},'ConImpedance';...
        {'ExternalControl','off';'NpNq','[1 1]'},'ConCurrent';...
        {},'Others';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Dynamic Load'
        NewPath='elec_conv_Three_PhaseDynamicLoad/Three_PhaseDynamicLoad'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.P=ConvClass.mapDirect(obj.OldParam.ActiveReactivePowers,1);
            obj.NewDirectParam.FRated=ConvClass.mapDirect(obj.OldParam.NominalVoltage,2);
            obj.NewDirectParam.VRatedMea=ConvClass.mapDirect(obj.OldParam.NominalVoltage,1);
            obj.NewDirectParam.Vang0=ConvClass.mapDirect(obj.OldParam.PositiveSequence,2);
        end


        function obj=Three_PhaseDynamicLoad_class(NominalVoltage,ActiveReactivePowers,PositiveSequence,...
            NpNq,MinimumVoltage,ExternalControl)
            if nargin>0
                obj.OldParam.NominalVoltage=NominalVoltage;
                obj.OldParam.ActiveReactivePowers=ActiveReactivePowers;
                obj.OldParam.PositiveSequence=PositiveSequence;
                obj.OldParam.NpNq=NpNq;
                obj.OldParam.MinimumVoltage=MinimumVoltage;
                obj.OldDropdown.ExternalControl=ExternalControl;
            end
        end

        function obj=objParamMappingDerived(obj)

            if obj.OldParam.ActiveReactivePowers(2)>=0
                obj.NewDerivedParam.Qpos=obj.OldParam.ActiveReactivePowers(2);
            else
                obj.NewDerivedParam.Qneg=obj.OldParam.ActiveReactivePowers(2);
            end

            if strcmp(obj.OldDropdown.ExternalControl,'on')
                obj.NewDerivedParam.Vline_rms_min=obj.OldParam.NominalVoltage(1)*0.1;
            else
                obj.NewDerivedParam.Vline_rms_min=obj.OldParam.NominalVoltage(1)*obj.OldParam.MinimumVoltage;
            end

            obj.NewDerivedParam.VRated=obj.OldParam.NominalVoltage(1)*obj.OldParam.PositiveSequence(1);
            obj.NewDerivedParam.Vmag0=obj.OldParam.NominalVoltage(1)*obj.OldParam.PositiveSequence(1);

            obj.NewDerivedParam.consumed_current_rms=obj.OldParam.ActiveReactivePowers(1)/...
            (sqrt(3)*obj.OldParam.NominalVoltage(1)*obj.OldParam.PositiveSequence(1));

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.ExternalControl,'off')

                if~isnumeric(obj.OldParam.NpNq)
                    logObj.addMessage(obj,'ParameterNumerical','[np, nq]');
                end

                if ischar(obj.OldParam.ActiveReactivePowers)
                    ActiveReactivePowersValue=evalin('base',obj.OldParam.ActiveReactivePowers);
                else
                    ActiveReactivePowersValue=obj.OldParam.ActiveReactivePowers;
                end

                if ActiveReactivePowersValue(1)>0&&...
                    ActiveReactivePowersValue(2)==0
                    obj.NewDropdown.component_structure_PQ='1';
                elseif ActiveReactivePowersValue(1)==0&&...
                    ActiveReactivePowersValue(2)>0
                    obj.NewDropdown.component_structure_PQ='2';
                elseif ActiveReactivePowersValue(1)==0&&...
                    ActiveReactivePowersValue(2)<0
                    obj.NewDropdown.component_structure_PQ='3';
                elseif ActiveReactivePowersValue(1)>0&&...
                    ActiveReactivePowersValue(2)>0
                    obj.NewDropdown.component_structure_PQ='4';
                elseif ActiveReactivePowersValue(1)>0&&...
                    ActiveReactivePowersValue(2)<0
                    obj.NewDropdown.component_structure_PQ='5';
                elseif ActiveReactivePowersValue(1)<0
                    obj.NewDropdown.component_structure_PQ='1';
                    logObj.addMessage(obj,'CustomMessage','Negative active power is not supported.');
                else
                    obj.NewDropdown.component_structure_PQ='1';
                    logObj.addMessage(obj,'CustomMessage','Zero active and reactive power are not supported.');
                end


                if ischar(obj.OldParam.NpNq)
                    NpNqValue=evalin('base',obj.OldParam.NpNq);
                else
                    NpNqValue=obj.OldParam.NpNq;
                end

                if~((NpNqValue(1)~=1&&NpNqValue(2)~=1)||(NpNqValue(1)~=2&&NpNqValue(2)~=2))
                    logObj.addMessage(obj,'CustomMessage','Only [np, nq] = [1 1] or [np, nq] = [2 2] is supported.');
                end

                if NpNqValue(1)==1&&NpNqValue(2)==1
                    if ActiveReactivePowersValue(2)~=0
                        logObj.addMessage(obj,'CustomMessage','For the case [np, nq] = [1 1] non-zero reactive power is not supported.');
                    end
                end

                if ischar(obj.OldParam.TimeConstants)
                    TimeConstantsValue=evalin('base',obj.OldParam.TimeConstants);
                else
                    TimeConstantsValue=obj.OldParam.TimeConstants;
                end

                if sum(TimeConstantsValue~=0)~=0
                    logObj.addMessage(obj,'CustomMessage','Non-zero time constants are not supported.');
                end
            end

        end
    end

end
