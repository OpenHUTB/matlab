function parser=getParserForBreakpointObjects()





    parser=SimulinkFixedPoint.SimulinkVariableUsageParser.Parser();
    setUsersFilter(parser,SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.FilterForBreakpointObjects);
    setSourceTypeFilter(parser,SimulinkFixedPoint.SimulinkVariableUsageParser.Filters.SourceTypeFilterForDataTypingServices);
end