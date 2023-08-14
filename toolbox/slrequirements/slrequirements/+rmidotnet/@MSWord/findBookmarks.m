function bookmarkInfo=findBookmarks(this,bookmarkId)

    if isempty(this.bookmarks)||~this.hDoc.Saved||~this.matchTimestamp()
        this.refresh();
        this.bookmarks=findBookmarksInDoc(this.hDoc);
    end

    if nargin<2

        bookmarkInfo=this.bookmarks;
    elseif~isempty(this.bookmarks)

        matchIdx=strcmp({this.bookmarks.id},bookmarkId);
        if isempty(matchIdx)
            bookmarkInfo=[];
        else
            bookmarkInfo=this.bookmarks(matchIdx);
        end
    else

        bookmarkInfo=[];
    end

end

function bookmarks=findBookmarksInDoc(wordDocObj)
    bookmarks=[];
    hBookmarks=wordDocObj.Bookmarks;
    for i=1:hBookmarks.Count
        bookmark=hBookmarks.Item(i);
        bookmarkData.id=char(bookmark.Name);
        bookmarkData.range=[bookmark.Range.Start,bookmark.Range.End];
        bookmarkData.doc=wordDocObj.FullName;
        if isempty(bookmarks)
            bookmarks=bookmarkData;
        else
            bookmarks(end+1)=bookmarkData;%#ok<AGROW>
        end
    end
end
