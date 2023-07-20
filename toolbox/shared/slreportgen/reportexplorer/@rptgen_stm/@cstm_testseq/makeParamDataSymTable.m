function makeParamDataSymTable(~,d,sect,paramDataSym,compileStatus)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:parameter')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);

    nProps=3;
    tableArray=cell(length(paramDataSym)+1,nProps);


    tableArray{1,1}=...
    getString(message('RptgenSL:rstm_cstm_testseq:dataName'));
    if compileStatus
        tableArray{1,2}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataType'));
        tableArray{1,3}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSize'));
    else
        tableArray{1,2}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataTypeFootRef'));
        tableArray{1,3}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSizeFootRef'));
    end


    if length(paramDataSym)>1
        nList=cellfun(@(x)x.Name,paramDataSym,'UniformOutput',false);
        [~,sortIdx]=sort(nList);
        paramDataSym=paramDataSym(sortIdx);
    end


    nParamDataSym=numel(paramDataSym);
    for iArg=1:nParamDataSym
        tableArray{iArg+1,1}=paramDataSym{iArg}.Name;
        tableArray{iArg+1,2}=paramDataSym{iArg}.DataType;
        tableArray{iArg+1,3}=paramDataSym{iArg}.Size;
    end

    tm=d.makeNodeTable(tableArray,0,true);
    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    sect.appendChild(tm.createTable());
end