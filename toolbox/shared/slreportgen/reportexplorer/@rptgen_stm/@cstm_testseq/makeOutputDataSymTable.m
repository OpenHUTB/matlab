function makeOutputDataSymTable(~,d,sect,outputDataSym,compileStatus)






    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:output')));
    para=createElement(d,'para',elem);
    appendChild(sect,para);

    nProps=5;
    tableArray=cell(length(outputDataSym)+1,nProps);


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


    if length(outputDataSym)>1
        nList=cellfun(@(x)x.Port,outputDataSym);
        [~,sortIdx]=sort(nList);
        outputDataSym=outputDataSym(sortIdx);
    end


    nOutputDataSym=numel(outputDataSym);
    for iArg=1:nOutputDataSym
        tableArray{iArg+1,1}=outputDataSym{iArg}.Port;
        tableArray{iArg+1,2}=outputDataSym{iArg}.Name;
        tableArray{iArg+1,3}=getString(message(['RptgenSL:rstm_cstm_testseq:dataClass',outputDataSym{iArg}.Class]));
        tableArray{iArg+1,4}=outputDataSym{iArg}.DataType;
        tableArray{iArg+1,5}=outputDataSym{iArg}.Size;
    end

    tm=d.makeNodeTable(tableArray,0,true);
    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    sect.appendChild(tm.createTable());
end
