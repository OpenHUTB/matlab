function val=isStateflowChart(this,chartHandle)



    val=isa(chartHandle,'Stateflow.Chart')||isa(chartHandle,'Stateflow.StateTransitionTableChart');

end

