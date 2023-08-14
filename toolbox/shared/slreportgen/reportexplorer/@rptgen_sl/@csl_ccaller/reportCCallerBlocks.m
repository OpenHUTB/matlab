function out=reportCCallerBlocks(this,d,out)





    context=getContextObject(rptgen_sl.appdata_sl);
    if isempty(context)
        this.status(getString(message('RptgenSL:csl_ccaller:runCmpnContextErrorNotInLoop',this.getName())),1);
        return;
    end


    contextHandle=slreportgen.utils.getSlSfHandle(context);


    cCallerBlocks=find_system(contextHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'type','block','blocktype','CCaller');

    nBlks=numel(cCallerBlocks);
    for i=1:nBlks
        cCaller=cCallerBlocks(i);
        name=mlreportgen.utils.normalizeString(getfullname(cCaller));

        locAddFunctionName(d,out,name,"FunctionName",...
        getString(message('RptgenSL:csl_ccaller:functionNameTag')))


        if this.includeAvailableFunctions
            locAddAvailableFunctions(d,out,name,"AvailableFunctions",...
            getString(message('RptgenSL:csl_ccaller:availableFunctionsTag')),...
            this.availableFunctionsListType);
        end


        if this.includeFcnProps
            this.makeFcnPropsTable(d,out,cCaller);
        end

        this.makePortSpecificationTable(d,out,cCaller);


        if this.includeCode
            locAddCode(d,out,cCaller,...
            getString(message('RptgenSL:csl_ccaller:codeLabel')));
        end
    end

end

function locAddFunctionName(d,out,blkName,param,tag)
    functionName=deblank(get_param(blkName,param));
    if~isempty(functionName)

        elem=d.createElement('emphasis',[blkName,' ',tag]);
        elem.setAttribute('role','bold');
        elem=d.createElement('para',elem);
        out.appendChild(elem);


        nameElem=d.createElement('para',functionName);
        out.appendChild(nameElem);
    end
end

function locAddAvailableFunctions(d,out,blkName,param,tag,availableFunctionsListType)
    availableFunctions=deblank(get_param(blkName,param));
    currentFunctionName=deblank(get_param(blkName,"FunctionName"));
    availableFunctions(ismember(availableFunctions,currentFunctionName))=[];
    if~isempty(availableFunctions)

        elem=d.createElement('emphasis',[blkName,' ',tag]);
        elem.setAttribute('role','bold');
        elem=d.createElement('para',elem);
        out.appendChild(elem);


        if(availableFunctionsListType==1)
            listElem=d.createElement('itemizedlist');
        else
            listElem=d.createElement('orderedlist');
        end
        for listIdx=1:numel(availableFunctions)
            listElem.appendChild(d.createElement('listitem',availableFunctions(listIdx)));
        end
        out.appendChild(listElem);
    end
end

function locAddCode(d,out,blkHandle,codeLabel)
    blkName=mlreportgen.utils.normalizeString(getfullname(blkHandle));
    script=slreportgen.report.CCaller.getCCallerCode(blkHandle);
    if script~=""

        elem=d.createElement('emphasis',[blkName,' ',codeLabel]);
        elem.setAttribute('role','bold');
        elem=d.createElement('para',elem);
        out.appendChild(elem);


        codeElem=d.createElement('programlisting',script);
        out.appendChild(codeElem);
    end
end