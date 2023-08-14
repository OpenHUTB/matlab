classdef BDInfo<handle




    properties(GetAccess=public,SetAccess=private)
        IsTestHarness(1,1)logical
        AllowRename(1,1)logical
        ModelName(1,1)string
        HarnessName(1,1)string
        ModelFile(1,1)string
    end

    methods(Access=public)
        function obj=BDInfo(...
            isTestHarness,...
            modelName,...
            harnessName,...
            modelFile,...
allowRename...
            )
            obj.IsTestHarness=isTestHarness;
            obj.ModelName=modelName;
            obj.HarnessName=harnessName;
            obj.ModelFile=modelFile;
            obj.AllowRename=allowRename;
        end

        function ensureLoaded(obj)
            if obj.IsTestHarness
                obj.ensureTestHarnessLoaded()
            else
                obj.ensureModelLoaded()
            end
        end

        function name=getSystemName(obj)
            if obj.IsTestHarness
                name=slxmlcomp.internal.testharness.getHarnessMemName(...
                char(obj.ModelFile),...
                char(obj.HarnessName),...
                obj.AllowRename...
                );
            else
                name=obj.ModelName;
            end
        end
    end

    methods(Access=private)
        function ensureModelLoaded(obj)
            slxmlcomp.internal.loadModel(obj.ModelFile);
        end

        function ensureTestHarnessLoaded(obj)
            slxmlcomp.internal.testharness.load(...
            char(obj.ModelFile),...
            char(obj.HarnessName),...
            obj.AllowRename...
            );
        end

    end

    methods(Access=public,Static)
        function bdInfo=fromJHighlightData(jHighlightData)

            import slxmlcomp.internal.highlight.window.BDLocation
            import slxmlcomp.internal.highlight.window.BDInfo

            harnessNode=getTestHarnessAncestor(jHighlightData.getNode());
            isInTestHarness=~isempty(harnessNode);
            modelFile=string(jHighlightData.getFile().getAbsolutePath());
            if isInTestHarness
                harnessName=string(harnessNode.getName());
            else
                harnessName="";
            end

            [~,modelName,~]=fileparts(modelFile);

            bdInfo=BDInfo(...
            isInTestHarness,...
            modelName,...
            harnessName,...
            modelFile,...
            jHighlightData.getAllowRename()...
            );
        end

        function info=fromMergeActionDataSource(jMergeActionData)

            import slxmlcomp.internal.highlight.window.BDInfo;

            node=jMergeActionData.getFromNode();
            if isempty(node)
                node=jMergeActionData.getToNode();
            end

            info=BDInfo.fromNodeAndSource(...
            node,...
            jMergeActionData.getFromSource(),...
true...
            );
        end

        function info=fromNodeAndSource(node,comparisonSource,allowRename)

            import slxmlcomp.internal.highlight.window.BDInfo;

            harnessNode=getTestHarnessAncestor(node);
            isInTestHarness=~isempty(harnessNode);
            harnessName="";
            if isInTestHarness
                harnessName=string(harnessNode.getName());
            end

            sourceFile=getFileToUseInMemory(comparisonSource);
            [~,modelName,~]=fileparts(char(sourceFile.getPath()));

            info=BDInfo(...
            isInTestHarness,...
            modelName,...
            harnessName,...
            string(sourceFile.getPath()),...
allowRename...
            );
        end

        function info=fromMergeActionDataTarget(jMergeActionData)

            import slxmlcomp.internal.highlight.window.BDInfo;

            node=jMergeActionData.getToNode();
            if isempty(node)
                node=jMergeActionData.getFromNode();
            end

            harnessNode=getTestHarnessAncestor(node);
            isInTestHarness=~isempty(harnessNode);
            harnessName="";
            if isInTestHarness
                harnessName=string(harnessNode.getName());
            end

            sourceFile=getFileToUseInMemory(jMergeActionData.getToSource());
            [~,modelName,~]=fileparts(char(sourceFile.getPath()));

            allowRename=false;
            info=BDInfo(...
            isInTestHarness,...
            modelName,...
            harnessName,...
            string(sourceFile.getPath()),...
allowRename...
            );
        end

        function info=fromDetermineMergeableNode(node,modelFile)
            import slxmlcomp.internal.highlight.window.BDInfo;

            harnessNode=getTestHarnessAncestor(node);
            isInTestHarness=~isempty(harnessNode);
            harnessName="";
            if isInTestHarness
                harnessName=string(harnessNode.getName());
            end

            [~,modelName,~]=fileparts(modelFile);

            allowRename=false;
            info=BDInfo(...
            isInTestHarness,...
            modelName,...
            harnessName,...
            string(modelFile),...
allowRename...
            );
        end
    end

end

function harnessNode=getTestHarnessAncestor(jNode)
    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.testharness.TestHarnessUtils
    harnessNode=TestHarnessUtils.getTestHarnessAncestorNode(jNode);
end

function file=getFileToUseInMemory(jSource)
    import com.mathworks.toolbox.rptgenslxmlcomp.comparison.merge.SimulinkMergeUtilities
    slxSource=SimulinkMergeUtilities.getSLXSource(jSource);
    file=slxSource.getModelData().getFileToUseInMemory();
end
