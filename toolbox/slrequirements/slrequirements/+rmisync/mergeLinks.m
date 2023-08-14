function[newReqs,newLinkStr]=mergeLinks(origReqs,syncObj,itemId,linkInfo)




    if syncObj.copyFromSrgToSl&&syncObj.copyFromSlToSrg
        error(message('Slvnv:reqmgt:mergeLinks'));

    elseif syncObj.copyFromSrgToSl
        newLinkStr='';
        newReqs=rmisync.propagateChangesToSl(origReqs,syncObj,itemId,linkInfo);
    elseif syncObj.copyFromSlToSrg
        newLinkStr=syncObj.propagateChanges(origReqs,itemId,linkInfo);
        newReqs=syncObj.updateSrgLink(origReqs,itemId);
    else
        newLinkStr='';
        newReqs=syncObj.updateSrgLink(origReqs,itemId);
    end
end
