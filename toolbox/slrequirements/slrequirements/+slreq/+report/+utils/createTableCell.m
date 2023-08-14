function tCell=createTableCell(content,isHeader)
    if isHeader
        tCell=mlreportgen.dom.TableHeaderEntry();
    else
        tCell=mlreportgen.dom.TableEntry();
    end
    tCell.append(content);
end