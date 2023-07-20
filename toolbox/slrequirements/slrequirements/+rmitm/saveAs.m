function newReq=saveAs(srcTestFile,destTestFile)




    srcTestFile=convertStringsToChars(srcTestFile);
    destTestFile=convertStringsToChars(destTestFile);

    newReq='';

    srcPath=rmitm.getFilePath(srcTestFile);
    dstPath=rmitm.getFilePath(destTestFile);

    if slreq.hasData(srcPath)
        slreq.utils.renameLinkSet(srcPath,dstPath);

        slreq.saveLinks(dstPath);
        newReq=slreq.getLinkFilePath(dstPath);
    end
end
