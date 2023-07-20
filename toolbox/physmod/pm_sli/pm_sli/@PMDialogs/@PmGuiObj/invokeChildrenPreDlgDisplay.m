function dlgInfo=invokeChildrenPreDlgDisplay(hThis,dlgInfo)











    nItems=length(hThis.Items);
    for idx=1:nItems
        dlgInfo=hThis.Items(idx).PreDlgDisplay(dlgInfo);
    end
end
