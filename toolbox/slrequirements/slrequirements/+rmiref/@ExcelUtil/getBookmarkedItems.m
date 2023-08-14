function contents=getBookmarkedItems(doc,varargin)

    utilObj=rmiref.ExcelUtil.docUtilObj(doc);
    myBookmarks=utilObj.hBookmarks;

    if length(varargin)==1
        oneBookmark=varargin{1};
        contents=cell(1,3);
    else
        oneBookmark='';
        contents=cell(myBookmarks.Count,3);
    end

    for i=1:myBookmarks.Count
        hBookmark=myBookmarks.Item(i);
        bookmarkName=hBookmark.Name;
        if isempty(oneBookmark)
            hRange=hBookmark.RefersToRange;
            contents{i,1}=getBookmarkLabel(bookmarkName,hRange);
            contents{i,2}=hRange.Address;
            [contents{i,3},contents{i,4}]=utilObj.getContentForBookmark(hBookmark);
        elseif strcmp(bookmarkName,oneBookmark)
            hRange=hBookmark.RefersToRange;
            contents{1,1}=getBookmarkLabel(bookmarkName,hRange);
            contents{1,2}=hRange.Address;
            [contents{1,3},contents{1,4}]=utilObj.getContentForBookmark(hBookmark);
            return;
        else
            continue;
        end
    end
end

function label=getBookmarkLabel(bookmarkName,bookmarkRange)
    text=bookmarkRange.Rows.Item(1).Cells.Item(1).Text;
    if length(text)>44
        label=[bookmarkName,' (',text(1:22),'...)'];
    else
        label=[bookmarkName,' (',text,')'];
    end
end
