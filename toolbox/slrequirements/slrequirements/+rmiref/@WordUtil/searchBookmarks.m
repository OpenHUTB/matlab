function found=searchBookmarks(comDocument,namedItem)
    if comDocument.Bookmarks.Exists(namedItem)
        comDocument.Bookmarks.Item(namedItem).Select;
        found=true;
    else
        found=false;
    end
end
