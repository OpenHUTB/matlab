classdef(Abstract)Format<ee.internal.importparams.MappingBlockXml




    methods(Static)
        function theClassName=getMappingClassFromXml(fileName)



            if~endsWith(fileName,'.xml')
                pm_error('physmod:ee:importparams:MappingBlockXml:InvalidFileFormat',fileName)
            end
            if exist(fileName,'file')~=2
                pm_error('physmod:ee:library:NotFound',fileName);
            end

            sourceStruct=readstruct(fileName);
            try
                theClassName=sourceStruct.Package.classAttribute;
            catch
                pm_error('physmod:ee:importparams:MappingBlockXml:MappingNotFound','UNKNOWN')
            end
        end
    end

end

