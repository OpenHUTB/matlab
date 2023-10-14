classdef CSharedLibraryPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter

    properties
        InstallerAdapter
    end

    methods
        function obj = CSharedLibraryPRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
            obj.InstallerAdapter = compiler.internal.deployScriptDataAdapter.InstallerPRJDataAdapter( prjData );
        end

        function optValue = getOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
                case compiler.internal.option.DeploymentOption.DebugBuild
                    optValue = contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, [ "-g", "-G" ] );
                case compiler.internal.option.DeploymentOption.EmbedArchive
                    optValue = ~contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, "-C" );
                case compiler.internal.option.DeploymentOption.FunctionFiles
                    optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
                case compiler.internal.option.DeploymentOption.LibraryName
                    optValue = obj.dataWrapper.getData(  ).param_appname;
                otherwise
                    if any( compiler.internal.option.DeploymentOption.allBuildTargetOptions == option )
                        optValue = obj.getBasicBuildOptionValue( option );
                    else

                        optValue = obj.InstallerAdapter.getOptionValue( option );
                    end
            end
        end
    end
end



