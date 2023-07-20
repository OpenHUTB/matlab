classdef jc_0733_a<slcheck.subcheck
    methods
        function obj=jc_0733_a()
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID='jc_0733_a';
        end

        function result=run(this)

            result=false;

            obj=this.getEntity();

            if~isa(obj,'Stateflow.State')
                return;
            end


            sLabel=regexprep(obj.LabelString,'/\*.*\*/','');
            sLabel=regexprep(sLabel,'(//|%)[^\n]*\n','');


            enIdx=regexp(sLabel,'(en|entry)\s*:');
            duIdx=regexp(sLabel,'(du|during)\s*:');
            exIdx=regexp(sLabel,'(ex|exit):\s*');

            if isempty(enIdx)&&isempty(duIdx)&&isempty(exIdx)
                return;
            end

            allIdx=[enIdx,duIdx,exIdx];
            [~,sortIdx]=sort(allIdx);
            if~isequal(sortIdx,(1:numel(allIdx)))
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end
        end
    end
end

