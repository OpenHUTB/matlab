classdef Utils < handle




    methods ( Static )
        function ddFilePath = getResolvedFilePath( ddFileName )
            if matlab.io.internal.common.isAbsolutePath( ddFileName )
                ddFilePath = ddFileName;
            else





                ddFilePath = which( ddFileName );
                if isempty( ddFilePath )
                    openDDsWithFilePath = Simulink.data.dictionary.getOpenDictionaryPaths( ddFileName );
                    if ~isempty( openDDsWithFilePath )
                        ddFilePath = openDDsWithFilePath{ 1 };
                    else
                        ddFilePath = fullfile( pwd, ddFileName );
                    end
                end
            end
        end

        function entries = getDataTypeDisplayNames( dictAPI, namedargs )
            arguments
                dictAPI Simulink.interface.Dictionary
                namedargs.IncludeBusTypes = true;
            end

            import Simulink.interface.dictionary.internal.Utils

            separator = DAStudio.message( 'SystemArchitecture:PropertyInspector:Separator' );
            defaultEntries = systemcomposer.internal.getBuiltInDataTypeList(  );

            userDefinedTypes = sort( Utils.fetchDataTypeDisplayNames( dictAPI ) );
            if ~namedargs.IncludeBusTypes
                userDefinedTypes = userDefinedTypes( ~startsWith( userDefinedTypes, 'Bus: ' ) );
            end

            entries = [ defaultEntries, separator, userDefinedTypes ];
        end
    end

    methods ( Static, Access = private )
        function displayNames = fetchDataTypeDisplayNames( dictAPI )
            arguments
                dictAPI Simulink.interface.Dictionary
            end

            dtObjs = dictAPI.DataTypes;
            displayNames = cell( 1, length( dtObjs ) );
            for idx = 1:length( dtObjs )
                dtObj = dtObjs( idx );
                displayNames{ idx } = dtObj.getTypeString(  );
            end
        end
    end
end
