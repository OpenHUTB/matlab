classdef db_0141_c<slcheck.subcheck
    methods
        function obj=db_0141_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0141_c';
        end

        function result=run(this)
            result=true;
            canvasH=this.getEntity();

            if ischar(canvasH)
                canvasH=get_param(canvasH,'handle');
            end


            signals=find_system(canvasH,'FindAll',true,'SearchDepth',1,'type','line');

            if isempty(signals)
                return;
            end

            violations=[];

            for i=1:numel(signals)

                if SLM3I.SLDomain.doesSegmentsContainKinks(signals(i))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',signals(i));
                    violations=[violations;vObj];
                end
            end


            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end