classdef ExcelClientForProductionServerBuildPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter

    properties
        DataMarshallingOptions
        InstallerAdapter
    end

    methods
        function obj = ExcelClientForProductionServerBuildPRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
            options.ReplaceExcelBlankWithNaN = obj.DEFAULT;
            options.ConvertExcelDateToString = obj.DEFAULT;
            options.ReplaceNaNToZeroInExcel = obj.DEFAULT;
            options.ConvertNumericOutToDateInExcel = obj.DEFAULT;
            obj.DataMarshallingOptions = compiler.internal.build.LegacyProjectBuildUtilities.configureDataMarshallingRules( options, obj.dataWrapper.getData(  ) );
            obj.InstallerAdapter = compiler.internal.deployScriptDataAdapter.ExcelClientForProductionServerPackagePRJDataAdapter( prjData );
        end

        function optValue = getOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
                case compiler.internal.option.DeploymentOption.AddInName
                    optValue = obj.dataWrapper.getData(  ).param_appname;
                case compiler.internal.option.DeploymentOption.AddInVersion
                    optValue = obj.dataWrapper.getData(  ).param_version;
                case compiler.internal.option.DeploymentOption.ArchiveName
                    optValue = obj.dataWrapper.getData(  ).param_appname;
                case compiler.internal.option.DeploymentOption.ClassName
                    theClasses = [ obj.dataWrapper.getData(  ).fileset_classes.entity_package.entity_class.nameAttribute ];
                    optValue = theClasses( 1 );
                case compiler.internal.option.DeploymentOption.ConvertNumericOutToDateInExcel
                    optValue = obj.DataMarshallingOptions.ConvertNumericOutToDateInExcel;
                case compiler.internal.option.DeploymentOption.ConvertExcelDateToString
                    optValue = obj.DataMarshallingOptions.ConvertExcelDateToString;
                case compiler.internal.option.DeploymentOption.DebugBuild
                    optValue = contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, [ "-g", "-G" ] );
                case compiler.internal.option.DeploymentOption.FunctionFiles
                    optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
                case compiler.internal.option.DeploymentOption.FunctionSignatures
                    optValue = obj.dataWrapper.getData(  ).param_discovery_file;
                case compiler.internal.option.DeploymentOption.GenerateVisualBasicFile
                    optValue = obj.DEFAULT;
                case compiler.internal.option.DeploymentOption.ReplaceExcelBlankWithNaN
                    optValue = obj.DataMarshallingOptions.ReplaceExcelBlankWithNaN;
                case compiler.internal.option.DeploymentOption.ReplaceNaNToZeroInExcel
                    optValue = obj.DataMarshallingOptions.ReplaceNaNToZeroInExcel;
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



