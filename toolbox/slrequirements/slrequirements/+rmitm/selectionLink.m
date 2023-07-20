function result=selectionLink(reqsys,testFile,testId)













    linkType=rmi.linktype_mgr('resolveByRegName',reqsys);
    if isempty(linkType)
        error(message('Slvnv:rmitm:IsInvalidDomainName',reqsys));
    end
    if isempty(linkType.SelectionLinkFcn)
        error(message('Slvnv:rmitm:NoSupportForSelectionLinking',reqsys));
    end

    make2way=rmipref('BiDirectionalLinking');

    result=feval(linkType.SelectionLinkFcn,[testFile,'|',testId],make2way);
    if iscell(result)


        req=result{1};
    else

        req=result;
    end

    if~isempty(req)
        src=struct('artifact',testFile,'id',testId,'domain','linktype_rmi_testmgr');
        [~,ext]=rmitm.getFilePath(testFile);
        if strcmp(ext,'.m')






            src.id=rmiml.RmiMUnitData.getBookmarkForTest(testFile,testId);
            src.domain='linktype_rmi_matlab';
        end

        slreq.internal.catLinks(src,req);

        if strcmp(ext,'.m')



            rmiml.notifyEditor(testFile,src.id);
        end
    end
end


