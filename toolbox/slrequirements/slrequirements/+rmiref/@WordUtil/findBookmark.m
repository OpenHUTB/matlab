function[docTxt,bookMarkId]=findBookmark(shapeRange)





    myBookmarks=shapeRange.Bookmarks;
    bookMark=[];
    found=myBookmarks.Count;
    if found==1
        bookMark=myBookmarks.Item(1);
    elseif found==0














        shapeRange.StartOf(3,1);
        myBookmarks=shapeRange.Bookmarks;
        if myBookmarks.Count==1
            bookMark=myBookmarks.Item(1);
        end
    else
        bookMark=myBookmarks.Item(found);
    end

    if~isempty(bookMark)
        bookMarkId=bookMark.Name;
        docTxt=bookMark.Range.Text;
    else
        txt=regexprep(shapeRange.Text,char(1),'');
        if~isempty(txt)
            docTxt=txt;
        else
            docTxt='NO BOOKMARK near this Simulink reference';
        end
    end

end
