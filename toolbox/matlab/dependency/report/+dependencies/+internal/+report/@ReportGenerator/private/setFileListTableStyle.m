function table=setFileListTableStyle(table)




    table.TableEntriesStyle={mlreportgen.dom.InnerMargin("10px","10px")};
    table.Border="double";
    table.ColSep="double";
    table.RowSep="double";
    table.TableEntriesHAlign="left";
    table.TableEntriesVAlign="middle";
    table.Style{end+1}=mlreportgen.dom.OuterMargin("20px");
end
