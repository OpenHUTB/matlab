classdef ExcelClientForProductionServerBuildScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        BUILD_COMMAND="compiler.build.excelClientForProductionServer";
        BUILD_OPTIONS_COMMAND="compiler.build.ExcelClientForProductionServerOptions";
        BUILD_OPTS_VAR="buildOpts";
        EXCEL_BUILD_RESULTS_VAR="excelClientBuildResult";
    end

    properties(Access=private)
PSAScriptGenerator
    end

    methods
        function obj=ExcelClientForProductionServerBuildScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);
            obj.PSAScriptGenerator=compiler.internal.deployScriptGenerator.PSABuildScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.AddInName,...
            compiler.internal.option.DeploymentOption.AddInVersion,...
            compiler.internal.option.DeploymentOption.ClassName,...
            compiler.internal.option.DeploymentOption.ConvertNumericOutToDateInExcel,...
            compiler.internal.option.DeploymentOption.ConvertExcelDateToString,...
            compiler.internal.option.DeploymentOption.DebugBuild,...
            compiler.internal.option.DeploymentOption.FunctionFiles,...
            compiler.internal.option.DeploymentOption.FunctionSignatures,...
            compiler.internal.option.DeploymentOption.GenerateVisualBasicFile,...
            compiler.internal.option.DeploymentOption.OutputDirBuild,...
            compiler.internal.option.DeploymentOption.ReplaceExcelBlankWithNaN,...
            compiler.internal.option.DeploymentOption.ReplaceNaNToZeroInExcel,...
            compiler.internal.option.DeploymentOption.Verbose];

        end

        function script=generateScript(obj)



            buildOptionsCreationLine=strcat(obj.BUILD_OPTS_VAR," = ",obj.BUILD_OPTIONS_COMMAND,"(",obj.BUILD_RESULTS_VAR,");");

            buildOptionsPropertySetLines=arrayfun(@(buildOpt)obj.serializeOption(buildOpt,obj.BUILD_OPTS_VAR),obj.generatorOptions);
            buildOptionsPropertySetLines=buildOptionsPropertySetLines(buildOptionsPropertySetLines~="");
            buildLine=strcat(obj.EXCEL_BUILD_RESULTS_VAR," = ",obj.BUILD_COMMAND,"(",obj.BUILD_OPTS_VAR,");");

            psaScript=obj.PSAScriptGenerator.generateScript;

            script=strjoin([psaScript,'',...
            "% "+string(message("Compiler:deploymentscript:buildIntro")),...
            buildOptionsCreationLine,...
            buildOptionsPropertySetLines,...
            buildLine],newline);
        end
    end
end
