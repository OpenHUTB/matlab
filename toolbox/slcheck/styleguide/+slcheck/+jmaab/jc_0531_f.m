
classdef jc_0531_f<slcheck.subcheck
    methods
        function obj=jc_0531_f()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0531_f';
        end
        function result=run(this)
            result=false;
            violations=[];
            obj=this.getEntity();
            if isa(obj,'Stateflow.Object')


                defaultTransitions=ModelAdvisor.internal.getDefaultTransitions(obj,1);


                [parallelStates,exclusiveStates]=ModelAdvisor.internal.getStates(...
                obj,1,false,true);


                [~,errObj]=...
                ModelAdvisor.internal.jc_0531.doesDefaultTransitionExceedStateBoundary(...
                defaultTransitions,[parallelStates,exclusiveStates]);

                if~isempty(errObj)&&iscell(errObj)
                    errObj=[errObj{:}];
                end

                for idx=1:length(errObj)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',errObj(idx));
                    violations=[violations;vObj];%#ok<AGROW>
                end
                if~isempty(violations)
                    result=this.setResult(violations);
                end
            end
        end
    end
end