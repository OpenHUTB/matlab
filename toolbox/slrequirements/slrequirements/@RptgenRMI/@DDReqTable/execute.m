function out=execute(this,dXML,varargin)





    if builtin('_license_checkout','Simulink_Requirements','quiet')
        out=dXML.createComment(getString(message('Slvnv:reqmgt:licenseCheckoutFailed')));
        return;
    end

    [dName,dPath]=RptgenRMI.mllinkMgr('getCurrent');

    switch this.TitleType
    case 'none'
        tTitle='';
    case 'name'
        tTitle=dName;
    case 'manual'
        tTitle=rptgen.parseExpressionText(this.TableTitle);
    otherwise
        error(message('Slvnv:RptgenRMI:execute:InvalidTitleType'));
    end


    filters=rmi.settings_mgr('get','filterSettings');
    if RptgenRMI.option('includeTags')
        include_keywords=true;
    else
        include_keywords=this.isKeyword;
    end
    details_level=RptgenRMI.option('detailsLevel');
    adSL=rptgen_sl.appdata_sl;
    if strcmp(adSL.ReportedDocsUseIDs,'on')
        useDocIds=true;
    else
        useDocIds=false;
    end

    linkedEntries=rmimap.getNodeIds(dPath,true);
    totalItems=length(linkedEntries);

    outerTable=cell(totalItems+1,2);
    if details_level>0
        colWid=[5,15];
        if ispc
            rmiut.msOfficeApps('cache');
        end
    else
        colWid=[7,13];
    end
    outerTable{1,1}=getString(message('Slvnv:RptgenRMI:ReqTable:execute:LinkedData'));
    outerTable{1,2}=getString(message('Slvnv:RptgenRMI:ReqTable:execute:ReqData'));

    if totalItems>0
        myConnection=Simulink.dd.open(dPath);
        for i=1:totalItems
            [outerTable{i+1,1},outerTable{i+1,2}]=makeTableRow(...
            dXML,myConnection,linkedEntries{i},dPath,...
            filters,include_keywords,details_level,useDocIds,...
            this.isDescription,this.isDoc,this.isId,adSL.ReportedDocs);
        end
        myConnection.close();
    end

    if ispc&&details_level>0
        rmiut.msOfficeApps('restore');
    end

    tm=makeNodeTable(dXML,outerTable,0,true);
    tm.setColWidths(colWid);
    tm.setTitle(tTitle);
    tm.setBorder(true);
    tm.setPageWide(false);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    out=tm.createTable;
end

function[leftCell,rightCell]=makeTableRow(dXML,myConnection,id,dPath,...
    filters,include_keywords,details_level,useDocIds,...
    isDescription,isDoc,isID,reportedDocs)

    leftCell=makeSourceCell(dXML,myConnection,dPath,id);


    if~isDescription&&~isDoc&&~isID
        rightCell=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoRequirementsInfoColumnsSelected')));
        return;
    end


    reqs=slreq.getReqs(dPath,id,'linktype_rmi_data');
    if~isempty(reqs)
        deleteIdx=~[reqs.linked];
        if any(deleteIdx)
            reqs(deleteIdx)=[];
        end
    end
    if isempty(reqs)
        rightCell=getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoRequirementsFound'));
        return;
    end
    if filters.enabled
        reqs=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExclude);
        if isempty(reqs)
            rightCell=getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoLinksMatchedFilter'));
            return;
        end
    end


    reqTable=RptgenRMI.reqsToTable(reqs,dXML,true,...
    isDescription,isDoc,isID,...
    include_keywords,details_level,useDocIds,dPath,reportedDocs);

    numCols=size(reqTable,2);


    tm=makeNodeTable(dXML,reqTable,0,true);
    if numCols==3
        if details_level>0
            tm.setColWidths([1,13,7]);
        else
            tm.setColWidths([1,10,10]);
        end
    else
        tm.setColWidths([1,20]);
    end
    tm.setBorder(false);
    tm.setPageWide(true);
    tm.setNumHeadRows(0);
    tm.setNumFootRows(0);
    rightCell=tm.createTable;
end

function srcCell=makeSourceCell(dXML,myConnection,dPath,id)


    entryPath=rmide.getEntryPath(myConnection,id);


    if rmipref('ReportLinkToObjects')

        ddLinkCmd=['rmiobjnavigate(''',dPath,''',''',id,''');'];
        if rmipref('ReportNavUseMatlab')
            navUrl=rmiut.cmdToUrl(ddLinkCmd,false);
        else
            navUrl=['matlab:',ddLinkCmd];
        end
        srcCell=dXML.makeLink(navUrl,entryPath,'ulink');
    else
        srcCell=entryPath;
    end
end

