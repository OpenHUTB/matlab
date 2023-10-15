classdef TabCompletion < handle

    methods ( Static )
        function idictFileNames = findInterfaceDictFiles( namedargs )
            arguments
                namedargs.Folder = pwd
            end
            idictFileNames = {  };
            slddFiles = dir( fullfile( namedargs.Folder, filesep, '*.sldd' ) );
            for i = 1:length( slddFiles )
                slddFile = fullfile( slddFiles( i ).folder, slddFiles( i ).name );
                if sl.interface.dict.api.isInterfaceDictionary( slddFile )
                    idictFileNames{ end  + 1 } = slddFiles( i ).name;%#ok<AGROW>
                end
            end
        end

        function propNames = getPlatformProperyNames( platformMappingObj, stereotypeableObj )
            propNames = getPlatformProperties( platformMappingObj, stereotypeableObj );
        end
    end
end

