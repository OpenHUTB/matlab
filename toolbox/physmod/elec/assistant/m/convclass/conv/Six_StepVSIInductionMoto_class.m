classdef Six_StepVSIInductionMoto_class<ConvClass&handle



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
        'ind_bus',[],...
        'cap_bus',[],...
        'Rbrake',[],...
        'fbrake',[],...
        'Ron_inv',[],...
        'Vf_inv',[],...
        'Vfd_inv',[],...
        'Tf',[],...
        'Tt',[],...
        'Tf_GTO',[],...
        'Tt_GTO',[],...
        'Rsnb_inv',[],...
        'Csnb_inv',[],...
        'fc_busc',[],...
        'network_freq',[],...
        'bus_dev_neg',[],...
        'bus_dev_pos',[],...
        'kp_busc',[],...
        'ki_busc',[],...
        'busVolt_min',[],...
        'busVolt_max',[],...
        'Acc',[],...
        'Dec',[],...
        'outfreq_min',[],...
        'outfreq_max',[],...
        'vh_ratio',[],...
        'zc_time',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
        'ReferenceFrame',[],...
        'IterativeDiscreteModel',[],...
        'deviceType',[],...
        'outputBusMode',[],...
        'MechanicalLoad',[],...
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
        OldPath='electricdrivelib/AC drives/Six-Step VSI Induction Motor Drive'
        NewPath='elec_conv_Six_StepVSIInductionMoto/Six_StepVSIInductionMoto'
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
