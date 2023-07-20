function table=getHTMLFcnInfoTableView(obj)



    ccm=obj.Data;
    fcns={ccm.FcnInfo.Name};
    n=length(fcns);
    col1=cell(n,1);
    col2=cell(n,1);
    col3=cell(n,1);
    col4=cell(n,1);
    col5=cell(n,1);
    col6=cell(n,1);
    col7=cell(n,1);
    option.HasHeaderRow=false;
    option.HasBorder=false;
    for i=1:length(fcns)
        fcnInfo=ccm.FcnInfo(i);
        if~isempty(fcnInfo.Caller)
            ttbl=Advisor.Table(length(fcnInfo.Caller),1);
            ttbl.setBorder(0);
            ttbl.setAttribute('width','100%');
            ttbl.setAttribute('cellpadding','1');
            ttbl.setAttribute('cellspacing','0');
            for j=1:length(fcnInfo.Caller)
                fcn=fcnInfo.Caller(j).Name;
                fcnlink=obj.getFcnNameWithHyperlink(fcn);
                child=fcnInfo.Name;
                nCalled=fcnInfo.Caller(j).Weight;
                textFcn=obj.addNumOfCalls(fcnlink,child,fcn,nCalled);
                ttbl.setEntry(j,1,textFcn);
            end
            col2{i}=ttbl.emitHTML;
        else
            col2{i}='';
        end
        if fcnInfo.HasDefinition
            col1{i}=obj.getFcnNameWithHyperlink(fcnInfo.Name);
            col5{i}=int2str(fcnInfo.NumCodeLines);
            col6{i}=int2str(fcnInfo.NumTotalLines);
            col7{i}=int2str(fcnInfo.Complexity);
            col3{i}=int2str(fcnInfo.StackTotal);
            if ismember(fcnInfo.Idx,ccm.RecursiveFcnIdx)
                col3{i}=sprintf(obj.msgs.recursion_tooltip,[col3{i},'*']);
            end
            col4{i}=int2str(fcnInfo.Stack);
        else
            col1{i}=fcnInfo.Name;
            col3{i}=obj.msgs.missing_def;
            col4{i}='-';
            col5{i}='-';
            col6{i}='-';
            col7{i}='-';
        end
    end
    [~,I]=sort(fcns);
    col1=col1(I);
    col2=col2(I);
    col3=col3(I);
    col4=col4(I);
    col5=col5(I);
    col6=col6(I);
    col7=col7(I);
    col3=strrep(col3,'-1',['<i>',obj.msgs.recursion_msg,'</i>']);
    option.HasHeaderRow=true;
    option.HasBorder=true;
    table=obj.createTable({[{obj.msgs.fcn_name_header1};col1],[{obj.msgs.fcn_calledby_header};col2],[{obj.msgs.tStack_header};col3],[{obj.msgs.stack_header};col4],[obj.msgs.loc_header;col5],[obj.msgs.lines_header;col6],[obj.msgs.complexity_header;col7]},option,[2,2,1,1,1,1,1],{'left','left','right','right','right','right','right'});
    table.setAttribute('class','treeTable');
    table.setAttribute('id','fcnTableView');
end


