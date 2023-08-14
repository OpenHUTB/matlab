classdef subcheck_jc_0753<slcheck.subcheck


    properties
        Strict=1;
    end

    methods
        function obj=subcheck_jc_0753(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Strict=InitParams.Strict;
        end
        function result=run(this)
            result=false;
            violations=[];
            sfObj=this.getEntity();
            if 1==this.Strict


                violations=[violations;checkTransitionActionsInChart(sfObj)];
            else

                violations=[violations;checkCondAndTransitionActionsInChart(sfObj)];
            end

            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end

function violations=checkTransitionActionsInChart(transObj)
    violations=[];

    if~isa(transObj,'Stateflow.Transition')
        return
    end
    if ModelAdvisor.internal.hasTransitionAction(transObj)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
        DAStudio.message('ModelAdvisor:jmaab:ColumnHeader_Chart'),...
        transObj.chart,...
        DAStudio.message('ModelAdvisor:jmaab:ColumnHeader_Transitions'),...
        transObj);
        violations=[violations;vObj];
    end
end
function violations=checkCondAndTransitionActionsInChart(chart)


    violations=[];
    if~isa(chart,'Stateflow.Chart')
        return
    end
    transObj=chart.find('-isa','Stateflow.Transition');
    condActionFlag=false;
    transActionFlag=false;
    transActionObj=[];
    for idx=1:length(transObj)
        if~isempty(transObj(idx).conditionaction)
            condActionFlag=true;
        end
        if~isempty(transObj(idx).transitionaction)
            transActionFlag=true;
            transActionObj=[transActionObj;transObj(idx)];%#ok<AGROW>
        end
    end
    if condActionFlag&&transActionFlag
        for i=1:length(transActionObj)
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
            DAStudio.message('ModelAdvisor:jmaab:ColumnHeader_Chart'),...
            transActionObj(i).chart,...
            DAStudio.message('ModelAdvisor:jmaab:ColumnHeader_Transitions'),...
            transActionObj(i));
            violations=[violations;vObj];%#ok<AGROW>
        end

    end

end