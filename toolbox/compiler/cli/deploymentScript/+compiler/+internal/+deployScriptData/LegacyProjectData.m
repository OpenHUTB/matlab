classdef LegacyProjectData < compiler.internal.deployScriptData.Data

    methods
        function obj = LegacyProjectData( prjPath )
            arguments
                prjPath{ mustBeTextScalar, mustBeFile }
            end
            prjData = compiler.internal.readPRJStruct( prjPath );
            obj = obj@compiler.internal.deployScriptData.Data( prjData );
        end
    end
end



