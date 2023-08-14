function selectAllItems(dataModel,valuesList,~)


    txn=dataModel.beginTransaction();
    allItems=valuesList.Items.toArray();
    for item=allItems
        item.Selected=true;
    end
    txn.commit();

    simulink.multisim.internal.utils.ValuesList.updateValuesListNumDesignPoints(valuesList);

    simulink.multisim.internal.updateDesignStudyNumSimulations(valuesList);
end