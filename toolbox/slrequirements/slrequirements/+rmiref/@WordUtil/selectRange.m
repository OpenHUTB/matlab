function selectRange(hWord,hDoc,location)
    switch location(1)
    case '#'
        pageNum=str2double(location(2:end));
        range=hDoc.GoTo(1,1,pageNum);
        range.Select;
        findId=0;
    case '@'
        rmiref.WordUtil.findNamedItem(hWord,hDoc,location(2:end))
        findId=0;

    case '?'
        locationStr=location(2:end);
        findId=1;

    otherwise
        findId=1;
    end
    if findId==1
        hWord.Selection.Start=0;hWord.Selection.End=0;
        hWord.Selection.Find.Text=locationStr;
        hWord.Selection.Find.Execute;
    end
end
