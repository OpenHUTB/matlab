function[table,row,fcnVisited,myTotal]=getSubFcnTable(obj,fcn,lvl,metrics,groupId,row,fcnVisited,ignoreChild,nodePosition,bRptLOC)
    ccm=obj.Data;
    if~ccm.FcnInfoMap.isKey(fcn)
        return
    end
    if isempty(fcnVisited)
        isRootFcn=true;
        bVisited=false;
    else
        isRootFcn=false;
        bVisited=ismember(fcn,fcnVisited);
    end
    fcnlink=obj.getFcnNameWithHyperlink(fcn);
    textFcn=fcnlink;
    switch metrics
    case 'Data Copy'
        self=ccm.FcnInfoMap(fcn).DataCopy;
    case 'Stack Size'
        self=ccm.FcnInfoMap(fcn).Stack;
    end
    sloc=ccm.FcnInfoMap(fcn).NumCodeLines;
    tsloc=ccm.FcnInfoMap(fcn).NumTotalLines;
    complexity=ccm.FcnInfoMap(fcn).Complexity;
    id=obj.getUniqueID();
    if isempty(ccm.FcnInfoMap(fcn).Callee)||ignoreChild
        children={};
        weight=[];
    else
        callee=ccm.FcnInfoMap(fcn).Callee;

        children={callee.Name};
        weight=[callee.Weight];




    end

    if~isempty(children)

        accum_metrs=zeros(size(children));
        for i=1:length(children)
            switch metrics
            case 'Data Copy'
                num=ccm.FcnInfoMap(children{i}).DataCopyTotal;
            case 'Stack Size'
                num=ccm.FcnInfoMap(children{i}).StackTotal;
            end
            accum_metrs(i)=num;
        end

        [~,tf]=sort(accum_metrs,'descend');
        children=children(tf);
        weight=weight(tf);
        option.UseSymbol=true;
        option.ShowByDefault=true;
        option.tooltip=obj.msgs.shrink_button_tooltip;
        button=rtw.report.Report.getRTWTableShrinkButton(id,option);
    else
        prefix='&#160;&#160;';
        button=['&#160;<span style="font-family:monospace">',prefix,'</span>&#160;'];
    end
    indent='';
    indent(1:lvl*6)=' ';
    indent=strrep(indent,' ','&#160;');
    indent=[indent,button];
    if isRootFcn
        col1=['<b>',textFcn,'</b>'];
    else
        col1=textFcn;
    end
    col1={['<span style="white-space:nowrap">',indent,'&#160;',col1,'</span>']};
    option.HasHeaderRow=false;
    option.HasBorder=false;
    if mod(row,2)
        option.BeginWithWhiteBG=false;
    else
        option.BeginWithWhiteBG=true;
    end
    row=row+1;
    table=Advisor.Table(1+length(children),1);
    if lvl>0
        table.setAttribute('style','display: none; border-style: none');
    else
        table.setAttribute('style','border-style: none');
    end
    fcnVisited=[fcnVisited,fcn];
    table.setBorder(0);
    table.setAttribute('width','100%');
    table.setAttribute('cellpadding','0');
    table.setAttribute('cellspacing','0');
    table.setAttribute('name',groupId);
    table.setAttribute('id',groupId);
    myTotal=self;
    nSum=0;
    nMax=0;
    for i=1:length(children)
        nCalled=weight(i);
        bIgnore=ismember(children{i},fcnVisited);
        [subTable,row,~,cTotal]=obj.getSubFcnTable(children{i},lvl+1,metrics,id,row,fcnVisited,bIgnore,nodePosition,bRptLOC);
        if~bIgnore
            nSum=nSum+nCalled*cTotal;
            if cTotal>nMax
                nMax=cTotal;
            end
        end
        table.setEntry(i+1,1,subTable.emitHTML);
    end
    switch metrics
    case 'Data Copy'
        myTotal=max(myTotal+nSum,ccm.FcnInfoMap(fcn).DataCopyTotal);
    case 'Stack Size'
        myTotal=max(myTotal+nMax,ccm.FcnInfoMap(fcn).StackTotal);
    end


    if ccm.FcnInfoMap(fcn).HasDefinition
        col3=loc_int2str(self);
        col4=loc_int2str(sloc);
        col5=loc_int2str(tsloc);
        col6=loc_int2str(complexity);
        if bVisited


            myTotal=0;
            col2={['<i>',obj.msgs.recursion_msg,'</i>']};
        else
            col2=loc_int2str(myTotal);
            if ismember(ccm.FcnInfoMap(fcn).Idx,ccm.RecursiveFcnIdx)
                col2{1}=sprintf(obj.msgs.recursion_tooltip,[col2{1},'*']);
            end
        end


        fcnInfo=ccm.FcnInfoMap(fcn);
        switch metrics
        case 'Data Copy'
            fcnInfo.DataCopyTotal=myTotal;
        case 'Stack Size'
            fcnInfo.StackTotal=myTotal;
        end
        ccm.FcnInfoMap(fcn)=fcnInfo;
    else
        col2={obj.msgs.missing_def};
        col3={'-'};
        col4={'-'};
        col5={'-'};
        col6={'-'};
    end
    if bRptLOC
        entryTable=obj.createTable({col1,col2,col3,col4,col5,col6},option,[3,1,1,1,1,1],{'left','right','right','right','right','right'});
    else
        entryTable=obj.createTable({col1,col2,col3},option,[3,1,1],{'left','right','right'});
    end
    table.setEntry(1,1,entryTable.emitHTML);
end
