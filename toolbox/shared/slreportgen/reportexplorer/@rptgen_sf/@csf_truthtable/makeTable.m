function tableContainer=makeTable(this,d)





    cInfo=rptgen_sf.csf_truthtable.makeConditionCells(this,d);
    aInfo=rptgen_sf.csf_truthtable.makeActionCells(this,d);

    switch this.TitleMode
    case 'none'
        tTitle='';
    case 'auto'
        if isa(this.RuntimeTruthTable.Chart,'Stateflow.TruthTableChart')
            tTitle=this.RuntimeTruthTable.Path;
        else
            tTitle=this.RuntimeTruthTable.Name;
        end
    otherwise
        tTitle=rptgen.parseExpressionText(this.Title);
    end


    tableContainer=d.createDocumentFragment();

    tm=makeNodeTable(d,cInfo{1},0,true);
    tm.setTitle(tTitle);
    tm.setColWidths(cInfo{2});
    tm.setNumHeadRows(0+this.showConditionHeader);
    conditionTable=tm.createTable;
    tableContainer.appendChild(conditionTable);

    for i=3:2:size(cInfo,2)


        tm=makeNodeTable(d,cInfo{i},0,true);
        tm.setTitle('');
        tm.setColWidths(cInfo{i+1});
        tm.setNumHeadRows(0+this.showConditionHeader);
        conditionTableContinuation=tm.createTable;
        tableContainer.appendChild(conditionTableContinuation);
    end



    if~isempty(aInfo{1})
        tm=makeNodeTable(d,aInfo{1},0,true);
        tm.setTitle('');
        tm.setColWidths(aInfo{2});
        tm.setNumHeadRows(0+this.showActionHeader);
        actionTable=tm.createTable;
        tableContainer.appendChild(actionTable);
    end