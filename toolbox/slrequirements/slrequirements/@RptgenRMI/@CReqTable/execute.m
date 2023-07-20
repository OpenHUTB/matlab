function out=execute(this,dXML,varargin)





    adSL=rptgen_sl.appdata_sl;


    if builtin('_license_checkout','Simulink_Requirements','quiet')
        out=dXML.createComment(getString(message('Slvnv:reqmgt:licenseCheckoutFailed')));
        return;
    end

    modelName=adSL.CurrentModel;

    groupIndex=0;
    switch this.Source
    case 'simulink'
        [theObj,currContext]=getContextObject(adSL);
        if isempty(theObj)
            out=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoCurrentSimulinkObject')));
            return
        end

        if strcmp(currContext,'SignalGroup')
            at=strfind(theObj,'@');
            if~isempty(at)
                groupIndex=sscanf(theObj(1:(at(1)-1)),'%d');
                theObj=theObj((at(1)+1):end);
            end
        end

        oName=getObjectName(rptgen_sl.propsrc_sl,theObj,currContext);
        theObj=get_param(theObj,'Handle');
        isSf=false;
    case 'stateflow'
        adSF=rptgen_sf.appdata_sf;
        theObj=adSF.CurrentObject;
        if isempty(theObj)
            out=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoCurrentStateflowObject')));
            return;
        end
        oName=getObjectName(rptgen_sf.propsrc_sf,theObj);
        theObj=get(theObj,'ID');
        isSf=true;
    otherwise
        error(message('Slvnv:RptgenRMI:execute:InvalidSource'));
    end

    switch this.TitleType
    case 'none'
        tTitle='';
    case 'name'
        if~groupIndex
            tTitle=oName;
        else
            adh=rptgen_hg.appdata_hg;
            tTitle=[oName,' : ',adh.CurrentName,' ',getString(message('Slvnv:RptgenRMI:ReqTable:execute:SignalRequirements'))];
        end
    case 'manual'
        tTitle=rptgen.parseExpressionText(this.TableTitle);
    otherwise
        error(message('Slvnv:RptgenRMI:execute:InvalidTitleType'));
    end


    if~this.isDescription&&~this.isDoc&&~this.isID
        out=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoRequirementsInfoColumnsSelected')));
        return;
    end

    filters=rmi.settings_mgr('get','filterSettings');
    try
        if groupIndex>0

            objReqs=rmi('get',theObj,groupIndex);
        elseif~isSf&&strcmp(get_param(theObj,'type'),'block_diagram')

            objReqs=rmi('get',theObj);
        elseif~isSf&&strcmp(get_param(theObj,'StaticLinkStatus'),'resolved')



            myLibSubsys=get_param(theObj,'ReferenceBlock');
            objReqs=rmi('get',myLibSubsys);
        else

            objReqs=rmi('get',theObj);
        end
        if~isempty(objReqs)
            deleteIdx=~[objReqs.linked];
            if any(deleteIdx)
                objReqs(deleteIdx)=[];
            end
        end
        if~isempty(objReqs)&&filters.enabled
            objReqs=rmi.filterTags(objReqs,filters.tagsRequire,filters.tagsExclude);
        end
    catch Mex %#ok<NASGU>
        objReqs=[];
    end

    if isempty(objReqs)
        out=dXML.createComment(getString(message('Slvnv:RptgenRMI:ReqTable:execute:NoRequirementsFound')));
        return;
    end


    if RptgenRMI.option('toolsReqReport')&&RptgenRMI.option('includeTags')
        include_keywords=true;
    else
        include_keywords=this.isKeyword;
    end

    details_level=RptgenRMI.option('detailsLevel');

    if strcmp(adSL.ReportedDocsUseIDs,'on')
        useDocIds=true;
    else
        useDocIds=false;
    end


    isSlreq=strcmp({objReqs.reqsys},'linktype_rmi_slreq');
    if any(isSlreq)
        for idx=find(isSlreq)
            if~isempty(regexp(objReqs(idx).description,'^link #\d+$'))
                objReqs(idx).description=slreq.internal.getReqItemSummary(objReqs(idx));
            end
        end
    end


    theTable=RptgenRMI.reqsToTable(objReqs,dXML,false,...
    this.isDescription,this.isDoc,this.isID,...
    include_keywords,details_level,useDocIds,modelName,adSL.ReportedDocs);


    headerRow={getString(message('Slvnv:RptgenRMI:ReqTable:execute:LinkNumber'))};
    if this.isDescription
        headerRow=[headerRow,getString(message('Slvnv:RptgenRMI:ReqTable:execute:Description'))];
    end
    if this.isDoc||this.isID
        if this.isDoc&&this.isID
            headerRow=[headerRow,getString(message('Slvnv:RptgenRMI:ReqTable:execute:TargetNameAndLocationID'))];
        elseif this.isDoc
            headerRow=[headerRow,getString(message('Slvnv:RptgenRMI:ReqTable:execute:Document'))];
        else
            headerRow=[headerRow,getString(message('Slvnv:RptgenRMI:ReqTable:execute:LocationID'))];
        end
    end
    theTable=[headerRow;theTable];


    tm=makeNodeTable(dXML,theTable,0,true);
    if size(theTable,2)==3
        if details_level>0
            tm.setColWidths([1,13,7]);
        else
            tm.setColWidths([1,10,10]);
        end
    else
        tm.setColWidths([1,20]);
    end
    tm.setTitle(tTitle);
    tm.setBorder(true);
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    out=tm.createTable;
end

