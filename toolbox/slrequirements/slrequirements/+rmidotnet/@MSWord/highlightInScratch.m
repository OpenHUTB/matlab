function highlightInScratch(this,item,color)

    selection=this.hTempDoc.ActiveWindow.Selection;
    selection.Start=item.range(1);
    selection.End=item.range(2);

    switch color
    case 'yellow'
        selection.Range.Shading.BackgroundPatternColor=Microsoft.Office.Interop.Word.WdColor.wdColorYellow;
    case 'green'
        selection.Range.Shading.BackgroundPatternColor=Microsoft.Office.Interop.Word.WdColor.wdColorBrightGreen;
    otherwise
        disp(['MSWord.highlightScratch: unsupported color ',color]);
    end

end
