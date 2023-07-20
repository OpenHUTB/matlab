classdef TaskAdvisorStandardStyle<ModelAdvisor.Report.TaskAdvisorStyleFactory
    methods
        function obj=TaskAdvisorStandardStyle
            obj.Name=[getString(message('ModelAdvisor:engine:GroupBy')),' ',getString(message('ModelAdvisor:engine:RecommendedAction'))];
        end

        function html=generateReport(this,TaskObj)
            if isa(TaskObj,'ModelAdvisor.Group')
                taskObjs=TaskObj.getAllChildren;
                elementsObjs={};
                for i=1:length(taskObjs)
                    if taskObjs{i}.Selected&&isa(taskObjs{i}.Check,'ModelAdvisor.Check')
                        elementsObjs=[elementsObjs,taskObjs{i}.Check.ResultDetails];%#ok<AGROW>
                    end
                end
                fts=ModelAdvisor.Report.Utils.sortObjs(elementsObjs,'RecommendedAction',true);
                html=fts;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.Group');
            end
        end

    end
end
