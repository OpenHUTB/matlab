classdef DotNETAssemblyBuildScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        BUILD_COMMAND="compiler.build.dotNETAssembly";
        BUILD_OPTIONS_COMMAND="compiler.build.DotNETAssemblyOptions";
        BUILD_OPTS_VAR="buildOpts";
    end

    methods
        function obj=DotNETAssemblyBuildScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.allBuildTargetOptions,...
            compiler.internal.option.DeploymentOption.AssemblyName,...
            compiler.internal.option.DeploymentOption.AssemblyVersion,...
            compiler.internal.option.DeploymentOption.DebugBuild,...
            compiler.internal.option.DeploymentOption.SampleGenerationFiles,...
            compiler.internal.option.DeploymentOption.EnableRemoting,...
            compiler.internal.option.DeploymentOption.FrameworkVersion,...
            compiler.internal.option.DeploymentOption.StrongNameKeyFile,...
            ];
        end

        function script=generateScript(obj)
            classmapCreationLine=obj.adapter.getOptionValue(compiler.internal.option.DeploymentOption.ClassMap);

            buildOptionsCreationLine=strcat(obj.BUILD_OPTS_VAR," = ",obj.BUILD_OPTIONS_COMMAND,"(classmap);");

            buildOptionsPropertySetLines=arrayfun(@(buildOpt)obj.serializeOption(buildOpt,obj.BUILD_OPTS_VAR),obj.generatorOptions);
            buildOptionsPropertySetLines=buildOptionsPropertySetLines(buildOptionsPropertySetLines~="");
            buildLine=strcat(obj.BUILD_RESULTS_VAR," = ",obj.BUILD_COMMAND,"(",obj.BUILD_OPTS_VAR,");");

            script=strjoin(["% "+string(message("Compiler:deploymentscript:buildIntro")),...
            classmapCreationLine,...
            buildOptionsCreationLine,...
            buildOptionsPropertySetLines,...
            buildLine],newline);
        end
    end

end

