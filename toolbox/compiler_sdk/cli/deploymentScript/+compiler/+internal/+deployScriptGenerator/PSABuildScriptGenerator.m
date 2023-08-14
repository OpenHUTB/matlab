classdef PSABuildScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        BUILD_COMMAND="compiler.build.productionServerArchive";
        BUILD_OPTIONS_COMMAND="compiler.build.ProductionServerArchiveOptions";
        BUILD_OPTS_VAR="buildOpts";
    end

    methods
        function obj=PSABuildScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.allBuildTargetOptions,...
            compiler.internal.option.DeploymentOption.ArchiveName,...
            compiler.internal.option.DeploymentOption.FunctionSignatures];
        end

        function script=generateScript(obj)
            buildCreationArguments=obj.adapter.getOptionValue(compiler.internal.option.DeploymentOption.FunctionFiles);
            buildOptionsCreationLine=strcat(obj.BUILD_OPTS_VAR," = ",obj.BUILD_OPTIONS_COMMAND,"(",obj.wrapInQuotes(buildCreationArguments),");");
            buildOptionsPropertySetLines=arrayfun(@(buildOpt)obj.serializeOption(buildOpt,obj.BUILD_OPTS_VAR),obj.generatorOptions);
            buildOptionsPropertySetLines=buildOptionsPropertySetLines(buildOptionsPropertySetLines~="");
            buildLine=strcat(obj.BUILD_RESULTS_VAR," = ",obj.BUILD_COMMAND,"(",obj.BUILD_OPTS_VAR,");");

            script=strjoin(["% "+string(message("Compiler:deploymentscript:buildIntro")),...
            buildOptionsCreationLine,...
            buildOptionsPropertySetLines,...
            buildLine],newline);
        end
    end

end

