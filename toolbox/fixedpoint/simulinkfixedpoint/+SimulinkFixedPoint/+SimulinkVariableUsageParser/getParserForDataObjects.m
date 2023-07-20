function parser=getParserForDataObjects()





    parser=SimulinkFixedPoint.SimulinkVariableUsageParser.Parser();
    setUsersFilter(parser,SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.FilterForDataObjects);
    setSourceTypeFilter(parser,SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.SourceTypeFilterForDataTypingServices);
end