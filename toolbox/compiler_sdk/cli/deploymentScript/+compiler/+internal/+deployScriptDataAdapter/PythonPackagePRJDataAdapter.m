classdef PythonPackagePRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter

    properties
        InstallerAdapter
    end

    methods
        function obj = PythonPackagePRJDataAdapter( prjData )
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
                case compiler.internal.option.DeploymentOption.FunctionFiles
                    optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
                case compiler.internal.option.DeploymentOption.PackageName
                    optValue = compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName( obj.dataWrapper.getData(  ) );
                case compiler.internal.option.DeploymentOption.SampleGenerationFiles
                    sample_files = obj.dataWrapper.getData(  ).fileset_examples;
                    if ( strcmp( sample_files, "" ) )
                        optValue = obj.DEFAULT;
                    else
                        optValue = sample_files.file;
                    end
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



