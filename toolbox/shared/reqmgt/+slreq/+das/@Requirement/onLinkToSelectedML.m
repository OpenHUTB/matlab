function onLinkToSelectedML()
    [targetFile,targetRange,selectedText]=rmiml.getSelection();
    [targetPath,id]=rmiml.ensureBookmark(targetFile,targetRange);

    rmiml.selectionLink('linktype_rmi_slreq',targetPath,id);
end
