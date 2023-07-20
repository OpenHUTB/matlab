classdef SeriesRLCBranch_class<ConvClass&handle


    properties

        OldParam=struct(...
        'Resistance',[],...
        'Inductance',[],...
        'Capacitance',[],...
        'InitialCurrent',[],...
        'InitialVoltage',[]...
        )


        OldDropdown=struct(...
        'BranchType',[],...
        'Measurements',[],...
        'SetiL0',[],...
        'Setx0',[]...
        )


        NewDirectParam=struct(...
        'R',[],...
        'l',[],...
        'c',[],...
        'vc_specify',[],...
        'vc_priority',[],...
        'vc',[],...
        'i_L_specify',[],...
        'i_L_priority',[],...
        'i_L',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'BranchType','R'},'R';...
        {'BranchType','L'},'L';...
        {'BranchType','C'},'C';...
        {'BranchType','RL'},'RL';...
        {'BranchType','RC'},'RC';...
        {'BranchType','LC'},'LC';...
        {'BranchType','RLC'},'RLC';...
        {'BranchType','Open circuit'},'OpenCircuit';...
        };

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Series RLC Branch'
        NewPath='elec_conv_SeriesRLCBranch/SeriesRLCBranch'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.R=obj.OldParam.Resistance;
            obj.NewDirectParam.l=obj.OldParam.Inductance;
            obj.NewDirectParam.c=obj.OldParam.Capacitance;

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

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            switch obj.OldDropdown.BranchType
            case{'L','RL'}
                if strcmp(obj.OldDropdown.SetiL0,'off')
                    logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
            case{'C','RC'}
                if strcmp(obj.OldDropdown.Setx0,'off')
                    logObj.addMessage(obj,'CustomMessage','The capacitor voltage might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
            case{'LC','RLC'}
                if strcmp(obj.OldDropdown.SetiL0,'off')
                    logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
                if strcmp(obj.OldDropdown.Setx0,'off')
                    logObj.addMessage(obj,'CustomMessage','The capacitor voltage might start from an undesired value.');
                    logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');
                end
            otherwise

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

