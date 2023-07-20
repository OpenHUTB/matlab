function execute(obj)
    obj.addItem(DAStudio.message('RTW:report:ReducedBlocksSummary'));
    tableData=obj.getTableData(true);
    table=Advisor.Table(size(tableData,1),size(tableData,2));
    table.setStyle('AltRow');
    table.setColHeading(1,DAStudio.message('RTW:report:ReducedBlocksTableColumnBlock'));
    table.setColHeading(2,DAStudio.message('RTW:report:ReducedBlocksTableColumnDescription'));
    table.setEntries(tableData);
    obj.addItem(table);
end
