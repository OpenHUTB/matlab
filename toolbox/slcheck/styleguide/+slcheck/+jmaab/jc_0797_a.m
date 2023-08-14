classdef jc_0797_a<slcheck.subcheck
    methods
        function obj=jc_0797_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0797_a';
        end

        function result=run(this)
            result=false;

            obj=this.getEntity();

            if isa(obj,'Stateflow.Transition')&&(isempty(obj.Destination)||any(strcmp(getSFLintIssue(obj),DAStudio.message('Stateflow:sflint:DanglingTransitionInfo'))))
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end


        end
    end
end

function issue=getSFLintIssue(Obj)
    r=sf('GetLintIssues',Obj.Id);
    if~isempty(r)
        issue={r(:).name};
    else
        issue='';
    end
end