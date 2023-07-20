function varType=getPropDataType(~,prop)


    switch prop
    case{'Node','NodeType'}
        varType='string';
    case{'ParallelExecutionTime','SerialExecutionTime'}
        varType='double';
    case{'ExecutionMode'}
        varType='enum';
    otherwise
        varType='string';
    end

end
