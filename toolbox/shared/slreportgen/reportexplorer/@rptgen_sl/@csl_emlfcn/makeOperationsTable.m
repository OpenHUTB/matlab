function makeOperationsTable(this,d,out,s)








    elem=...
    d.createElement('para',...
    getString(message('RptgenSL:csl_emlfcn:operationsTableName')));
    pi=createProcessingInstruction(d,'db2dom','style-name="Heading 2"');
    appendChild(elem,pi);
    appendChild(out,elem);

    nArgs=numel(s);
    nProps=length(this.OperationsTableProps);
    tableArray=cell(nArgs+1,nProps);

    for iProp=1:nProps
        tableArray{1,iProp}=this.OperationsTableColHeaders(iProp);
    end

    for iArg=1:nArgs

        if isa(s(iArg).dataType,'eml.MxInfo')

            dataType='other';
        elseif all(s(iArg).size==1)

            dataType=s(iArg).dataType;
        else

            dataType=[s(iArg).dataType,' [',int2str(s(iArg).size),']'];
        end


        tableArray{iArg+1,1}=s(iArg).name;
        tableArray{iArg+1,2}=dataType;
        tableArray{iArg+1,3}=s(iArg).position;
    end

    tm=d.makeNodeTable(tableArray,0,true);

    tm.setBorder(true);
    tm.setGroupAlign('left');
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    tm.setColWidths([2,2,2]);

    out.appendChild(tm.createTable());

end

