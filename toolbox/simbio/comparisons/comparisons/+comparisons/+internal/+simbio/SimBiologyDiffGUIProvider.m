classdef SimBiologyDiffGUIProvider<comparisons.internal.DiffGUIProvider






    methods

        function tfCanHandle=canHandle(obj,sourceFile,targetFile,options)



            [~,~,firstExt]=fileparts(sourceFile.Path);
            [~,~,secondExt]=fileparts(targetFile.Path);


            tfCanHandle=firstExt==".sbproj"&&...
            secondExt==".sbproj"&&...
            (options.Type==""||options.Type==obj.getType());

        end

        function app=handle(~,sourceFile,targetFile,~)

            try

                sourcePath=string(sourceFile.Path);
                targetPath=string(targetFile.Path);
                options=struct("SourceModelName",string(missing),...
                "TargetModelName",string(missing),...
                "UseSingleProject",sourcePath==targetPath,...
                "AutoSelectModels",true,...
                "IgnoreDiagram",false);
                [modelInfos,blockInfos]=...
                simbio.comparisons.internal.getDiffInfos(sourcePath,...
                targetPath,options);
                modelInfos{1}.GitInfos=sourceFile.Properties;
                modelInfos{2}.GitInfos=targetFile.Properties;

                diffResults=SimBiology.DiffResults(modelInfos{1},modelInfos{2},...
                blockInfos{1},blockInfos{2});

                app=showAndReturnApp(diffResults);
            catch
                exception=MException(message('SimBiology:diff:FailedToOpenDiffApp'));
                throwAsCaller(exception);
            end
        end

        function priority=getPriority(~,~,~,~)


            priority=100;
        end

        function type=getType(~)

            type="sbproj";
        end

        function str=getDisplayType(~)

            str=message("SimBiology:diff:ComparisonDisplayType").string();
        end
    end

end
