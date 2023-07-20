classdef subcheck_jc_0771<slcheck.subcheck
    properties(Access=private)
        Position=1;
    end

    properties(Access=private,Constant)



    end

    methods
        function obj=subcheck_jc_0771(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Position=InitParams.Position;
        end

        function result=run(this)
            hasViolation=false;
            result=false;

            transitionObj=this.getEntity();

            if isempty(transitionObj)
                return;
            end

            if~isprop(transitionObj,'LabelString')
                return;
            end

            label=strtrim(transitionObj.LabelString);
            if isempty(label)
                return;
            end



            if isempty(transitionObj.Source)&&strcmp(label,'?')
                return;
            end


            if isempty(strtrim(regexprep(label,'(%|\/\/)[^\n]*\n?','')))||...
...
                isempty(regexp(label,'%|/\*.*?\*/|(\/\/)+.*','once'))
                return;
            end



            config=ModelAdvisor.internal.getTransitionActionTypes(transitionObj);
            if~config.hasCondition&&...
                ~config.hasConditionAction&&...
                ~config.hasTransitionAction&&...
                ~config.hasEvent
                return;
            end


            lineStrs=strsplit(label,'\n');
            if strcmp(transitionObj.Chart.ActionLanguage,'MATLAB')







                expwithComments=['.*(\]+).*(\%).*|'...
                ,'.*(\}+).*(\%).*|'...
                ,'.*(\/+).*(\%).*'];

                only_comments='^(\s*)(\%)+.*';
            else































                expwithComments=['.*(\/\*)+.*(\*\/)+.*(\[+).*|'...
                ,'.*(\/\*)+.*(\*\/)+.*(\{+).*|'...
                ,'.*(\/\*)+.*(\*\/)+.*(\/+).*|'...
                ,'.*(\]+).*(\/\*)+.*(\*\/)+\s*|'...
                ,'.*(\}+).*(\/\*)+.*(\*\/)+\s*|'...
                ,'.*(\/+).*(\/\*)+.*(\*\/)+|'...
                ,'.*(\]+).*(\/\/)+.*|'...
                ,'.*(\}+).*(\/\/)+.*|'...
                ,'.*(\/+).*(\/\/)+.*|'...
                ,'.*(\]+).*(\%).*|'...
                ,'.*(\}+).*(\%).*|'...
                ,'.*(\/+).*(\%).*'];

                only_comments=['^(\s*)(\/\*)+.*(\*\/)+(\s*)$|'...
                ,'^(\s*)(\/\/)+.*|'...
                ,'^(\s*)(\%)+.*'];
            end
            hasComments=cellfun(@(x)~isempty(regexp(x,only_comments,'once')),lineStrs);
            if 1==this.Position




                if any(cellfun(@(x)~isempty(regexp(x,expwithComments,'once')),lineStrs))
                    hasViolation=true;





                elseif~(all(hasComments)||((hasComments(1)==1)&&all((hasComments(2:end)==0))))
                    hasViolation=true;
                end

            else

                if any(cellfun(@(x)~isempty(regexp(x,expwithComments,'once')),lineStrs))
                    hasViolation=true;





                elseif~(all(hasComments)||((hasComments(end)==1)&&all((hasComments(1:end-1)==0))))
                    hasViolation=true;
                end
            end

            if hasViolation
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',transitionObj);
                result=this.setResult(vObj);
            end

        end
    end
end