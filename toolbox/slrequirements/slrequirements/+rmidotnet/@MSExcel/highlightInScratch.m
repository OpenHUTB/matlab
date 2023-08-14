function highlightInScratch(this,item,color)





    tempSheet=Microsoft.Office.Interop.Excel.Worksheet(this.hTempDoc.Sheets.Item(this.iSheet));

    rangeString=rmidotnet.MSExcel.itemToRangeString(item,'first');
    hRange=tempSheet.Range(rangeString);

    hRange.Font.Bold=1;
    switch color
    case 'red'
        hRange.Font.Color=1000;
    case 'green'
        hRange.Font.Color=20000;
    otherwise

    end


    rangeString=rmidotnet.MSExcel.itemToRangeString(item,'last');
    hRange=tempSheet.Range(rangeString);
    text=hRange.Text.char;
    marker=['[',item.label,']'];
    if isempty(text)
        clipboard('copy',marker);
    else
        text=strrep(text,newline,'  ');
        clipboard('copy',[text,' ',marker]);
    end
    hRange.PasteSpecial();
    hRange.Font.Bold=1;
    hRange.Font.Color=20000;

end

