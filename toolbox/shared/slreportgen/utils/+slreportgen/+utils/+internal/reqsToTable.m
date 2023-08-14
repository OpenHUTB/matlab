function table=reqsToTable(reqs)

























    table=[];
    nReqs=length(reqs);
    if nReqs<1||~rmi.isInstalled()
        return;
    end


    import mlreportgen.dom.*
    table=FormalTable();


    headerRow=append(table.Header,TableRow());


    append(headerRow,...
    TableHeaderEntry(getString(message('Slvnv:RptgenRMI:ReqTable:execute:LinkNumber'))));


    append(headerRow,...
    TableHeaderEntry(getString(message('Slvnv:RptgenRMI:ReqTable:execute:Description'))));


    append(headerRow,...
    TableHeaderEntry(getString(message('Slvnv:RptgenRMI:ReqTable:execute:Document'))));


    for i=1:nReqs

        req=reqs(i);


        contentRow=append(table,TableRow());


        append(contentRow,TableEntry(strcat(num2str(i),".")));


        append(contentRow,TableEntry(req.description));



        linkType=rmi.linktype_mgr('resolveByRegName',req.reqsys);
        if isempty(linkType)
            [~,~,dExt]=fileparts(req.doc);
            linkType=rmi.linktype_mgr('resolve',req.reqsys,dExt);
        end

        docURL=rmi.reqToUrl(req,[],rmipref('ReportNavUseMatlab'),linkType);
        label=RptgenRMI.rptToReqLabel(linkType,req,true,true);

        docEntry=append(contentRow,TableEntry);
        append(docEntry,ExternalLink(docURL,label));
    end
end