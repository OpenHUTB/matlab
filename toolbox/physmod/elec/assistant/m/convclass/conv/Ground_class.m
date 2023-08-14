classdef Ground_class<ConvClass&handle


    properties

        OldParam=struct(...
        )


        OldDropdown=struct(...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end


    properties(Constant)
        OldPath='powerlib/Elements/Ground'




        NewPath='fl_lib/Electrical/Electrical Elements/Electrical Reference';
    end

    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
        end
    end

end

