function out=reportCFcnBlocks(this,d,out)





    context=getContextObject(rptgen_sl.appdata_sl);
    if isempty(context)
        this.status(getString(message('RptgenSL:csl_cfcn:runCmpnContextErrorNotInLoop',this.getName())),1);
        return;
    end


    contextHandle=slreportgen.utils.getSlSfHandle(context);


    cFcns=find_system(contextHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'type','block','blocktype','CFunction');

    nFcns=numel(cFcns);
    for i=1:nFcns
        cFcn=cFcns(i);
        name=mlreportgen.utils.normalizeString(getfullname(cFcn));


        if this.includeFcnProps
            this.makeFcnPropsTable(d,out,cFcn);
        end


        if this.includeSymbolsTable
            this.makeSymbolsTable(d,out,cFcn);
        end


        if this.includeOutputCode
            locAddCodeSection(d,out,name,"OutputCode",...
            getString(message('RptgenSL:csl_cfcn:outputCodeTag')));
        end


        if this.includeStartCode
            locAddCodeSection(d,out,name,"StartCode",...
            getString(message('RptgenSL:csl_cfcn:startCodeTag')));
        end


        if this.includeInitializeConditionsCode
            locAddCodeSection(d,out,name,"InitializeConditionsCode",...
            getString(message('RptgenSL:csl_cfcn:initConditionsCodeTag')));
        end


        if this.includeTerminateCode
            locAddCodeSection(d,out,name,"TerminateCode",...
            getString(message('RptgenSL:csl_cfcn:terminateCodeTag')));
        end

    end

end

function locAddCodeSection(d,out,blkName,codeParam,codeTag)
    code=get_param(blkName,codeParam);
    if~isempty(code)

        elem=d.createElement('emphasis',[blkName,' ',codeTag]);
        elem.setAttribute('role','bold');
        elem=d.createElement('para',elem);
        out.appendChild(elem);


        codeElem=d.createElement('programlisting',code);
        out.appendChild(codeElem);
    end
end