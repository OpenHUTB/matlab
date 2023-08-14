function makeInputDataSymTable(~,d,sect,inputDataSym,compileStatus)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:input')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);

    nProps=5;
    tableArray=cell(length(inputDataSym)+1,nProps);


    tableArray{1,1}=...
    getString(message('RptgenSL:rstm_cstm_testseq:dataPort'));
    tableArray{1,2}=...
    getString(message('RptgenSL:rstm_cstm_testseq:dataName'));
    tableArray{1,3}=...
    getString(message('RptgenSL:rstm_cstm_testseq:dataClass'));
    if compileStatus
        tableArray{1,4}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataType'));
        tableArray{1,5}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSize'));
    else
        tableArray{1,4}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataTypeFootRef'));
        tableArray{1,5}=...
        getString(message('RptgenSL:rstm_cstm_testseq:dataSizeFootRef'));
    end


    if length(inputDataSym)>1
        nList=cellfun(@(x)x.Port,inputDataSym);
        [~,sortIdx]=sort(nList);
        inputDataSym=inputDataSym(sortIdx);
    end


    nInputDataSym=numel(inputDataSym);
    for iArg=1:nInputDataSym
        tableArray{iArg+1,1}=inputDataSym{iArg}.Port;
        tableArray{iArg+1,2}=inputDataSym{iArg}.Name;
        tableArray{iArg+1,3}=getString(message(['RptgenSL:rstm_cstm_testseq:dataClass',inputDataSym{iArg}.Class]));
        tableArray{iArg+1,4}=inputDataSym{iArg}.DataType;
        tableArray{iArg+1,5}=inputDataSym{iArg}.Size;
    end

    tm=d.makeNodeTable(tableArray,0,true);
    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    sect.appendChild(tm.createTable());
end
