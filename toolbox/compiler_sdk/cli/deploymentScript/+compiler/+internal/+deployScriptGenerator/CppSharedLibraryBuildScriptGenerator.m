classdef CppSharedLibraryBuildScriptGenerator<compiler.internal.deployScriptGenerator.DeployScriptGenerator


    properties(Constant,Access=private)
        BUILD_COMMAND="compiler.build.cppSharedLibrary";
        BUILD_OPTIONS_COMMAND="compiler.build.CppSharedLibraryOptions";
        BUILD_OPTS_VAR="buildOpts";
    end

    methods
        function obj=CppSharedLibraryBuildScriptGenerator(adapter)
            obj=obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator(adapter);

            obj.generatorOptions=[compiler.internal.option.DeploymentOption.allBuildTargetOptions,...
            compiler.internal.option.DeploymentOption.DebugBuild,...
            compiler.internal.option.DeploymentOption.Interface,...
            compiler.internal.option.DeploymentOption.LibraryName,...
            compiler.internal.option.DeploymentOption.LibraryVersion,...
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

    methods(Access=protected)
        function optionLine=serializeOption(obj,option,scriptVarName)
            if option==compiler.internal.option.DeploymentOption.Interface


                optionName=option.optionName();
                optionValue=obj.adapter.getOptionValue(option);
                optionLine="";
                if optionValue=="all"

                    optionLine=strcat("%"+scriptVarName,".",optionName," = ""mwarray"";");
                    optionLine=optionLine+newline;
                    optionValue="matlab-data";
                end
                optionLine=strcat(optionLine,scriptVarName,".",optionName," = """,optionValue,""";");
            else
                optionLine=serializeOption@compiler.internal.deployScriptGenerator.DeployScriptGenerator(obj,option,scriptVarName);
            end
        end

    end
end
