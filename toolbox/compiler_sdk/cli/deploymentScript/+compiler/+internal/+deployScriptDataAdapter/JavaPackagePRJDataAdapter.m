classdef JavaPackagePRJDataAdapter < compiler.internal.deployScriptDataAdapter.ClassBasedPRJDataAdapter

    methods
        function obj = JavaPackagePRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.ClassBasedPRJDataAdapter( prjData );
        end

        function optValue = getOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
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
                    optValue = obj.getSharedClassBasedLibraryOptionValue( option );
            end
        end
    end
end


