classdef Field_OrientedControlInd_class<ConvClass&handle



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
        'sourceFrequency',[],...
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
        'in_flux',[],...
        'nf',[],...
        'kp_fc',[],...
        'ki_fc',[],...
        'freqc_fc',[],...
        'fluxmin',[],...
        'fluxmax',[],...
        'h',[],...
        'kp_Id',[],...
        'ki_Id',[],...
        'kp_Iq',[],...
        'ki_Iq',[],...
        'fc_bus',[],...
        'car_freq',[],...
        'freq_max',[],...
        'Tvect',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
        'ReferenceFrame',[],...
        'IterativeDiscreteModel',[],...
        'deviceType',[],...
        'regulationType',[],...
        'modulationType',[],...
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
        OldPath='electricdrivelib/AC drives/Field-Oriented Control Induction Motor Drive'
        NewPath='elec_conv_Field_OrientedControlInd/Field_OrientedControlInd'
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
