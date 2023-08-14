classdef Single_PhaseInductionMot_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Pn',[],...
        'Vn',[],...
        'fn',[],...
        'Rs',[],...
        'Lls',[],...
        'Lms',[],...
        'Ra',[],...
        'Lla',[],...
        'k',[],...
        'Rr',[],...
        'Llr',[],...
        'J',[],...
        'Friction',[],...
        'p',[],...
        'InitialSpeed',[],...
        'Rsnubber1',[],...
        'Csnubber1',[],...
        'Ron1',[],...
        'Vf1',[],...
        'cap_bus',[],...
        'Rbrake',[],...
        'fbrake',[],...
        'activationVoltage',[],...
        'shutdownVoltage',[],...
        'Ron2',[],...
        'Vf2',[],...
        'Vfd',[],...
        'Rsnubber2',[],...
        'Csnubber2',[],...
        'Tsc',[],...
        'fc_sc',[],...
        'Acc',[],...
        'Dec',[],...
        'kp_sc',[],...
        'ki_sc',[],...
        'Tmin',[],...
        'Tmax',[],...
        'in_flux',[],...
        'nf',[],...
        'h',[],...
        'T_bw',[],...
        'F_bw',[],...
        'freq_max',[],...
        'Tvect',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
        'deviceType',[],...
        'regulationType',[],...
        'controllerType',[],...
        'outputBusMode',[],...
        'MechanicalLoad',[],...
        'driveType',[],...
        'busLabels',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='electricdrivelib/AC drives/Single-Phase Induction Motor Drive'
        NewPath='elec_conv_Single_PhaseInductionMot/Single_PhaseInductionMot'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
