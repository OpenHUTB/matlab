function makePortSpecificationTable(this,d,out,cCaller)






    blkName=mlreportgen.utils.normalizeString(getfullname(cCaller));


    props={getString(message("Simulink:CustomCode:PortSpec_ArgName")),...
    getString(message("Simulink:CustomCode:PortSpec_Scope")),...
    getString(message("Simulink:CustomCode:PortSpec_Label")),...
    getString(message("Simulink:CustomCode:PortSpec_Type")),...
    getString(message("Simulink:CustomCode:PortSpec_Size")),...
    getString(message("Simulink:CustomCode:PortSpec_Index"))};


    portSpec=get_param(cCaller,"FunctionPortSpecification");
    portSpec=[portSpec.ReturnArgument,portSpec.InputArguments,portSpec.GlobalArguments];
    nPortSpecification=numel(portSpec);
    nProps=numel(props);
    tableArray=cell(nPortSpecification+1,nProps);

    for iProp=1:nProps
        tableArray{1,iProp}=props(iProp);
    end


    for psIdx=1:nPortSpecification
        currSym=portSpec(psIdx);

        tableArray{psIdx+1,1}=currSym.Name;
        tableArray{psIdx+1,2}=currSym.Scope;
        tableArray{psIdx+1,4}=currSym.Type;
        tableArray{psIdx+1,5}=currSym.Size;




        switch currSym.Scope
        case "Constant"
            tableArray{psIdx+1,3}=currSym.Label;
            tableArray{psIdx+1,6}="-";
        otherwise
            tableArray{psIdx+1,3}=currSym.Label;
            tableArray{psIdx+1,6}=currSym.PortNumber;
        end

    end


    tm=d.makeNodeTable(tableArray,0,true);


    tm.setBorder(this.hasBorderPortSpecificationTable);
    tm.setPageWide(this.spansPagePortSpecificationTable);
    tm.setGroupAlign(this.PortSpecificationTableAlign);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);


    if strcmp(this.PortSpecificationTableTitleType,'auto')
        tm.setTitle([blkName,' ',getString(message('RptgenSL:csl_ccaller:portSpecificationTableName'))]);
    else
        tm.setTitle(rptgen.parseExpressionText(this.PortSpecificationTableTitle));
    end

    out.appendChild(tm.createTable());

end

