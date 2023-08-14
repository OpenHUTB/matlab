function toggleColumn(columnName,cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;

    visibleColumns=guiObj.getVisibleColumns();
    columnIdx=contains(visibleColumns,columnName);
    isColumnVisible=any(columnIdx);
    isColumnCheckboxSelected=cbinfo.EventData;

    if isColumnCheckboxSelected

        if~isColumnVisible

            visibleColumns{end+1}=columnName;


            allTabColumns=guiObj.getColumnsForCurrentTab();
            visibleColumnsIdx=contains(allTabColumns,visibleColumns);
            orderedVisibleColumns=allTabColumns(visibleColumnsIdx);
            guiObj.setVisibleColumns(orderedVisibleColumns);
        end
    else

        if isColumnVisible

            visibleColumns(columnIdx)=[];
            guiObj.setVisibleColumns(visibleColumns);
        end
    end
end
