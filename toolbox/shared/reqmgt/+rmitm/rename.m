function newReq=rename(oldTestFile,newTestFile)




    oldTestFile=convertStringsToChars(oldTestFile);
    newTestFile=convertStringsToChars(newTestFile);

    newReq='';


    linkSet=slreq.utils.getLinkSet(oldTestFile);
    if~isempty(linkSet)
        linkSet.moveArtifact(newTestFile);
        linkSet.save();
        newReq=linkSet.filepath;
    end
end

