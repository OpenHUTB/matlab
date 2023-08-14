classdef ExcelClientForProductionServerPackageScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        EXCEL_BUILD_RESULTS_VAR="excelClientBuildResult";
        PACKAGE_COMMAND="compiler.package.excelClientForProductionServer";
        PACKAGE_OPTIONS_COMMAND="compiler.package.ExcelClientForProductionServerOptions";
        PACKAGE_OPTS_VAR="packageOpts";
    end

    methods
        function obj=ExcelClientForProductionServerPackageScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.InstallerName,...
            compiler.internal.option.DeploymentOption.InstallerIcon,...
            compiler.internal.option.DeploymentOption.OutputDirPackage,...
            compiler.internal.option.DeploymentOption.MaxResponseSize,...
            compiler.internal.option.DeploymentOption.ServerTimeOut,...
            compiler.internal.option.DeploymentOption.ServerURL,...
            compiler.internal.option.DeploymentOption.SSLCertificate,...
            compiler.internal.option.DeploymentOption.Version];
        end

        function script=generateScript(obj)
            packageOptionsCreationLine=strcat(obj.PACKAGE_OPTS_VAR," = ",obj.PACKAGE_OPTIONS_COMMAND,"(",obj.EXCEL_BUILD_RESULTS_VAR,");");
            packageOptionsPropertySetLines=arrayfun(@(packageOpt)obj.serializeOption(packageOpt,obj.PACKAGE_OPTS_VAR),obj.generatorOptions);
            packageOptionsPropertySetLines=packageOptionsPropertySetLines(packageOptionsPropertySetLines~="");
            packageLine=strcat(obj.PACKAGE_COMMAND,"(",obj.BUILD_RESULTS_VAR,", ""Options"", ",obj.PACKAGE_OPTS_VAR,");");

            script=strjoin(["% "+string(message("Compiler:deploymentscript:packageIntro")),...
            packageOptionsCreationLine,...
            packageOptionsPropertySetLines,...
            packageLine],newline);
        end
    end

    methods(Access=protected)
        function defaultValue=getDefaultValue(obj,option)
            mustBeMember(option,obj.generatorOptions);
            if strcmp(option.optionName(),"Version")
                defaultValue="1.0";
            else
                defaultValue="";
            end
        end
    end
end

