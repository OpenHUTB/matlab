classdef jc_0773_b<slcheck.subcheck
    methods

        function obj=jc_0773_b()
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID='jc_0773_b';
        end

        function result=run(this)
            result=false;

            sfTObj=this.getEntity();

            if isempty(sfTObj)
                return;
            end


            if~isa(sfTObj,'Stateflow.Transition')
                return;
            end

            section=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfTObj);

            if isempty(section)
                return;
            end




            if~isempty(section.conditionSection)
                return;
            end


            sfSrc=sfTObj.source;

            if isempty(sfSrc)
                return;
            end

            M=containers.Map('KeyType','double','ValueType','double');
            sfObj={sfTObj};
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



            if isa(sfSrc,'Stateflow.SimulinkBasedState')||...
                isa(sfSrc,'Stateflow.AtomicSubchart')
                prt=sfSrc.Chart;
                srcdTxns=prt.find('-isa','Stateflow.Transition','Source',sfSrc);

            elseif isa(sfSrc,'Stateflow.Function')
                return;


            elseif isa(sfSrc,'Stateflow.Box')
                return;
            else
                srcdTxns=sfSrc.sourcedTransitions;
            end





            largestExecutionOrder=numel(srcdTxns);





            if largestExecutionOrder==0||...
                largestExecutionOrder==1

                return;

            end

            executionOrder=sfTObj.ExecutionOrder;






            if executionOrder==largestExecutionOrder
                return;
            end


            rdObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(rdObj,'SID',sfTObj);
            result=this.setResult(rdObj);


        end
    end
end