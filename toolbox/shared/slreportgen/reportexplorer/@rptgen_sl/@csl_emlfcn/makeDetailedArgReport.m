function makeDetailedArgReport(this,d,out,hEMLUDD)







    args=hEMLUDD.find('-isa','Stateflow.Data');

    nArgs=length(args);

    if nArgs>0
        title=d.createElement('emphasis',[hEMLUDD.Name,' ',getString(message('RptgenSL:csl_emlfcn:functionArguments'))]);
        title.setAttribute('role','bold');
        title=d.createElement('para',title);
        out.appendChild(title);
    end


    for iArg=1:nArgs

        nProps=length(this.ArgPropNames);
        tableArray=cell(nProps+1,2);

        tableArray{1,1}=...
        rptgen.parseExpressionText(this.ArgPropTablePropColHeader);
        tableArray{1,2}=...
        rptgen.parseExpressionText(this.ArgPropTableValueColHeader);


        context=get(rptgen_sf.appdata_sf,'CurrentObject');
        if isempty(context)
            context=getContextObject(rptgen_sl.appdata_sl);
        else
            context=context.Path;
        end
        context=get_param(context,"Handle");

        for iProp=1:nProps
            propName=this.ArgPropNames{iProp};
            tableArray{iProp+1,1}=propName;
            tableArray{iProp+1,2}=...
            this.getArgPropertyValue(args(iArg),propName,context);
        end

        tm=d.makeNodeTable(tableArray,0,true);

        if strcmp(this.FcnPropsTableTitleType,'auto')
            tm.setTitle([args(iArg).Name,' ',getString(message('RptgenSL:csl_emlfcn:argumentProperties'))]);
        else
            tm.setTitle(rptgen.parseExpressionText(this.FcnPropsTableTitle));
        end

        tm.setBorder(this.hasBorderArgPropTable);
        tm.setPageWide(this.spansPageArgPropTable);
        tm.setNumHeadRows(1);
        tm.setNumFootRows(0);
        tm.setColWidths([this.ArgPropTablePropColWidth...
        ,this.ArgPropTableValueColWidth]);

        out.appendChild(tm.createTable());

    end


end




