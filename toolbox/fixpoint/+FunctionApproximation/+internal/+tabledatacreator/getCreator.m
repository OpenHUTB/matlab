function tableDataCreator=getCreator(breakpointSpecification)



    if isEvenSpacing(breakpointSpecification)
        tableDataCreator=FunctionApproximation.internal.tabledatacreator.EvenSpacingTableDataCreator;
    else
        tableDataCreator=FunctionApproximation.internal.tabledatacreator.ExplicitValueTableDataCreator;
    end
end
