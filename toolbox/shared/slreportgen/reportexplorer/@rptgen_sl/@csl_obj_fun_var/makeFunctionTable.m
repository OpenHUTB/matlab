function out=makeFunctionTable(c,fnList,d)




    if isempty(fnList)
        out='';
        c.status('No functions found',2);
        return;
    end

    varTable=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:functionNameLabel'))};fnList(:,1)];
    cWid=1;

    if c.FunctionTableParentBlock
        varTable(:,end+1)=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:parentBlocksLabel'))};fnList(:,2)];
        cWid=[cWid,4];
    end

    if c.FunctionTableCallingString
        varTable(:,end+1)=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:callingStringLabel'))};fnList(:,3)];
        cWid=[cWid,2];
    end

    tm=makeNodeTable(d,...
    varTable,0,logical(1));

    if strcmp(c.FunctionTableTitleType,'auto')
        currContext=getContextType(rptgen_sl.appdata_sl,c,logical(0));
        if isempty(currContext)|strcmpi(currContext,'none')
            tTitle=getString(message('RptgenSL:rsl_csl_obj_fun_var:allFunctionsLabel'));
        else
            tTitle=sprintf(getString(message('RptgenSL:rsl_csl_obj_fun_var:functionsMsg')),currContext);
        end
    else
        tTitle=rptgen.parseExpressionText(c.FunctionTableTitle);
    end

    tm.setTitle(tTitle);
    tm.setColWidths(cWid);
    tm.setBorder(c.isBorder);
    tm.setNumHeadRows(1);

    out=tm.createTable;