classdef DotNETAssemblyPRJDataAdapter < compiler.internal.deployScriptDataAdapter.ClassBasedPRJDataAdapter

    methods
        function obj = DotNETAssemblyPRJDataAdapter( prjData )
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

                case compiler.internal.option.DeploymentOption.AssemblyName
                    optValue = compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName( obj.dataWrapper.getData(  ) );
                case compiler.internal.option.DeploymentOption.AssemblyVersion
                    optValue = obj.dataWrapper.getData(  ).param_version;
                case compiler.internal.option.DeploymentOption.EnableRemoting
                    optValue = strcmpi( obj.dataWrapper.getData(  ).param_net_enable_remoting, "true" );
                case compiler.internal.option.DeploymentOption.FrameworkVersion
                    optValue = obj.DEFAULT;
                    if isfield( obj.dataWrapper.getData(  ), 'param_assembly_net_version' )
                        if strcmp( obj.dataWrapper.getData(  ).param_assembly_net_version, "option.net.version.four" )
                            optValue = "4.0";
                        elseif strcmp( obj.dataWrapper.getData(  ).param_assembly_net_version, "option.net.version.five" )
                            optValue = "5.0";
                        end
                    end
                case compiler.internal.option.DeploymentOption.SampleGenerationFiles
                    sample_files = obj.dataWrapper.getData(  ).fileset_examples;
                    if ( strcmp( sample_files, "" ) )
                        optValue = obj.DEFAULT;
                    else
                        optValue = sample_files.file;
                    end
                case compiler.internal.option.DeploymentOption.StrongNameKeyFile
                    val = obj.dataWrapper.getData(  ).param_encryption_key_file;
                    if val.strlength > 0
                        optValue = val;
                    else
                        optValue = obj.DEFAULT;
                    end
                otherwise
                    optValue = obj.getSharedClassBasedLibraryOptionValue( option );
            end

        end
    end
end


