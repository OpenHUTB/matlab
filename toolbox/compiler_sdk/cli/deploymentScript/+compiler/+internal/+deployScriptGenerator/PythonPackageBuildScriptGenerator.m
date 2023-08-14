classdef PythonPackageBuildScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        BUILD_COMMAND="compiler.build.pythonPackage";
        BUILD_OPTIONS_COMMAND="compiler.build.PythonPackageOptions";
        BUILD_OPTS_VAR="buildOpts";
    end

    methods
        function obj=PythonPackageBuildScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.allBuildTargetOptions,...
            compiler.internal.option.DeploymentOption.PackageName,...
            compiler.internal.option.DeploymentOption.SampleGenerationFiles];
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

