classdef ParallelRLCLoad_class<ConvClass&handle




    properties

        OldParam=struct(...
        'NominalVoltage',[],...
        'NominalFrequency',[],...
        'ActivePower',[],...
        'InductivePower',[],...
        'CapacitivePower',[],...
        'InitialVoltage',[],...
        'InitialCurrent',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'LoadType',[],...
        'Setx0',[],...
        'SetiL0',[]...
        )


        NewDirectParam=struct(...
        'vc_specify',[],...
        'vc_priority',[],...
        'vc',[],...
        'i_L_specify',[],...
        'i_L_priority',[],...
        'i_L',[]...
        )


        NewDerivedParam=struct(...
        'R',[],...
        'l',[],...
        'c',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'InductivePower','0';'CapacitivePower','0'},'R';...
        {'ActivePower','0';'CapacitivePower','0'},'L';...
        {'ActivePower','0';'InductivePower','0'},'C';...
        {'CapacitivePower','0'},'RL';...
        {'InductivePower','0'},'RC';...
        {'ActivePower','0'},'LC';...
        {},'RLC';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Parallel RLC Load'
        NewPath='elec_conv_ParallelRLCLoad/ParallelRLCLoad'
    end

    methods
        function obj=objParamMappingDirect(obj)
            if strcmp(obj.OldDropdown.SetiL0,'off')
                obj.NewDirectParam.i_L_specify='on';
                obj.NewDirectParam.i_L_priority='none';
            else
                obj.NewDirectParam.i_L_specify='on';
                obj.NewDirectParam.i_L_priority='high';
                obj.NewDirectParam.i_L=obj.OldParam.InitialCurrent;
            end

            if strcmp(obj.OldDropdown.Setx0,'off')
                obj.NewDirectParam.vc_specify='on';
                obj.NewDirectParam.vc_priority='none';
            else
                obj.NewDirectParam.vc_specify='on';
                obj.NewDirectParam.vc_priority='high';
                obj.NewDirectParam.vc=obj.OldParam.InitialVoltage;
            end
        end


        function obj=ParallelRLCLoad_class(ActivePower,NominalFrequency,NominalVoltage,InductivePower,CapacitivePower)
            if nargin>0
                obj.OldParam.ActivePower=ActivePower;
                obj.OldParam.NominalFrequency=NominalFrequency;
                obj.OldParam.NominalVoltage=NominalVoltage;
                obj.OldParam.InductivePower=InductivePower;
                obj.OldParam.CapacitivePower=CapacitivePower;
            end
        end

        function obj=objParamMappingDerived(obj)

            P=obj.OldParam.ActivePower;
            FRated=obj.OldParam.NominalFrequency;
            VRated=obj.OldParam.NominalVoltage;
            Qpos=obj.OldParam.InductivePower;
            Qneg=obj.OldParam.CapacitivePower;
            w=2*pi*FRated;

            if P~=0
                obj.NewDerivedParam.R=VRated^2/P;
            end
            if Qpos~=0
                obj.NewDerivedParam.l=VRated^2/(w*Qpos);
            end
            if Qneg~=0
                obj.NewDerivedParam.c=Qneg/(w*VRated^2);
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if~isnumeric(obj.OldParam.ActivePower)
                logObj.addMessage(obj,'ParameterNumerical','Active power P (W)');
            end
            if~isnumeric(obj.OldParam.InductivePower)
                logObj.addMessage(obj,'ParameterNumerical','Inductive reactive Power QL');
            end
            if~isnumeric(obj.OldParam.CapacitivePower)
                logObj.addMessage(obj,'ParameterNumerical','Capacitive reactive power Qc');
            end

            if ischar(obj.OldParam.InductivePower)
                obj.OldParam.InductivePower=evalin('base',obj.OldParam.InductivePower);
            end
            if ischar(obj.OldParam.CapacitivePower)
                obj.OldParam.CapacitivePower=evalin('base',obj.OldParam.CapacitivePower);
            end

            if obj.OldParam.InductivePower~=0
                if strcmp(obj.OldDropdown.SetiL0,'off')
                    logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
            end

            if obj.OldParam.CapacitivePower~=0
                if strcmp(obj.OldDropdown.Setx0,'off')
                    logObj.addMessage(obj,'CustomMessage','The capacitor voltage might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
            end


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Branch voltage'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage');
            case 'Branch current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch current');
            case 'Branch voltage and current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage and current');
            end

        end
    end

end
