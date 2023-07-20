

function fcnTable=getHTMLFcnInfo(obj)
    ccm=obj.Data;
    bRptLOC=true;


    savedFcnInfoMap=ccm.FcnInfoMap;
    stack_table=obj.getHTMLMemoryMetrics('Stack Size',bRptLOC);
    fcnInfo_table=obj.getHTMLFcnInfoTableView();
    ccm.FcnInfoMap=savedFcnInfoMap;

    tblFormat='fcnInfo_table';
    treeFormat='fcnInfo_calltree';
    tbl_view=Advisor.Table(2,1);
    link=Advisor.Element;
    link.setContent(obj.msgs.call_tree_msg);
    link.setTag('a');
    link.setAttribute('href',['javascript:if (rtwSwitchView) rtwSwitchView(window.document,''',tblFormat,''', ''',treeFormat,''')']);
    link.setAttribute('title',obj.msgs.switch2tree);
    tbl_view.setEntry(1,1,[obj.msgs.view_msg,' ',link.emitHTML,' | ',obj.msgs.table_msg]);
    tbl_view.setEntry(2,1,fcnInfo_table.emitHTML);
    tbl_view.setBorder(0);
    tbl_view.setAttribute('width','100%');
    tbl_view.setAttribute('cellpadding','0');
    tbl_view.setAttribute('cellspacing','0');
    tbl_view.setAttribute('name',tblFormat);
    tbl_view.setAttribute('id',tblFormat);
    tbl_view.setAttribute('style','display: none');
    link=Advisor.Element;
    link.setContent(obj.msgs.table_msg);
    link.setTag('a');
    link.setAttribute('href',['javascript:if (rtwSwitchView) rtwSwitchView(window.document,''',treeFormat,''', ''',tblFormat,''')']);
    link.setAttribute('title',obj.msgs.switch2table);
    tree_view=Advisor.Table(2,1);
    tree_view.setEntry(1,1,[obj.msgs.view_msg,obj.msgs.call_tree_msg,' | ',link.emitHTML]);
    tree_view.setEntry(2,1,stack_table.emitHTML);
    tree_view.setBorder(0);
    tree_view.setAttribute('width','100%');
    tree_view.setAttribute('cellpadding','0');
    tree_view.setAttribute('cellspacing','0');
    tree_view.setAttribute('name',treeFormat);
    tree_view.setAttribute('id',treeFormat);
    if isempty(ccm.RecursiveFcnIdx)
        fcnTable=Advisor.Table(2,1);
    else
        fcnTable=Advisor.Table(3,1);
        fcnTable.setEntry(3,1,obj.msgs.recursion_footnote);
    end
    fcnTable.setEntry(1,1,tree_view.emitHTML);
    fcnTable.setEntry(2,1,tbl_view.emitHTML);
    fcnTable.setBorder(0);
    fcnTable.setAttribute('width','100%');
    fcnTable.setAttribute('cellpadding','0');
    fcnTable.setAttribute('cellspacing','0');
end
