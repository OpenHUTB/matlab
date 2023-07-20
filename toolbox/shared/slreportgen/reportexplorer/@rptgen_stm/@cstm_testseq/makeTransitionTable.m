function makeTransitionTable(this,d,sect,state)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:tranistionTableTitle')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);


    transitions=getStateTransitions(this,state);
    nTransitions=length(transitions);
    nProps=2;
    tableArray=cell(nTransitions+1,nProps);


    tableArray{1,1}=...
    getString(message('RptgenSL:rstm_cstm_testseq:condition'));
    tableArray{1,2}=...
    getString(message('RptgenSL:rstm_cstm_testseq:nextStep'));


    for iArg=1:nTransitions
        if~isempty(transitions{iArg}.cond)
            tableArray{iArg+1,1}=transitions{iArg}.cond;
        else

            emptyCondition=createElement(d,'emphasis','true');
            tableArray{iArg+1,1}=emptyCondition;
        end
        tableArray{iArg+1,2}=transitions{iArg}.dest;
    end

    tm=d.makeNodeTable(tableArray,0,true);
    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    tm.setColWidths([2,2]);

    sect.appendChild(tm.createTable());
end