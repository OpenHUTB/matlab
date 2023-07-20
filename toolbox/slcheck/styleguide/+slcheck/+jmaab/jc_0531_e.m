


classdef jc_0531_e<slcheck.subcheck
    methods
        function obj=jc_0531_e()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0531_e';
        end
        function result=run(this)
            result=false;
            violations=[];
            obj=this.getEntity();
            if isa(obj,'Stateflow.Object')

                [~,errObj]=...
                ModelAdvisor.internal.jc_0531.isDestinationNotPositionedOnTop(...
                obj);

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