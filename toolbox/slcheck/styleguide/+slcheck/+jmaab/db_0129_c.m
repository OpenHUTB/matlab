classdef db_0129_c<slcheck.subcheck
    methods
        function obj=db_0129_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0129_c';
        end
        function result=run(this)
            result=false;
            violations=[];
            obj=this.getEntity();

            if isa(obj,'Stateflow.Chart')
                sfTransitions=obj.find('-isa','Stateflow.Transition');

                sfStateandObjs=obj.find('-isa','Stateflow.State',...
                '-or','-isa','Stateflow.SimulinkBasedState',...
                '-or','-isa','Stateflow.Box',...
                '-or','-isa','Stateflow.SLFunction',...
                '-or','-isa','Stateflow.EMFunction',...
                '-or','-isa','Stateflow.TruthTable',...
                '-or','-isa','Stateflow.AtomicSubchart',...
                '-or','-isa','Stateflow.Annotation',...
                '-or','-isa','Stateflow.Function',...
                '-or','-isa','Stateflow.Junction');
                violations=[violations;getTransitionsCrossingStates(sfTransitions,sfStateandObjs)];

                if~isempty(violations)
                    result=this.setResult(violations);
                end
            end
        end
    end
end


function violations=getTransitionsCrossingStates(sfTransitions,sfStates)
    violations={};
    errTrans=[];
    if isempty(sfTransitions)||isempty(sfStates)
        return;
    end
    for k=1:length(sfTransitions)
        for p=1:length(sfStates)
            if~isequal(sfTransitions(k).Path,sfStates(p).Path)
                continue;
            end

            if isa(sfStates(p),'Stateflow.Junction')
                if Advisor.Utils.Stateflow.doTransitionJunctionOverlap(sfTransitions(k),sfStates(p))
                    errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>                    
                end
                continue;
            end

            if~Advisor.Utils.Stateflow.doTransitionBoxOverlap(...
                sfTransitions(k),sfStates(p))
                if isa(sfStates(p),'Stateflow.AtomicSubchart')
                    if ModelAdvisor.internal.isTransitionInsideBox(...
                        sfTransitions(k),sfStates(p))
                        errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                    end
                end
                continue;
            end


            if~isa(sfStates(p),'Stateflow.State')&&(~isa(sfStates(p),'Stateflow.Box'))
                errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                continue;
            end


            if~Advisor.Utils.Stateflow.isDefaultTransition(sfTransitions(k))
                parentObj=sfTransitions(k).Source.getParent;
            else
                parentObj=sfTransitions(k).getParent;
            end
            if(isa(sfStates(p),'Stateflow.Box')&&...
                (~(isequal(parentObj,sfStates(p))||...
                isequal(sfTransitions(k).Destination.getParent,sfStates(p)))))
                errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                continue;
            end


            if isequal(sfStates(p),sfTransitions(k).Source)||...
                isequal(sfStates(p),sfTransitions(k).Destination)
                errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                continue;
            end

            destobj=sfTransitions(k).Destination;

            if isempty(destobj)
                errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                continue;
            end


            if isa(destobj,'Stateflow.State')






                states=sfStates(p).find('-isa','Stateflow.State');
                states(arrayfun(@(x)x.getParent==sfStates(p),states));

                junctions=sfStates(p).find('-isa','Stateflow.Junction','-and','type','CONNECTIVE');

                if(any(ismember(states,destobj))&&...
                    any(ismember([states;junctions],sfTransitions(k).Source)))||...
                    (~any(ismember(states,destobj))&&...
                    ~any(ismember([states;junctions],sfTransitions(k).Source)))
                    errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                    continue;
                end
            end

            if isa(destobj,'Stateflow.Junction')
                if(strcmp(destobj.getParent.getFullName,sfTransitions(k).Source.getParent.getFullName))
                    errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                    continue;
                end




                if~isequal(destobj.getParent,sfStates(p))&&...
                    (isprop(destobj.getParent,'IsSubchart')&&destobj.getParent.IsSubchart)
                    errTrans=[errTrans;sfTransitions(k)];%#ok<AGROW>
                end
            end
        end
    end
    errTrans=unique(errTrans);
    for idx=1:length(errTrans)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',errTrans(idx));
        violations=[violations;vObj];%#ok<AGROW>
    end
end