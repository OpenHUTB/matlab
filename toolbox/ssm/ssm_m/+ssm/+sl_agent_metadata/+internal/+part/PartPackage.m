classdef PartPackage<ssm.sl_agent_metadata.internal.part.Part




    properties
        PackageType(1,:)char=''
    end
    methods
        function obj=PartPackage()
            obj@ssm.sl_agent_metadata.internal.part.Part('package')
        end

        function populateFileList(~)
        end

        function populateInformation(obj)


            obj.InformationStruct.Version=string(version);
            obj.InformationStruct.Timestamp=string(datestr(now,'yyyy_mm_dd-hh_MM_SS'));
            obj.InformationStruct.PackageType=string(obj.PackageType);
        end

    end
end


