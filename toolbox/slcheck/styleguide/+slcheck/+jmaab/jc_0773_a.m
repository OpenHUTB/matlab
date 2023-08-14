classdef jc_0773_a<slcheck.subcheck
    methods

        function obj=jc_0773_a()
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID='jc_0773_a';
        end

        function result=run(this)
            result=false;

            sfJObj=this.getEntity();

            if isempty(sfJObj)
                return;
            end



            if~isa(sfJObj,'Stateflow.Junction')
                return;
            end



            M=containers.Map('KeyType','double','ValueType','double');
            sfObj={sfJObj};
            i=1;
            while i<=numel(sfObj)
                if isKey(M,sfObj{i}.Id)
                    i=i+1;
                    continue;
                else

                    M(sfObj{i}.Id)=sfObj{i}.Id;
                end

                if isa(sfObj{i},'Stateflow.Junction')
                    transitions=[sfObj{i}.sourcedTransitions;sfObj{i}.sinkedTransitions];

                    for j=1:numel(transitions)

                        if isKey(M,transitions(j).Id)
                            i=i+1;
                            continue;
                        else
                            sfObj{end+1}=transitions(j);
                        end
                    end
                elseif isa(sfObj{i},'Stateflow.Transition')

                    objs=[sfObj{i}.Source;sfObj{i}.Destination];

                    for j=1:numel(objs)
                        if isKey(M,objs(j).Id)
                            i=i+1;
                            continue;
                        else
                            sfObj{end+1}=objs(j);
                        end
                    end
                elseif isa(sfObj{i},'Stateflow.State')
                    return;
                end
                i=i+1;
            end


            sourcedTransitions=sfJObj.sourcedTransitions;




            if isempty(sourcedTransitions)
                return;
            end

            conditionalSecCount=0;
            unConditionalSecCount=0;




            for tCount=1:numel(sourcedTransitions)

                section=Advisor.Utils.Stateflow...
                .getAbstractSyntaxTree(sourcedTransitions(tCount));

                if isempty(section)
                    continue;
                end


                if~isempty(section.conditionSection)

                    conditionalSecCount=conditionalSecCount+1;
                else

                    unConditionalSecCount=unConditionalSecCount+1;

                end

            end





            if conditionalSecCount==0||...
                (conditionalSecCount>0&&unConditionalSecCount==1)

                return;

            end

            rdObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(rdObj,'SID',sfJObj);
            result=this.setResult(rdObj);

        end
    end
end