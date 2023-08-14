










function path=getComponentPath(comp)

    path='';

    switch(comp.Type)
    case{Advisor.component.Types.Model,Advisor.component.Types.ProtectedModel}
        path=comp.ID;

    case Advisor.component.Types.SubSystem
        path=Simulink.ID.getFullName(comp.ID);

    case Advisor.component.Types.Chart
        [obj,context]=Advisor.component.getComponentSource(comp);

        if~isempty(context)



            path=context.getFullName();
        else
            path=obj.getFullName();
        end

    case Advisor.component.Types.MATLABFunction
        [obj,context]=Advisor.component.getComponentSource(comp);

        if~isempty(context)





            if isa(obj,'Stateflow.EMChart')
                path=context.getFullName();
            else
                mlfunctionPathInLib=obj.getFullName();
                instanceChartPath=context.getFullName();
                chartPathInLib=obj.Chart.getFullName();
                path=[instanceChartPath,mlfunctionPathInLib(length(chartPathInLib)+1:end)];
            end
        else
            path=obj.getFullName();
        end

    otherwise

    end
end