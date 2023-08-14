function makeFcnDetTable(~,d,out,emlFcn,fId,functionDetails,rootFcnId)








    tableArray=cell(3,2);

    tableArray{1,1}=...
    strcat(getString(message('RptgenSL:csl_emlfcn:functionName')),':');
    tableArray{1,2}=functionDetails.fcnName;

    tableArray{2,1}=...
    strcat(getString(message('RptgenSL:csl_emlfcn:functionId')),':');
    tableArray{2,2}=fId;

    tableArray{3,1}=...
    strcat(getString(message('RptgenSL:csl_emlfcn:fileNameOrPath')),':');
    tableArray{3,2}=functionDetails.scrPath;

    tm=d.makeNodeTable(tableArray,0,true);


    if fId==rootFcnId
        tm.setTitle([emlFcn.name,' '...
        ,getString(message('RptgenSL:csl_emlfcn:symbolData'))]);
    end

    tm.setBorder(false);
    tm.setPageWide(true);
    tm.setNumHeadRows(0);
    tm.setNumFootRows(0);
    tm.setColWidths([1,4]);

    out.appendChild(tm.createTable());

end

