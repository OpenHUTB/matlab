function caseId=setReqs(varargin)




    [fPath,caseId]=rmitm.resolve(varargin{:});


    src=struct('artifact',fPath,'id',caseId,'domain','linktype_rmi_testmgr');
    [~,ext]=rmitm.getFilePath(fPath);
    if strcmp(ext,'.m')






        src.id=rmiml.RmiMUnitData.getBookmarkForTest(fPath,caseId);
        src.domain='linktype_rmi_matlab';
    end

    reqs=varargin{end};
    slreq.internal.setLinks(src,reqs);



    rmitm.UpdateNotifier.notifyReqUpdate(fPath,caseId);

    if strcmp(ext,'.m')



        rmiml.notifyEditor(fPath,src.id);
    end
end


