function table=getHTMLMemoryMetrics(obj,metrics,bRptLOC)



    ccm=obj.Data;
    root_fcn=ccm.getCallGraphRoot();
    fcns={ccm.FcnInfo.Name};
    [~,loc]=intersect(fcns,root_fcn);

    switch metrics
    case 'Data Copy'
        dataCopyTotal=[ccm.FcnInfo.DataCopyTotal];
        dataCopyTotal=dataCopyTotal(loc);
        [~,I]=sort(dataCopyTotal,'descend');
        root_fcn=root_fcn(I);
        col2={obj.msgs.tdcopy_header};
        col3={obj.msgs.dcopy_header};
    case 'Stack Size'
        stackTotal=[ccm.FcnInfo.StackTotal];
        stackTotal=stackTotal(loc);
        [~,I]=sort(stackTotal,'descend');
        root_fcn=root_fcn(I);
        col2={obj.msgs.tStack_header};
        col3={obj.msgs.stack_header};
    end
    recursiveFcnList=fcns(ccm.RecursiveFcnIdx);
    if~isempty(recursiveFcnList)
        root_fcn=[root_fcn,setdiff(recursiveFcnList,root_fcn)];
    end
    tables=Advisor.Table(1+length(root_fcn),1);
    tables.setBorder(0);
    tables.setAttribute('width','100%');
    tables.setAttribute('cellpadding','0');
    tables.setAttribute('cellspacing','0');
    tables.setAttribute('class','treeTable');
    tables.setAttribute('id','fcnTreeView');
    option.HasHeaderRow=true;
    option.HasBorder=false;
    col1={obj.msgs.fcn_name_header};
    col4={obj.msgs.loc_header};
    col5={obj.msgs.lines_header};
    col6={obj.msgs.complexity_header};
    if bRptLOC
        entryTable=obj.createTable({col1,col2,col3,col4,col5,col6},option,[3,1,1,1,1,1],{'left','right','right','right','right','right'});
    else
        entryTable=obj.createTable({col1,col2,col3},option,[3,1,1],{'left','right','right'});
    end
    tables.setEntry(1,1,entryTable.emitHTML);
    row=0;
    for i=1:length(root_fcn)
        fcn=root_fcn{i};
        groupId='';
        fcnVisited={};
        if i==1
            nodePosition='first';
        else
            nodePosition='';
        end
        [subTable,row]=obj.getSubFcnTable(fcn,0,metrics,groupId,row,fcnVisited,false,nodePosition,bRptLOC);
        tables.setEntry(i+1,1,subTable.emitHTML);
    end
    option.HasHeaderRow=false;
    option.HasBorder=true;
    option.BeginWithWhiteBG=true;

    table=obj.createTable({{''}},option,1,'left');
    table.setAttribute('cellspacing','0');
    table.setAttribute('cellpadding','0');
    table.setEntry(1,1,tables.emitHTML);
end
