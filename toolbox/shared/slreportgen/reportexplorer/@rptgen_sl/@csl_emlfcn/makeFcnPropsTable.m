function makeFcnPropsTable(this,d,out,emlFcn)






    if isa(emlFcn,'Stateflow.EMChart')
        tableArray=cell(8,2);

        tableArray{1,1}=...
        rptgen.parseExpressionText(this.FcnPropsTablePropColHeader);
        tableArray{1,2}=...
        rptgen.parseExpressionText(this.FcnPropsTableValueColHeader);

        tableArray{2,1}=getString(message('RptgenSL:csl_emlfcn:updateMethod'));
        tableArray{2,2}=emlFcn.ChartUpdate;

        tableArray{3,1}=getString(message('RptgenSL:csl_emlfcn:sampleTime'));
        tableArray{3,2}=emlFcn.SampleTime;

        tableArray{4,1}=getString(message('RptgenSL:csl_emlfcn:variableArraySupport'));
        tableArray{4,2}=emlFcn.SupportVariableSizing;

        tableArray{5,1}=getString(message('RptgenSL:csl_emlfcn:satOnIntOverflow'));
        tableArray{5,2}=emlFcn.SaturateOnIntegerOverflow;

        tableArray{6,1}=getString(message('RptgenSL:csl_emlfcn:treatSignalAsFI'));
        tableArray{6,2}=emlFcn.TreatAsFi;

        tableArray{7,1}=getString(message('RptgenSL:csl_emlfcn:embedFIMath'));
        tableArray{7,2}=emlFcn.EmlDefaultFimath;

        tableArray{8,1}=getString(message('RptgenSL:csl_emlfcn:inputFIMath'));
        tableArray{8,2}=emlFcn.InputFimath;

        tableArray{9,1}=getString(message('RptgenSL:csl_emlfcn:description'));
        tableArray{9,2}=emlFcn.Description;
    else
        tableArray=cell(5,2);

        tableArray{1,1}=...
        rptgen.parseExpressionText(this.FcnPropsTablePropColHeader);
        tableArray{1,2}=...
        rptgen.parseExpressionText(this.FcnPropsTableValueColHeader);

        tableArray{2,1}=getString(message('RptgenSL:csl_emlfcn:satOnIntOverflow'));
        tableArray{2,2}=emlFcn.SaturateOnIntegerOverflow;

        tableArray{3,1}=getString(message('RptgenSL:csl_emlfcn:embedFIMath'));
        tableArray{3,2}=emlFcn.EmlDefaultFimath;

        tableArray{4,1}=getString(message('RptgenSL:csl_emlfcn:inputFIMath'));
        tableArray{4,2}=emlFcn.InputFimath;

        tableArray{5,1}=getString(message('RptgenSL:csl_emlfcn:description'));
        tableArray{5,2}=emlFcn.Description;
    end

    tm=d.makeNodeTable(tableArray,0,true);

    if strcmp(this.FcnPropsTableTitleType,'auto')
        tm.setTitle([emlFcn.name,' ',getString(message('RptgenSL:csl_emlfcn:functionPropertiesLabel'))]);
    else
        tm.setTitle(rptgen.parseExpressionText(this.FcnPropsTableTitle));
    end

    tm.setBorder(this.hasBorderFcnPropTable);
    tm.setPageWide(this.spansPageFcnPropTable);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    tm.setColWidths([this.FcnPropsTablePropColWidth,...
    this.FcnPropsTableValueColWidth]);

    out.appendChild(tm.createTable());

end




