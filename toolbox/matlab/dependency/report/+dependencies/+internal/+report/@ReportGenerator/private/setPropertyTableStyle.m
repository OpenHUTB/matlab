function table=setPropertyTableStyle(table)




    table.TableEntriesStyle={mlreportgen.dom.InnerMargin("10px","10px")};
    table.Border="none";
    table.ColSep="none";
    table.RowSep="none";
    table.TableEntriesHAlign="left";
    table.Style{end+1}=mlreportgen.dom.OuterMargin("20px");
    for rowIndex=1:table.NRows
        table.entry(rowIndex,1).Style={mlreportgen.dom.Bold(true)};
    end
end
