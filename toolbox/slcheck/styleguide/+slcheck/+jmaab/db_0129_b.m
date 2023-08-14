classdef db_0129_b<slcheck.subcheck
    methods
        function obj=db_0129_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0129_b';
        end
        function result=run(this)
            result=false;
            violations=[];
            obj=this.getEntity();

            if isa(obj,'Stateflow.Chart')
                sfTransitions=obj.find('-isa','Stateflow.Transition');
                violations=[violations;getTransitionsOverlappingOtherTransitions(sfTransitions)];

                if~isempty(violations)
                    result=this.setResult(violations);
                end
            end
        end
    end
end

function violationObj=getTransitionsOverlappingOtherTransitions(sfTransitions)
    violationObj=[];
    errTrans=[];
    if isempty(sfTransitions)
        return;
    end
    allSFIds=arrayfun(@(x)x.Id,sfTransitions);


    adjacencyMatrix=zeros(length(allSFIds));




    for k=1:length(sfTransitions)
        for p=1:length(sfTransitions)
            if isequal(k,p)||~isequal(sfTransitions(k).Path,sfTransitions(p).Path)
                continue;
            end


            if 1==adjacencyMatrix(allSFIds==sfTransitions(k).Id,...
                allSFIds==sfTransitions(p).Id)||...
                1==adjacencyMatrix(allSFIds==sfTransitions(p).Id,...
                allSFIds==sfTransitions(k).Id)
                continue;
            end

            adjacencyMatrix(allSFIds==sfTransitions(k).Id,...
            allSFIds==sfTransitions(p).Id)=1;
            adjacencyMatrix(allSFIds==sfTransitions(p).Id,...
            allSFIds==sfTransitions(k).Id)=1;

            if Advisor.Utils.Stateflow.doTransitionsOverlap(sfTransitions(k),...
                sfTransitions(p))
                errTrans=[errTrans;sfTransitions(k);sfTransitions(p)];%#ok<AGROW>
                continue;
            end
        end
    end
    errTrans=unique(errTrans);
    for idx=1:length(errTrans)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',errTrans(idx));
        violationObj=[violationObj;vObj];%#ok<AGROW>
    end
end
