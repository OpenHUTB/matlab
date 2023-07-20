function out=execute(this,dXML,varargin)





    if builtin('_license_checkout','Simulink_Requirements','quiet')
        out=dXML.createComment(getString(message('Slvnv:reqmgt:licenseCheckoutFailed')));
        return;
    end

    [oName,sid]=RptgenRMI.mllinkMgr('getCurrent');

    switch this.TitleType
    case 'none'
        tTitle='';
    case 'name'
        tTitle=oName;
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

    allData=rmiml.getReqTableData(sid);
    totalBookmarks=size(allData,1);

    outerTable=cell(totalBookmarks+1,2);
    if details_level>0
        colWid=[8,12];
    else
        colWid=[10,10];
    end
    outerTable{1,1}=getString(message('Slvnv:RptgenRMI:ReqTable:execute:LinkedCode'));
    outerTable{1,2}=getString(message('Slvnv:RptgenRMI:ReqTable:execute:ReqData'));

    for i=1:totalBookmarks
        [outerTable{i+1,1},outerTable{i+1,2}]=makeTableRow(dXML,allData(i,:),sid,...
        filters,include_keywords,details_level,useDocIds,...
        this.isDescription,this.isDoc,this.isId,adSL.ReportedDocs);
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

function[leftCell,rightCell]=makeTableRow(dXML,data,sid,...
    filters,include_keywords,details_level,useDocIds,...
    isDescription,isDoc,isID,reportedDocs)


    leftCell=dXML.createElement('simplelist');
    leftCell.setAttribute('type','vert');
    leftCell.setAttribute('rows','2');

    id=data{1};

    if rmipref('ReportLinkToObjects')

        codeLinkCmd=['rmicodenavigate(''',sid,''',''',id,''');'];
        if rmipref('ReportNavUseMatlab')
            navUrl=rmiut.cmdToUrl(codeLinkCmd,false);
        else
            navUrl=['matlab:',codeLinkCmd];
        end
        linkToEditor=dXML.makeLink(navUrl,getString(message('Slvnv:rmiml:ShowInEditor')),'ulink');
        leftCell.appendChild(dXML.createElement('member',linkToEditor));
    end








    if rptgen.use_java
        codeElement=com.mathworks.widgets.CodeAsXML.xmlize(java(dXML),data{3});
    else
        codeElement=rptgen.internal.docbook.CodeAsXML.xmlize(dXML.Document,data{3});
    end

    leftCell.appendChild(dXML.createElement('member',codeElement));


    if~isDescription&&~isDoc&&~isID
        rightCell=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoRequirementsInfoColumnsSelected')));
        return;
    end


    reqs=rmiml.getReqs(sid,id);
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


    if exist(sid,'file')==2
        srcRoot=fileparts(sid);
    else
        srcRoot=strtok(sid,':');
    end
    reqTable=RptgenRMI.reqsToTable(reqs,dXML,true,...
    isDescription,isDoc,isID,...
    include_keywords,details_level,useDocIds,srcRoot,reportedDocs);

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

