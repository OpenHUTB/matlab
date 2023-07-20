function makeConstDataSymTable(~,d,sect,constDataSym,compileStatus)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:constant')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);

    nProps=4;
    tableArray=cell(length(constDataSym)+1,nProps);


    tableArray{1,1}=...
    getString(message('RptgenSL:rstm_cstm_testseq:dataName'));
    tableArray{1,2}=...
    getString(message('RptgenSL:rstm_cstm_testseq:value'));
    if compileStatus
        tableArray{1,3}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataType'));
        tableArray{1,4}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSize'));
    else
        tableArray{1,3}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataTypeFootRef'));
        tableArray{1,4}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSizeFootRef'));
    end



    if length(constDataSym)>1
        nList=cellfun(@(x)x.Name,constDataSym,'UniformOutput',false);
        [~,sortIdx]=sort(nList);
        constDataSym=constDataSym(sortIdx);
    end


    nConstDataSym=numel(constDataSym);
    for iArg=1:nConstDataSym
        tableArray{iArg+1,1}=constDataSym{iArg}.Name;
        tableArray{iArg+1,2}=constDataSym{iArg}.Value;
        tableArray{iArg+1,3}=constDataSym{iArg}.DataType;
        tableArray{iArg+1,4}=constDataSym{iArg}.Size;
    end

    tm=d.makeNodeTable(tableArray,0,true);
    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    sect.appendChild(tm.createTable());
end