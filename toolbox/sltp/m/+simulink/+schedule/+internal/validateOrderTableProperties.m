function validateOrderTableProperties(eo)

    validTable=simulink.schedule.internal.createPartitionPropertiesTable(height(eo));

    validTable=validTable(:,1:3);
    validTable.Properties.RowNames=eo.Properties.RowNames;

    if~isequal(...
        validTable.Properties,...
        eo.Properties)
        msg='SimulinkPartitioning:CLI:InvalidOrderPropertyEdit';
        error(message(msg));
    end

    for i=1:length(validTable.Properties.VariableNames)
        if~isequal(class(validTable{:,i}),class(eo{:,i}))
            msg='SimulinkPartitioning:CLI:InvalidOrderVariableDataTypeEdit';
            error(message(msg,validTable.Properties.VariableNames{i}));
        end
    end

end


