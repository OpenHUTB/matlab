function yn=confirmCleanup(reqDoc,mwSource,countUnmatched)




    yn=slreq.internal.TempFlags.getInstance.get('BacklinksCleanupViaAPI');
    if~isempty(yn)
        return;
    end


    mwSourceName=slreq.uri.getShortNameExt(mwSource);

    response=questdlg({...
    getString(message('Slvnv:slreq_backlinks:FoundNUnmatchedLinksFromTo',num2str(countUnmatched),reqDoc,mwSourceName,mwSourceName,reqDoc)),...
    '',...
    getString(message('Slvnv:slreq_backlinks:DeleteTheseLinksQuest',reqDoc))},...
    getString(message('Slvnv:slreq_backlinks:BacklinksCleanupTitle')),...
    getString(message('Slvnv:slreq_backlinks:Delete')),...
    getString(message('Slvnv:slreq_backlinks:Keep')),...
    getString(message('Slvnv:slreq_backlinks:Keep')));
    yn=~isempty(response)&&strcmp(response,getString(message('Slvnv:slreq_backlinks:Delete')));

end
