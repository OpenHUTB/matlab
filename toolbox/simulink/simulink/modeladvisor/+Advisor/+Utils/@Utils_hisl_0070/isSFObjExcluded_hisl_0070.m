function bResult=isSFObjExcluded_hisl_0070(Object,opt,forReq)



    if~contains(class(Object),'Stateflow')...
        ||isa(Object,'Stateflow.SLFunction')...
        ||isa(Object,'Stateflow.Data')...
        ||isa(Object,'Stateflow.Junction')...
        ||isa(Object,'Stateflow.Annotation')...
        ||isa(Object,'Stateflow.Event')
        bResult=true;
    elseif Advisor.Utils.Utils_hisl_0070.hasReqs(Object,opt)
        bResult=true;
    elseif isa(Object,'Stateflow.EMChart')||isa(Object,'Stateflow.EMFunction')
        bResult=false;
    elseif opt.link2ContainerOnly
        children=setdiff(Object.find([rmisf.sfisa('isaFilter'),{'-depth'},{1}]),Object);
        if isempty(children)

            bResult=forReq;

        else
            bResult=true;
            for i=1:length(children)
                bResult=bResult&&(~isempty(setdiff(children(i).find([rmisf.sfisa('isaFilter'),{'-depth'},{1}]),children(i)))||Advisor.Utils.Utils_hisl_0070.hasReqs(children(i),opt));
            end
        end
    else
        bResult=false;
    end
end

