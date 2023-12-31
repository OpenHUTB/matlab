classdef BrushlessDCMotorDrive_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Rs',[],...
        'Lls',[],...
        'Flat',[],...
        'FluxCst',[],...
        'VoltageCst',[],...
        'TorqueCst',[],...
        'ia',[],...
        'ib',[],...
        'J',[],...
        'Friction',[],...
        'p',[],...
        'wm',[],...
        'thetam',[],...
        'Rsnb_rec',[],...
        'Csnb_rec',[],...
        'Ron_rec',[],...
        'Vf_rec',[],...
        'cap_bus',[],...
        'Rbrake',[],...
        'fbrake',[],...
        'activationVoltage',[],...
        'shutdownVoltage',[],...
        'Ron_inv',[],...
        'Vf_inv',[],...
        'Vfd_inv',[],...
        'Tf',[],...
        'Tt',[],...
        'Tf_GTO',[],...
        'Tt_GTO',[],...
        'Rsnb_inv',[],...
        'Csnb_inv',[],...
        'Acc',[],...
        'Dec',[],...
        'kp_sc',[],...
        'ki_sc',[],...
        'fc_sc',[],...
        'Tsc',[],...
        'Tmin',[],...
        'Tmax',[],...
        'h',[],...
        'freq_max',[],...
        'Tvect',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
        'MachineConstant',[],...
        'deviceType',[],...
        'regulationType',[],...
        'outputBusMode',[],...
        'MechanicalLoad',[],...
        'modelDetailLevel',[],...
        'driveType',[],...
        'busLabels',[],...
        'AverageValue',[]...
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
        OldPath='electricdrivelib/AC drives/Brushless DC Motor Drive'
        NewPath='elec_conv_BrushlessDCMotorDrive/BrushlessDCMotorDrive'
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
