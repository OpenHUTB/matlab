classdef(Abstract)MonitorFactory<handle





    methods(Abstract)

        model=createMonitorModel(this)


        view=createMultiAxesView(this,parent,model)
    end
end
