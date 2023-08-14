function varargout=findDecoupledSubsystems(sud)







    collector=DataTypeWorkflow.Advisor.internal.DecoupledSubsystemCollector();
    try

        collector.collect(sud);
    catch err
        throwAsCaller(err);
    end

    if nargout==1

        varargout{1}=collector.Table;
    else

        displayStrategy=DataTypeWorkflow.Advisor.internal.getDecoupledSubsystemListDisplayStrategy(collector.Table);
        displayStrategy.constructDisplayList();
        displayStrategy.displayList();
    end
end