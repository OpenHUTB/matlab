function makeArgSummaryTable(this,d,out,emlFcn)











    args=emlFcn.find('-isa','Stateflow.Data');

    nArgs=length(args);

    if(nArgs<1)

        return
    end

    nProps=length(this.ArgSummTableProps);

    tableArray=cell(nArgs+1,nProps);

    for iProp=1:nProps
        tableArray{1,iProp}=this.ArgSummTableColHeaders(iProp);
    end


    context=get(rptgen_sf.appdata_sf,'CurrentObject');
    if isempty(context)
        context=getContextObject(rptgen_sl.appdata_sl);
    else
        context=context.Path;
    end
    context=get_param(context,"Handle");

    for iArg=1:nArgs
        for iProp=1:nProps
            tableArray{iArg+1,iProp}=...
            this.getArgPropertyValue(args(iArg),this.ArgSummTableProps{iProp},context);
        end
    end


    tm=d.makeNodeTable(tableArray,0,true);

    if strcmp(this.ArgSummTableTitleType,'auto')
        tm.setTitle([emlFcn.name,' ',getString(message('RptgenSL:csl_emlfcn:argumentSummary'))]);
    else
        tm.setTitle(rptgen.parseExpressionText(this.ArgSummTableTitle));
    end

    tm.setBorder(this.hasBorderArgSummTable);
    tm.setGroupAlign(this.ArgSummTableAlign);
    tm.setPageWide(this.spansPageArgSummTable);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);


    tm.setColWidths(this.ArgSummTableColWidths);

    out.appendChild(tm.createTable());


end




