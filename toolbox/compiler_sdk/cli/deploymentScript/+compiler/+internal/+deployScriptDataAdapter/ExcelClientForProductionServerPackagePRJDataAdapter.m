classdef ExcelClientForProductionServerPackagePRJDataAdapter < compiler.internal.deployScriptDataAdapter.DataAdapter

    methods
        function obj = ExcelClientForProductionServerPackagePRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.DataAdapter( prjData );
        end

        function optValue = getOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
                case compiler.internal.option.DeploymentOption.InstallerName
                    optValue = strcat( obj.dataWrapper.getData(  ).param_appname, "ClientInstl" );
                case compiler.internal.option.DeploymentOption.InstallerIcon
                    if isstruct( obj.dataWrapper.getData(  ).param_icons )
                        optValue = obj.dataWrapper.getData(  ).param_icons.file( 1 );
                    else
                        optValue = obj.DEFAULT;
                    end
                case compiler.internal.option.DeploymentOption.OutputDirPackage
                    optValue = fullfile( obj.dataWrapper.getData(  ).param_output );
                case compiler.internal.option.DeploymentOption.MaxResponseSize
                    optValue = obj.dataWrapper.getData(  ).param_max_size;
                case compiler.internal.option.DeploymentOption.ServerTimeOut
                    optValue = obj.dataWrapper.getData(  ).param_time_out;
                case compiler.internal.option.DeploymentOption.ServerURL
                    optValue = obj.dataWrapper.getData(  ).param_mads_server_configuration;
                case compiler.internal.option.DeploymentOption.SSLCertificate
                    optValue = obj.dataWrapper.getData(  ).param_certificate_file;
                case compiler.internal.option.DeploymentOption.Version
                    optValue = obj.dataWrapper.getData(  ).param_version;
                otherwise
                    error( message( "Compiler:deploymentscript:invalidAdapterOption", string( option ) ) );
            end
        end
    end
end



