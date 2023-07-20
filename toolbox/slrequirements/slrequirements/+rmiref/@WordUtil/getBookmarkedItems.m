function contents=getBookmarkedItems(doc,varargin)

    utilObj=rmiref.WordUtil.docUtilObj(doc);
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
            contents{i,1}=getBookmarkLabel(hBookmark);
            contents{i,2}=utilObj.getParagraphIdx(hBookmark.Range);
            [contents{i,3},contents{i,4}]=utilObj.getContentForBookmark(hBookmark);
        elseif strcmp(bookmarkName,oneBookmark)
            contents{1,1}=getBookmarkLabel(hBookmark);
            contents{1,2}=utilObj.getParagraphIdx(hBookmark.Range);
            [contents{1,3},contents{1,4}]=utilObj.getContentForBookmark(hBookmark);
            return;
        else
            continue;
        end
    end
end

function label=getBookmarkLabel(hBookmark)
    text=hBookmark.Range.Text;
    if length(text)>44
        label=[hBookmark.Name,' (',text(1:22),'...)'];
    else
        label=[hBookmark.Name,' (',text,')'];
    end
end

