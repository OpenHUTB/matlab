classdef jc_0733_b<slcheck.subcheck
    methods
        function obj=jc_0733_b()
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID='jc_0733_b';
        end

        function result=run(this)

            result=false;

            obj=this.getEntity();

            if~isa(obj,'Stateflow.State')
                return;
            end


            sLabel=regexprep(obj.LabelString,'/\*.*?\*/','');
            sLabel=regexprep(sLabel,'(//|%)[^\n]*\n','');
            sLabel=regexprep(sLabel,'\s','');

            toks=regexp(sLabel,'(en|entry|du|during|ex|exit)(,(en|entry|du|during|ex|exit))+:','tokens');
            toks=[toks{:}];

            if isempty(toks)
                return;
            end

            tempToks=toks;
            toks={};

            for i=1:numel(tempToks)
                tok=split(tempToks{i},',');
                for j=1:numel(tok)
                    if~isempty(tok{j})
                        toks{end+1}=tok{j};
                    end
                end
            end


            toks=strrep(toks,'en','1');
            toks=strrep(toks,'du','2');
            toks=strrep(toks,'ex','3');

            if~issorted(toks)||~all(cellfun(@(x)issorted(str2num(x)),toks))%#ok<ST2NM>
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                result=this.setResult(vObj);
            end
        end
    end
end

