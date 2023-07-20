classdef Overmodulation_class<ConvClass&handle



    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
        'OverModType',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'OverModType','Third harmonic'},'Thirdharmonic';...
        {'OverModType','Flat top'},'Flattop';...
        {'OverModType','Min-Max'},'Minmax';...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib_meascontrol/Pulse & Signal Generators/Overmodulation'
        NewPath='elec_conv_sl_Overmodulation/Overmodulation'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=Overmodulation_class()
            if nargin>0
            end
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end
