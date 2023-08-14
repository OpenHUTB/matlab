classdef jc_0626_b<slcheck.subcheck

    methods
        function obj=jc_0626_b(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.CheckName;
        end
        function result=run(this)

            result=false;
            obj=this.getEntity();
            violations=[];


            if strcmp(get_param(obj,'BlockType'),'Lookup_n-D')


                interpMethod=get_param(obj,'InterpMethod');
                extrapMethod=get_param(obj,'ExtrapMethod');
                useLastTableValue=get_param(obj,'UseLastTableValue');



                if~any(strcmp(interpMethod,{'Linear point-slope','Linear Lagrange'}))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,...
                    'Block',obj,...
                    'Parameter','InterpMethod',...
                    'CurrentValue',interpMethod,...
                    'RecommendedValue','Linear point-slope|Linear Lagrange');
                    violations=[violations;vObj];
                end



                if~strcmp(extrapMethod,'Clip')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,...
                    'Block',obj,...
                    'Parameter','ExtrapMethod',...
                    'CurrentValue',extrapMethod,...
                    'RecommendedValue','Clip');
                    violations=[violations;vObj];
                end




                if strcmp(useLastTableValue,'off')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,...
                    'Block',obj,...
                    'Parameter','UseLastTableValue',...
                    'CurrentValue',useLastTableValue,...
                    'RecommendedValue','on');
                    violations=[violations;vObj];
                end

            end
            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
        function bSuccess=fixit(this)
            bSuccess=true;

            obj=this.getEntity();
            if strcmp(get_param(obj,'BlockType'),'Lookup_n-D')
                interpMethod=get_param(obj,'InterpMethod');
                extrapMethod=get_param(obj,'ExtrapMethod');
                useLastTableValue=get_param(obj,'UseLastTableValue');

                if any(strcmp(interpMethod,{'Cubic spline','Akima spline'}))
                    set_param(obj,'InterpMethod','Linear point-slope');
                elseif~strcmp(extrapMethod,'Clip')
                    set_param(obj,'ExtrapMethod','Clip');
                elseif strcmp(useLastTableValue,'off')
                    set_param(obj,'UseLastTableValue','on');
                end
            end
        end
    end
end