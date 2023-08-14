classdef(Hidden=true)CheckStyleFactory<ModelAdvisor.Report.StyleFactory
    methods(Static,Hidden=true)
        function styles=getSupportedStyles
            styles={'ModelAdvisor.Report.StandardStyle','ModelAdvisor.Report.SubsystemStyle','ModelAdvisor.Report.BlockStyle'};
        end

        function styleNames=getSupportedStyleNames(styles)
            styleNames=cell(1,numel(styles));
            for i=1:numel(styles)
                styleObj=ModelAdvisor.Report.StyleFactory.creator(styles{i});
                styleNames{i}=styleObj.Name;
            end
        end
    end
end
