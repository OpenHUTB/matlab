

classdef jc_0531_g<slcheck.subcheck
    methods
        function obj=jc_0531_g()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0531_g';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            if~isa(obj,'Stateflow.Object')&&...
                isa(get_param(bdroot(obj),'Object'),'Simulink.BlockDiagram')

                if ModelAdvisor.internal.jc_0531.dontHaveSingleNonGuardPath(obj)
                    currentValue=get_param(obj,'SFNoUnconditionalDefaultTransitionDiag');
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,...
                    'Model',Simulink.ID.getSID(obj),...
                    'Parameter','SFNoUnconditionalDefaultTransitionDiag',...
                    'CurrentValue',currentValue,...
                    'RecommendedValue','error');
                    result=this.setResult(vObj);
                end
            end
        end
    end
end