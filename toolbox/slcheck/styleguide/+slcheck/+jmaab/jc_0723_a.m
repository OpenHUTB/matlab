classdef jc_0723_a<slcheck.subcheck
    methods
        function obj=jc_0723_a()
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID='jc_0723_a';
        end

        function result=run(this)

            result=false;

            obj=this.getEntity();

            if~isa(obj,'Stateflow.Transition')
                return;
            end

            if isempty(obj.Source)||isempty(obj.Destination)
                return;
            end

            if Advisor.Utils.Stateflow.isSuperTransitionToDest(obj)
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end

        end
    end
end
