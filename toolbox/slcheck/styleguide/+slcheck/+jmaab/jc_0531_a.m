




classdef jc_0531_a<slcheck.subcheck
    methods
        function obj=jc_0531_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0531_a';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            violations=[];
            if isa(obj,'Stateflow.Object')


                defaultTransitions=ModelAdvisor.internal.getDefaultTransitions(obj,1);


                [~,exclusiveStates]=ModelAdvisor.internal.getStates(...
                obj,1,false,true);


                junctions=ModelAdvisor.internal.getJunctions(obj,1,true);



                [~,errObj]=...
                ModelAdvisor.internal.jc_0531.hasNoDefaultTransition(...
                defaultTransitions,[exclusiveStates;junctions]);

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