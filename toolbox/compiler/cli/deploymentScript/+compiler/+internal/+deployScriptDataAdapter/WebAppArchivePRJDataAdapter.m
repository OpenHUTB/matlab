classdef WebAppArchivePRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter

    methods
        function obj = WebAppArchivePRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
        end

        function optValue = getOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
                case compiler.internal.option.DeploymentOption.AppFile
                    optValue = obj.dataWrapper.getData(  ).fileset_web_main.file;
                case compiler.internal.option.DeploymentOption.ArchiveName
                    optValue = obj.dataWrapper.getData(  ).param_appname;
                otherwise
                    optValue = obj.getBasicBuildOptionValue( option );
            end
        end
    end
end



