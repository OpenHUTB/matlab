function makeSupportingFunctionsTable(this,d,out,chart,fcnData)





    fcnNames={fcnData.Name};
    fcnPaths={fcnData.Path};
    fcnTypes={fcnData.Type};

    if isempty(fcnNames)
        return;
    end


    [fcnNames,ix]=unique(fcnNames);
    fcnTypes=fcnTypes(ix);
    fcnPaths=fcnPaths(ix);

    tableArray=cell(length(fcnNames)+1,3);

    tableArray{1,1}=...
    rptgen.parseExpressionText(this.SupportFcnTableNameColHeader);

    tableArray{1,2}=...
    rptgen.parseExpressionText(this.SupportFcnTableDefinedByColHeader);

    tableArray{1,3}=...
    rptgen.parseExpressionText(this.SupportFcnTablePathColHeader);

    tableArray(2:end,1)=fcnNames;
    tableArray(2:end,2)=fcnTypes;
    tableArray(2:end,3)=fcnPaths;

    tm=d.makeNodeTable(tableArray,0,true);

    if strcmp(this.SupportFcnTableTitleType,'auto')
        tm.setTitle([chart.name,' ',getString(message('RptgenSL:csl_emlfcn:supportingFunctions'))]);
    else
        tm.setTitle(rptgen.parseExpressionText(this.SupportFcnTableTitle));
    end

    tm.setBorder(this.hasBorderSupportFcnTable);
    tm.setPageWide(this.spansPageSupportFcnTable);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    tm.setColWidths([this.SupportFcnTableNameColWidth,...
    this.SupportFcnTableDefinedByColWidth,...
    this.SupportFcnTablePathColWidth]);

    out.appendChild(tm.createTable());
end













































