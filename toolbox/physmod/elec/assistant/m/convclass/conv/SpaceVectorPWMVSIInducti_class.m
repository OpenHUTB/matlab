classdef SpaceVectorPWMVSIInducti_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Pn',[],...
        'Vn',[],...
        'fn',[],...
        'Rs',[],...
        'Lls',[],...
        'Lms',[],...
        'Rr',[],...
        'Llr',[],...
        'ia',[],...
        'pha',[],...
        'ib',[],...
        'phb',[],...
        'ic',[],...
        'phc',[],...
        'J',[],...
        'Friction',[],...
        'p',[],...
        'slip',[],...
        'thdeg',[],...
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
        'ctrl_sat_min',[],...
        'ctrl_sat_max',[],...
        'ctrl_f_min',[],...
        'ctrl_f_max',[],...
        'ctrl_v_min',[],...
        'ctrl_v_max',[],...
        'vh_ratio',[],...
        'zc_time',[],...
        'car_freq',[],...
        'fc_bus',[],...
        'Tvect',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
        'ReferenceFrame',[],...
        'IterativeDiscreteModel',[],...
        'deviceType',[],...
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
        OldPath='electricdrivelib/AC drives/Space Vector PWM VSI Induction Motor Drive'
        NewPath='elec_conv_SpaceVectorPWMVSIInducti/SpaceVectorPWMVSIInducti'
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
