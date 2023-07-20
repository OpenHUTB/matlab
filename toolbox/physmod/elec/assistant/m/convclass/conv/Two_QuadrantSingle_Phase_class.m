classdef Two_QuadrantSingle_Phase_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Laf',[],...
        'Ra',[],...
        'La',[],...
        'Rf',[],...
        'Lf',[],...
        'J',[],...
        'Bm',[],...
        'Tfriction',[],...
        'w0',[],...
        'Ron_rec',[],...
        'Vf_rec',[],...
        'Rsnb_rec',[],...
        'Csnb_rec',[],...
        'smoothingInductance',[],...
        'Vfield',[],...
        'LineVoltage',[],...
        'LineFrequency',[],...
        'sourceInductance',[],...
        'PhaseAngle',[],...
        'Tc',[],...
        'wb',[],...
        'InitialSpeed',[],...
        'fc_sc',[],...
        'kp_sc',[],...
        'ki_sc',[],...
        'Acc',[],...
        'Dec',[],...
        'fc_ic',[],...
        'refLim',[],...
        'Pb',[],...
        'Vb',[],...
        'kp_ic',[],...
        'ki_ic',[],...
        'alphamin',[],...
        'alphamax',[],...
        'freqSynchro',[],...
        'pulseWitdth',[],...
        'baseSampleTime',[]...
        )


        OldDropdown=struct(...
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
        OldPath='electricdrivelib/DC drives/Two-Quadrant Single-Phase Rectifier DC Drive'
        NewPath='elec_conv_Two_QuadrantSingle_Phase/Two_QuadrantSingle_Phase'
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
