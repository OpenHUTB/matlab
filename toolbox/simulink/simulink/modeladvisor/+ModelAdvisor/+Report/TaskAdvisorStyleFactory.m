classdef(Hidden=true)TaskAdvisorStyleFactory<ModelAdvisor.Report.StyleFactory
    methods(Static,Hidden=true)
        function styles=getSupportedStyles
            styles={'ModelAdvisor.Report.TaskAdvisorStandardStyle','ModelAdvisor.Report.TaskAdvisorSubsystemStyle','ModelAdvisor.Report.TaskAdvisorBlockStyle'};
        end

        function styleNames=getSupportedStyleNames
            styles=ModelAdvisor.Report.CheckStyleFactory.getSupportedStyles();
            styleNames=cell(1,numel(styles));
            for i=1:numel(styles)
                styleObj=ModelAdvisor.Report.StyleFactory.creator(styles{i});
                styleNames{i}=styleObj.Name;
            end
        end
    end






end
