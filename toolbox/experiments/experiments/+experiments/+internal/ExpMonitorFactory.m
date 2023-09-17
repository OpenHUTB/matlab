classdef ExpMonitorFactory<experiments.internal.MonitorFactory

    methods
        function model=createMonitorModel(~)
            model=experiment.shared.model.MonitorModel();
        end

        function view=createMultiAxesView(~,parent,model)
            view=experiment.shared.view.MultiAxesView(parent,model);
        end
    end
end
