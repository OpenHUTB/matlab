function count=highlight(this,items)

    count=0;

    if isempty(items)
        return;
    end


    try
        if~this.hDoc.Saved()||~this.matchTimestamp()
            error('Stale data: %s was modified.',this.sName);
        end
    catch
        error('Stale data: %s may have been closed.',this.sName);
    end



    this.updateScratchCopy();
    labelRange=this.hTempDoc.Range;




    for i=1:length(items)
        item=items(i);
        [colorIndex,highlightLabel]=itemTypeToColorIndex(item.type);
        if isempty(colorIndex)
            continue;
        end
        parags=item.parags;
        for idx=parags
            hParag=this.hTempDoc.Paragraphs.Item(idx);
            hParag.Format.Shading.BackgroundPatternColorIndex=colorIndex;
            count=count+1;
        end
        if highlightLabel
            labelRange.Start=item.range(1);
            labelRange.End=item.range(2);
            labelRange.Font.Color=Microsoft.Office.Interop.Word.WdColor.wdColorRed;
        end

    end


    insertColorLegend(this.hTempDoc);


    reqmgt('winFocus',this.hTempDoc.Name.char);

end

function insertColorLegend(tempDoc)
    firstParag=tempDoc.Paragraphs.Item(1);
    origTitle=firstParag.Range.Text.char;
    origColor=firstParag.Format.Shading.BackgroundPatternColorIndex;


    modifiedTitle=['BOOKMARKS MATCHES SECTIONS PARENTS OTHER'...
    ,char(13),char(13),origTitle];
    firstParag.Range.Text=modifiedTitle;


    movedParag=tempDoc.Paragraphs.Item(3);
    movedParag.Format.Shading.BackgroundPatternColorIndex=origColor;



    tmpRange=firstParag.Range;
    tmpRange.Start=0;
    tmpRange.End=length('BOOKMARKS');
    colorIndex=itemTypeToColorIndex('bookmark');
    tmpRange.Shading.BackgroundPatternColorIndex=colorIndex;

    tmpRange.Start=length('BOOKMARKS ');
    tmpRange.End=tmpRange.Start+length('MATCHES');
    colorIndex=itemTypeToColorIndex('match');
    tmpRange.Shading.BackgroundPatternColorIndex=colorIndex;

    tmpRange.Start=length('BOOKMARKS MATCHES ');
    tmpRange.End=tmpRange.Start+length('SECTIONS');
    colorIndex=itemTypeToColorIndex('section');
    tmpRange.Shading.BackgroundPatternColorIndex=colorIndex;
    fontIndex=Microsoft.Office.Interop.Word.WdColor.wdColorWhite;
    tmpRange.Font.Color=fontIndex;

    tmpRange.Start=length('BOOKMARKS MATCHES SECTIONS ');
    tmpRange.End=tmpRange.Start+length('PARENTS');
    colorIndex=itemTypeToColorIndex('parent');
    tmpRange.Shading.BackgroundPatternColorIndex=colorIndex;

    tmpRange.Start=length('BOOKMARKS MATCHES SECTIONS PARENTS ');
    tmpRange.End=tmpRange.Start+length('OTHER');
    colorIndex=itemTypeToColorIndex('skip');
    tmpRange.Shading.BackgroundPatternColorIndex=colorIndex;
end

function[colorIndex,highlightLabel]=itemTypeToColorIndex(type)
    switch type
    case 'bookmark'
        colorIndex=Microsoft.Office.Interop.Word.WdColorIndex.wdYellow;
        highlightLabel=true;
    case 'parent'
        colorIndex=Microsoft.Office.Interop.Word.WdColorIndex.wdTurquoise;
        highlightLabel=false;
    case 'match'
        colorIndex=Microsoft.Office.Interop.Word.WdColorIndex.wdBrightGreen;
        highlightLabel=true;
    case 'section'
        colorIndex=Microsoft.Office.Interop.Word.WdColorIndex.wdViolet;
        highlightLabel=false;
    otherwise

        colorIndex=Microsoft.Office.Interop.Word.WdColorIndex.wdGray25;
        highlightLabel=false;
    end
end