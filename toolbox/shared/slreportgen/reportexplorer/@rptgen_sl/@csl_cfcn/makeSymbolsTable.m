function makeSymbolsTable(this,d,out,cFcn)





    blkName=mlreportgen.utils.normalizeString(getfullname(cFcn));


    props={getString(message("Simulink:CustomCode:PortSpec_ArgName")),...
    getString(message("Simulink:CustomCode:PortSpec_Scope")),...
    getString(message("Simulink:CustomCode:PortSpec_Label")),...
    getString(message("Simulink:CustomCode:PortSpec_Type")),...
    getString(message("Simulink:CustomCode:PortSpec_Size")),...
    getString(message("Simulink:CustomCode:PortSpec_Index"))};


    symbolSpec=get_param(cFcn,"SymbolSpec");
    symbolSpec=symbolSpec.Symbols;
    nSymbols=numel(symbolSpec);
    nProps=numel(props);
    tableArray=cell(nSymbols+1,nProps);

    for iProp=1:nProps
        tableArray{1,iProp}=props(iProp);
    end


    for symIdx=1:nSymbols
        currSym=symbolSpec(symIdx);

        tableArray{symIdx+1,1}=currSym.Name;
        tableArray{symIdx+1,2}=currSym.Scope;
        tableArray{symIdx+1,4}=currSym.Type;
        tableArray{symIdx+1,5}=currSym.Size;




        switch currSym.Scope
        case "Persistent"
            tableArray{symIdx+1,3}="-";
            tableArray{symIdx+1,6}="-";
        case "Constant"
            tableArray{symIdx+1,3}=currSym.Label;
            tableArray{symIdx+1,6}="-";
        otherwise
            tableArray{symIdx+1,3}=currSym.Label;
            tableArray{symIdx+1,6}=currSym.PortNumber;
        end

    end


    tm=d.makeNodeTable(tableArray,0,true);


    tm.setBorder(this.hasBorderSymbolsTable);
    tm.setPageWide(this.spansPageSymbolsTable);
    tm.setGroupAlign(this.SymbolsTableAlign);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);


    if strcmp(this.SymbolsTableTitleType,'auto')
        tm.setTitle([blkName,' ',getString(message('RptgenSL:csl_cfcn:symbolsTableName'))]);
    else
        tm.setTitle(rptgen.parseExpressionText(this.SymbolsTableTitle));
    end

    out.appendChild(tm.createTable());

end

