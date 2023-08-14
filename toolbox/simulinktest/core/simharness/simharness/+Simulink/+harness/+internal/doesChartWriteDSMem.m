function res=doesChartWriteDSMem(chartPath,memName)
    res=false;
    chartID=sfprivate('block2chart',chartPath);
    chartH=idToHandle(sfroot,chartID);
    d=chartH.find('-isa','Stateflow.Data','scope','Data Store Memory','Name',memName);
    if isempty(d)
        return
    end

    switch(class(chartH))
    case{'Stateflow.Chart',...
        'Stateflow.StateTransitionTableChart',...
        'Stateflow.ReactiveTestingTableChart',...
        }
        Stateflow.internal.UsesDatabase.RehashUsesInObject(chartID);
        uses=Stateflow.internal.UsesDatabase.GetAllUsesOfObject(d.Id);
        n=length(uses);
        for i=1:n
            if uses(i).accessType==1||uses(i).accessType==2
                res=true;
                return;
            end
        end
    otherwise
        res=false;
    end

end