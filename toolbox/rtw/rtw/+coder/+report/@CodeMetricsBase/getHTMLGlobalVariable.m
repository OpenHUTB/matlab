function out=getHTMLGlobalVariable(obj)



    isForNewReport=obj.isSLReportV2;
    ccm=obj.Data;
    vars={ccm.GlobalVarInfo.Name};
    sizes=[ccm.GlobalVarInfo.Size];
    bitFlags=[ccm.GlobalVarInfo.IsBitField];
    files={ccm.GlobalVarInfo.File};
    useCounts=[ccm.GlobalVarInfo.UseCount];
    useCountInFcns=zeros(size(useCounts));
    for i=1:length(ccm.GlobalVarInfo)
        if~isempty(ccm.GlobalVarInfo(i).UseInFunctions)
            useCountInFcns(i)=max([ccm.GlobalVarInfo(i).UseInFunctions.UseCount]);
        end
    end
    members={ccm.GlobalVarInfo.Members};
    id_var='globalvarInfo_table';
    if ccm.hasKnownStat
        mdlRefVarList={ccm.KnownStat.GlobalVarInfo.Name};
        mdlRefVarSizes=[ccm.KnownStat.GlobalVarInfo.Size];
        mdlRefVarBitFlags=[ccm.KnownStat.GlobalVarInfo.IsBitField];
        mdlRefFiles={ccm.KnownStat.GlobalVarInfo.File};
        mdlRefuseCounts=[ccm.KnownStat.GlobalVarInfo.UseCount];
        mdlRefuseCountInFcns=zeros(size(mdlRefuseCounts));
        for i=1:length(ccm.KnownStat.GlobalVarInfo)
            if~isempty(ccm.KnownStat.GlobalVarInfo(i).UseInFunctions)
                mdlRefuseCountInFcns(i)=max([ccm.KnownStat.GlobalVarInfo(i).UseInFunctions.UseCount]);
            end
        end
        mdlRefMembers={ccm.KnownStat.GlobalVarInfo.Members};
    else
        mdlRefVarList={};
        mdlRefVarSizes=[];
        mdlRefVarBitFlags=[];
        mdlRefFiles=[];
        mdlRefuseCounts=[];
        mdlRefuseCountInFcns=[];
        mdlRefMembers={};
    end
    [mdlRefVars,tf]=setdiff(mdlRefVarList,vars);
    varCol=[vars,mdlRefVars];
    sizes=[sizes,mdlRefVarSizes(tf)];
    bitFlags=[bitFlags,mdlRefVarBitFlags(tf)];
    files=[files,mdlRefFiles(tf)];
    useCounts=[useCounts,mdlRefuseCounts(tf)];
    useCountInFcns=[useCountInFcns,mdlRefuseCountInFcns(tf)];
    members=[members,mdlRefMembers(tf)];
    mdlref_name=cell(length(varCol),1);

    for i=1:length(vars)
        title='';
        if ccm.GlobalVarInfo(i).IsStatic
            var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(ccm.GlobalVarInfo(i).Name);
            [~,file,ext]=fileparts(ccm.GlobalVarInfo(i).File{1});
            title=sprintf(obj.msgs.staticGlobalVar_tooltip,var,[file,ext]);
        else
            var=vars{i};
        end
        aElement=Advisor.Element;
        aElement.setTag('span');
        aElement.setContent(var);
        if~isempty(title)
            aElement.setAttribute('title',title);
        end
        if obj.getGenHyperlinkFlag
            if~isForNewReport


                fullFileName=files{i};
                htmlfilename=obj.getLinkToFile(fullFileName);

                if~obj.htmlfileExistMap.isKey(htmlfilename)
                    obj.htmlfileExistMap(htmlfilename)=exist(htmlfilename,'file');
                end
                if obj.forceGenHyperlinkToSource||obj.htmlfileExistMap(htmlfilename)
                    aElement.setTag('a');
                    aElement.setAttribute('href',[htmlfilename,'#var_',var]);
                    aElement.setAttribute('class','code2code');
                end
            else


                aElement.setTag('a');
                aElement.setAttribute('href','javascript: void(0)');
                aElement.setAttribute('onclick',coder.report.internal.getPostParentWindowMessageCall('jumpToCode',var));
            end
        end
        varCol{i}=aElement.emitHTML;
        mdlref_name{i}=' ';
    end

    for i=1:length(mdlRefVars)
        [~,loc]=ismember(mdlRefVars{i},mdlRefVarList);
        varInfo=ccm.KnownStat.GlobalVarInfo(loc);
        refMdlName=varInfo.MdlRef;
        title='';
        if varInfo.IsStatic
            var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(varInfo.Name);
            [~,file,ext]=fileparts(varInfo.File{1});
            title=sprintf(obj.msgs.staticGlobalVar_tooltip,var,[file,ext]);
        else
            var=varInfo.Name;
        end
        aElement=Advisor.Element;
        aElement.setTag('span');
        aElement.setContent(var);
        if~isempty(title)
            aElement.setAttribute('title',title);
        end
        varCol{i+length(vars)}=aElement.emitHTML;
        if obj.getGenHyperlinkFlag()&&exist(ccm.mdlRefInfo(refMdlName),'dir')
            aElement=Advisor.Element;
            aElement.setContent(refMdlName);
            aElement.setTag('a');
            aElement.setAttribute('target','_top');
            if isForNewReport
                href_value=coder.internal.coderReport('getDestHTMLFileName',fullfile(ccm.mdlRefInfo(refMdlName),'_internal.html'),ccm.BuildDir);
                newUrl=href_value{1};

                aElement.setAttribute('href','javascript: void(0)');
                callBackString=sprintf('postParentWindowMessage({message:''%s'', url:''%s'', modelName:''%s''})',...
                'jumpToReport',newUrl,refMdlName);
                aElement.setAttribute('onclick',callBackString);
            else
                href_value=coder.internal.coderReport('getDestHTMLFileName',fullfile(ccm.mdlRefInfo(refMdlName),[refMdlName,'_codegen_rpt.html']),ccm.BuildDir);
                aElement.setAttribute('href',href_value{1});
            end
            aElement.setAttribute('class','extern');
            aElement.setAttribute('name','external_link');
            mdlref_name{i+length(vars)}=aElement.emitHTML;
        else
            mdlref_name{i+length(vars)}=refMdlName;
        end
    end

    [sizes,I]=sort(sizes,'descend');
    bitFlags=bitFlags(I);
    varCol=varCol(I);
    mdlref_name=mdlref_name(I);
    useCounts=useCounts(I);
    useCountInFcns=useCountInFcns(I);
    members=members(I);
    tables=Advisor.Table(2+length(varCol),1);
    tables.setAttribute('class','treeTable');
    tables.setBorder(0);
    tables.setAttribute('width','100%');
    tables.setAttribute('cellpadding','0');
    tables.setAttribute('cellspacing','0');
    option.HasHeaderRow=true;
    option.HasBorder=false;

    col1={obj.msgs.global_var_header};
    col2={obj.msgs.var_size_header};
    col3={obj.msgs.var_usecount_header};
    col4={obj.msgs.var_usecountinfcn_header};
    hasMdlRefVars=~isempty(mdlRefVars);
    if hasMdlRefVars
        col5={obj.msgs.mdlref_header};
        contents={col1,col2,col3,col4,col5};
        colWidthsInPercent=[3,1,1,1,2];
        colAlignment={'left','right','right','right','right'};
    else
        contents={col1,col2,col3,col4};
        colWidthsInPercent=[3,2,2,2];
        colAlignment={'left','right','right','right'};
    end
    entryTable=obj.createTable(contents,option,colWidthsInPercent,colAlignment);
    tables.setEntry(1,1,entryTable.emitHTML);
    rowNumber=2;
    for i=1:length(varCol)
        if mod(rowNumber,2)
            option.BeginWithWhiteBG=false;
        else
            option.BeginWithWhiteBG=true;
        end
        rowNumber=rowNumber+1;
        if isempty(members{i})
            prefix='&#160;&#160;';
            button=['&#160;<span style="font-family:monospace">',prefix,'</span>&#160;'];
        else
            option.UseSymbol=true;
            option.ShowByDefault=true;
            option.tooltip='Click to shrink or expand tree';
            id=[id_var,'_sub',num2str(rowNumber)];
            button=rtw.report.Report.getRTWTableShrinkButton(id,option);
        end
        col1={['<span style="white-space:nowrap">',button,' ',varCol{i},'</span>']};
        col2={int2str(sizes(i))};
        for k=1:length(bitFlags)
            if bitFlags(k)
                col2{k}=[col2{k},' (',obj.msgs.bit,')'];
            end
        end
        if useCounts(i)==0
            col3={['<span title="',obj.msgs.zeroUseCount,'">0</span><span style="font-family:Courier">*</span>']};
        else
            col3={[int2str(useCounts(i)),'<span style="font-family:Courier">&#160;</span>']};
        end
        if useCountInFcns(i)==0
            col4={['<span title="',obj.msgs.zeroUseCount,'">0</span><span style="font-family:Courier">*</span>']};
        else
            col4={[int2str(useCountInFcns(i)),'<span style="font-family:Courier">&#160;</span>']};
        end
        if hasMdlRefVars
            col5=mdlref_name(i);
            contents={col1,col2,col3,col4,col5};
        else
            contents={col1,col2,col3,col4};
        end
        option.HasHeaderRow=false;
        contentTable=obj.createTable(contents,option,colWidthsInPercent,colAlignment);
        if isempty(members{i})
            tables.setEntry(i+1,1,contentTable.emitHTML);
        else
            colWidthsInPercent=colWidthsInPercent/sum(colWidthsInPercent)*100;
            [struct_table,rowNumber]=obj.getHTMLGlobvalVariableStructTable(members{i},0,id,rowNumber,hasMdlRefVars,colWidthsInPercent,colAlignment);
            tmpTable=Advisor.Table(2,1);
            tmpTable.setBorder(0);
            tmpTable.setAttribute('width','100%');
            tmpTable.setAttribute('cellpadding','0');
            tmpTable.setAttribute('cellspacing','0');
            tmpTable.setEntry(1,1,contentTable.emitHTML);
            tmpTable.setEntry(2,1,struct_table.emitHTML);
            tables.setEntry(i+1,1,tmpTable.emitHTML);
        end
    end

    col1={['<b>',obj.msgs.total,'</b>']};
    col2=strcat('<b>',loc_int2str(sum(sizes)),'</b>');
    col3=strcat('<b>',loc_int2str(sum(useCounts)),'<span style="font-family:Courier">&#160;</span></b>');
    col4={' '};
    if mod(rowNumber,2)
        option.BeginWithWhiteBG=false;
    else
        option.BeginWithWhiteBG=true;
    end
    if hasMdlRefVars
        col5={' '};
        contents={col1,col2,col3,col4,col5};
    else
        contents={col1,col2,col3,col4};
    end
    sumTable=obj.createTable(contents,option,colWidthsInPercent,colAlignment);
    tables.setEntry(2+length(varCol),1,sumTable.emitHTML);

    option.HasHeaderRow=false;
    option.HasBorder=true;
    option.BeginWithWhiteBG=true;
    globalvar_table=obj.createTable({{''}},option,1,'left');
    globalvar_table.setAttribute('cellspacing','0');
    globalvar_table.setAttribute('cellpadding','0');
    globalvar_table.setEntry(1,1,tables.emitHTML);
    globalvar_table.setAttribute('name',id_var);
    globalvar_table.setAttribute('id',id_var);
    if ismember(0,useCounts)
        out=Advisor.Table(2,1);
        out.setEntry(2,1,['* ',obj.msgs.zeroUseCount]);
        out.setEntry(1,1,globalvar_table.emitHTML);
        out.setBorder(0);
        out.setAttribute('width','100%');
        out.setAttribute('cellpadding','0');
        out.setAttribute('cellspacing','0');
    else
        out=globalvar_table;
    end
end


