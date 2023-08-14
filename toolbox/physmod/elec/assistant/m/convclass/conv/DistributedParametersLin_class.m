classdef DistributedParametersLin_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Phases',[],...
        'Frequency',[],...
        'Resistance',[],...
        'Inductance',[],...
        'Capacitance',[],...
        'Length',[],...
        'x1',[],...
        'x2',[],...
        'x3',[],...
        'x4',[],...
        'x5',[],...
        'V1',[],...
        'V2',[],...
        'I1',[],...
        'I2',[],...
        'nHarmo',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'Ll',[],...
        'R',[],...
        'C',[],...
        'LEN',[],...
        'freq',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'Phases','1'},'1phase';...
        {},'blank';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Distributed Parameters Line'
        NewPath='elec_conv_DistributedParametersLin/DistributedParametersLin'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.Ll=obj.OldParam.Inductance;
            obj.NewDirectParam.R=obj.OldParam.Resistance;
            obj.NewDirectParam.C=obj.OldParam.Capacitance;
            obj.NewDirectParam.LEN=obj.OldParam.Length;
            obj.NewDirectParam.freq=obj.OldParam.Frequency;
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            if obj.OldParam.Phases>1
                logObj.addMessage(obj,'OptionNotSupported','Number of phase greater than 1','');
            end
        end
    end

end
