function n=getRequirementNode(obj,dXML,displayFields)















    if nargin<2||isempty(dXML)


        dXML=get(rptgen.appdata_rg,'CurrentDocument');
    end



    if ischar(obj)


        [obj,isRichText]=rmisl.richTextToHandle(obj);
        if isempty(obj)
            n=[];
            return;
        end
    else
        isRichText=false;
    end

    isSf=~isRichText&&strncmp(class(obj),'Stateflow.',length('Stateflow.'));













    try



        try
            if~isRichText&&~isSf&&...
                RptgenRMI.option('followLibraryLinks')&&...
                strcmp(get_param(obj,'StaticLinkStatus'),'implicit')
                objReqs=rmi.getReqs(obj,true);
            else
                objReqs=rmi.getReqs(obj);
            end
        catch

            objReqs=rmi.getReqs(obj);
        end
    catch Mex %#ok<NASGU>
        n=[];
        return;
    end

    hasMlLinks=~isRichText&&RptgenRMI.mllinkMgr('check',obj);

    if isempty(objReqs)


        if~isRichText&&~isSf&&~strcmp(obj,bdroot(obj))
            refObj=get_param(obj,'ReferenceBlock');
            if~isempty(refObj)
                if RptgenRMI.option('followLibraryLinks')
                    n=dXML.createElement('member',getString(message('Slvnv:RptgenRMI:execute:LinkedInLibraryMore')));
                else
                    n=dXML.createElement('member',getString(message('Slvnv:RptgenRMI:execute:LinkedInLibrary')));
                end
                return;
            end
        end
    else

        filters=rmi.settings_mgr('get','filterSettings');
        if filters.enabled
            objReqs=rmi.filterTags(objReqs,filters.tagsRequire,filters.tagsExclude);
        end
    end


    if isempty(objReqs)

        if hasMlLinks
            mfLink=makeLinkToMFTable(obj,dXML);
            nodeTable=cell(2,2);
            nodeTable{2,1}='+';nodeTable{2,2}=mfLink;
            nodeTable{3,1}=' ';nodeTable{3,2}=' ';
            numCols=2;
        else
            n=[];
            return;
        end

    else


        if(nargin>2&&any(strcmp(displayFields,'keywords')))||RptgenRMI.option('includeTags')
            list_keywords=true;
        else
            list_keywords=false;
        end

        reportSettings=rmi.settings_mgr('get','reportSettings');
        details_level=reportSettings.detailsLevel;


        adSL=rptgen_sl.appdata_sl;
        if strcmp(adSL.ReportedDocsUseIDs,'on')
            use_id=true;
        else
            use_id=false;
        end

        isSlreq=strcmp({objReqs.reqsys},'linktype_rmi_slreq');
        if any(isSlreq)
            for idx=find(isSlreq)
                objReqs(idx).description=slreq.internal.getReqItemSummary(objReqs(idx));
            end
        end


        nodeTable=RptgenRMI.reqsToTable(objReqs,dXML,true,...
        true,true,true,...
        list_keywords,details_level,use_id,adSL.CurrentModel,adSL.ReportedDocs);

        numCols=size(nodeTable,2);

        if hasMlLinks
            row=size(nodeTable,1)+1;
            nodeTable(row+1,:)=repmat({' '},1,numCols);
            row=row+1;
            nodeTable{row,1}='+';
            nodeTable{row,2}=makeLinkToMFTable(obj,dXML);
            if numCols>2
                nodeTable{row,3}=' ';
            end
            row=row+1;
            nodeTable(row,:)=repmat({' '},1,numCols);
        end


        if isSf
            parentId=sf('ParentOf',obj.Id);
            if sf('IsSubviewer',parentId)
                RptgenRMI.data(parentId);
            end
        end

    end

    tm=makeNodeTable(dXML,nodeTable,0,true);
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
    n=tm.createTable;
end

function mfLink=makeLinkToMFTable(obj,dXML)
    sid=Simulink.ID.getSID(obj);
    display_string=getString(message('Slvnv:RptgenRMI:execute:LinksInCode'));
    mfLink=dXML.makeLink(['#',sid],display_string,'matlab');
end

