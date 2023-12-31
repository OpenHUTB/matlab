classdef Four_QuadrantChopperDCDr_class<ConvClass&handle



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
        'smoothingInductance',[],...
        'Vfield',[],...
        'Ron',[],...
        'Vf',[],...
        'Tf',[],...
        'Tt',[],...
        'Vfd',[],...
        'Rsnb',[],...
        'Csnb',[],...
        'wb',[],...
        'InitialSpeed',[],...
        'fc_sc',[],...
        'Tsc',[],...
        'kp_sc',[],...
        'ki_sc',[],...
        'Acc',[],...
        'Dec',[],...
        'fc_ic',[],...
        'refLim',[],...
        'switchfreq',[],...
        'Tic',[],...
        'Pb',[],...
        'Vb',[],...
        'kp_ic',[],...
        'ki_ic',[],...
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
        OldPath='electricdrivelib/DC drives/Four-Quadrant Chopper DC Drive'
        NewPath='elec_conv_Four_QuadrantChopperDCDr/Four_QuadrantChopperDCDr'
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
