classdef SLXImageMapper<handle

    properties(Access=private)
ModelCloseActions
    end

    methods(Access=public)
        function obj=SLXImageMapper()
            obj.ModelCloseActions={};
        end

        function imageFile=createScreenshot(obj,node,source,outputpath)
            import slxmlcomp.internal.report.sections.SystemImage;
            import slxmlcomp.internal.report.sections.Util;
            import slxmlcomp.internal.report.sections.ChartSection;

            import slxmlcomp.internal.highlight.window.BDInfo;
            info=BDInfo.fromNodeAndSource(...
            node,...
            source,...
true...
            );

            obj.ensureLoaded(info);

            image=SystemImage(...
            obj.getNodePath(node),...
            outputpath,...
'svg'...
            );

            imageFile=image.ImageFile;

        end
    end

    methods(Access=private)
        function ensureLoaded(obj,bdInfo)
            bdInfo.ensureLoaded();

            systemName=bdInfo.getSystemName();
            if~isfield(obj.ModelCloseActions,systemName)
                obj.ModelCloseActions.(systemName)=...
                onCleanup(@()close_system(systemName,0));
            end
        end

        function nodePath=getNodePath(~,node)
            import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.decorator.SimulinkPathGeneratingLightweightNode
            pathGenNode=SimulinkPathGeneratingLightweightNode.get(node);
            nodePath=char(pathGenNode.getNodePath());
        end

    end
end

