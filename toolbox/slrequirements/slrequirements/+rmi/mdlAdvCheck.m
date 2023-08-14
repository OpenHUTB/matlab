function[ResultDescription,ResultDetails]=mdlAdvCheck(check,system)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
    end

    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&filterSettings.filterConsistency
        filters=filterSettings;
    else
        filters=[];
    end

    switch(lower(check))
    case 'doc'
        [ResultDescription,ResultDetails]=check_doc(system,filters);
    case 'id'
        [ResultDescription,ResultDetails]=check_id(system,filters);
    case 'label'
        [ResultDescription,ResultDetails]=check_label(system,filters);
    case 'path'
        [ResultDescription,ResultDetails]=check_path(system,filters);
    end
end

function[ResultDescription,ResultDetails]=check_doc(system,filters)
    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    results=results_make_empty();

    hBlocks=rmisl.blockTable(system,'get',true);


    all_errors='';
    for i=1:length(hBlocks)
        [reqs,flags]=rmi.reqsWithFilterFlags(hBlocks(i),filters);
        for j=1:length(reqs)
            if~flags(j)
                continue;
            end
            try
                status=rmi('check',hBlocks(i),'doc',j);

                if~status&&~rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    results=results_add_req(...
                    results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,'',j);
                end
            catch Mex
                if rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    continue;
                end


                this_error=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'doc');
                if isempty(this_error)
                    this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                    results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,'',j);
                end

                if~contains(all_errors,this_error)
                    all_errors=[all_errors,'<li>',this_error,'</li>'];
                end

            end
        end
    end


    [mlCheck,all_errors]=rmisl.checkMFunctions(system,'doc',all_errors);


    if~isempty(all_errors)
        all_errors=['<p /><font color=''#cc5500''><b>',DAStudio.message('Slvnv:consistency:EncounteredErrors'),'</b><ul>',all_errors,'</ul></font><hr />'];
    end
    if results_doc_number(results)>0
        str_html=[bold('Inconsistencies:'),'<blockquote><table>'];
        for i=1:results_doc_number(results)
            hasLibLinks=false;
            thisDocBegin=length(ResultDescription)+1;
            thisDoc=results_doc(results,i);
            if rmisl.isDocBlockPath(thisDoc)
                docHeader='Slvnv:consistency:checkDocumentDocBlock';
            else
                docHeader='Slvnv:consistency:checkDocumentResults';
            end
            str_html=[...
str_html...
            ,'<tr><td colspan="5"><hr/>&nbsp;<br/>'...
            ,DAStudio.message(docHeader,bold(thisDoc),bold(DAStudio.message('Slvnv:consistency:fix')))...
            ,'</td></tr>'...
            ,empty_row(5)...
            ,tr([td(pad(bold(DAStudio.message('Slvnv:consistency:block')),2,20)),td('&nbsp;<p />')...
            ,td(pad(bold(DAStudio.message('Slvnv:consistency:requirements')),2,20)),td('&nbsp;'),td('')])...
            ];
            fix_count=0;
            for j=1:results_block_number(results,i)
                str_html=[str_html,'<tr><td>'];%#ok<*AGROW>
                open_row=['</td>',td('')];
                ResultDescription{end+1}=str_html;
                handle=results_block_handle(results,i,j);
                if is_sf_handle(handle)
                    rt=Stateflow.Root;
                    ResultDetails{end+1}={rt.idToHandle(handle)};
                else
                    ResultDetails{end+1}=handle;
                end
                str_html='';
                for k=1:results_req_number(results,i,j)
                    req_link=results_link(system,results,i,j,k);
                    [fix_cmd,label,hasLibLinks]=doc_fix_cmd(system,results,i,j,k,hasLibLinks);
                    str_html=[...
str_html...
                    ,open_row...
                    ,td(req_link)...
                    ,td('<br/><br/>')...
                    ,td(hlink(fix_cmd,label)),'</tr>'];
                    if~hasLibLinks
                        fix_count=fix_count+1;
                    end
                    open_row=['<tr>',td(''),td('')];
                end
            end
            if fix_count>1
                [fix_cmd,cnt]=doc_fix_all_cmd(system,results,i);
                if cnt>1
                    str_html=[...
str_html...
                    ,tr([td('')...
                    ,td('')...
                    ,td('')...
                    ,td('')...
                    ,'<td width="50">',hlink(fix_cmd,DAStudio.message('Slvnv:consistency:fixAll')),'</td>'])...
                    ,empty_row(4)];
                end
            end
            if hasLibLinks
                ResultDescription{thisDocBegin}=insertLibLinkMessage(ResultDescription{thisDocBegin},5);
            end
        end

        ResultDescription{end+1}=[str_html,'</table></blockquote>'];
        if~isempty(all_errors)
            ResultDescription{1}=[all_errors,'<p />',ResultDescription{1}];
        end
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'doc');
        end
        mdladvObj.setCheckResultStatus(false);

    elseif~isempty(all_errors)
        ResultDescription{end+1}=all_errors;
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'doc');
        end
        mdladvObj.setCheckResultStatus(false);

    elseif~isempty(mlCheck)
        [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'doc');
        mdladvObj.setCheckResultStatus(false);

    else
        ResultDescription{end+1}=pass_string();
        mdladvObj.setCheckResultStatus(true);
    end

    ResultDetails{end+1}=[];
end

function[ResultDescription,ResultDetails]=check_id(system,filters)
    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    results=results_make_empty();

    all_errors='';
    missing_docs='';
    modelH=bdroot(system);
    hBlocks=rmisl.blockTable(system,'get',true);
    for i=1:length(hBlocks)
        try
            [reqs,flags]=rmi.reqsWithFilterFlags(hBlocks(i),filters);
        catch mexception
            if strcmp(mexception.identifier,'Simulink:Commands:InvSimulinkObjHandle')




                rmisl.blockTable(modelH,'clear');
                hBlocks=rmisl.blockTable(system,'get',true);
                [reqs,flags]=rmi.reqsWithFilterFlags(hBlocks(i),filters);
            else
                rethrow(mexception);
            end
        end
        for j=1:length(reqs)
            if~flags(j)
                continue;
            end
            try






                if any(strcmp(reqs(j).reqsys,{'linktype_rmi_simulink','linktype_rmi_matlab'}))
                    if rmisl.isHarnessIdString(reqs(j).doc)
                        parentName=strtok(reqs(j).doc,':');
                        if strcmp(parentName,get_param(modelH,'Name'))
                            [~,objPath]=rmi.objinfo(hBlocks(i));
                            error(message('Slvnv:reqmgt:mdlAdvCheck:UnableToCheckHarnessLink',objPath,num2str(j)));
                        end
                    end
                end
                status=rmi('check',hBlocks(i),'id',j);
                if~status&&~rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,'',j);
                end
            catch Mex
                if rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    continue;
                end

                if contains(Mex.message,getString(message('Slvnv:reqmgt:getLinktype:UnregisteredExt','.mn')))
                    rmiut.warnNoBacktrace('Slvnv:reqmgt:linktype_rmi_mupad:MuPADLinkSkipped','MuPAD Notebook');
                    continue;
                end


                [this_error,missing_doc]=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'id');
                if isempty(this_error)
                    if strcmp(Mex.identifier,'Simulink:utility:invalidSID')||...
                        strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')


                        results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                        reqs(j).description,'',j);
                    else
                        this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                        results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                        reqs(j).description,'',j);
                    end
                end
                if missing_doc
                    if~contains(missing_docs,this_error)
                        missing_docs=[missing_docs,'<li>',this_error,'</li>'];
                    end
                elseif~isempty(this_error)
                    if~contains(all_errors,this_error)
                        all_errors=[all_errors,'<li>',this_error,'</li>'];
                    end
                end
            end
        end
    end


    [mlCheck,all_errors]=rmisl.checkMFunctions(system,'id',all_errors);

    if~isempty(all_errors)
        all_errors=['<p /><font color=''#cc5500''><b>',DAStudio.message('Slvnv:consistency:EncounteredErrors'),'</b><ul>',all_errors,'</ul></font><hr>'];
    end
    if~isempty(missing_docs)
        missing_docs=['<p /><font color=''#cc5500''><b>Unable to check:</b><ul>',missing_docs,'</ul></font><hr>'];
    end
    if results_doc_number(results)>0
        str_html=[bold('Inconsistencies:'),'<blockquote>'...
        ,'<table><tr><td colspan="3">'...
        ,DAStudio.message('Slvnv:consistency:checkIdResults')...
        ,'</td></tr>',empty_row(3)...
        ,tr([td(bold(DAStudio.message('Slvnv:consistency:block'))),td('&nbsp;<p />'),td(bold(DAStudio.message('Slvnv:consistency:requirements')))])...
        ];
        for i=1:results_doc_number(results)
            for j=1:results_block_number(results,i)
                str_html=[str_html,'<tr><td>'];
                open_row=['</td>',td('')];
                ResultDescription{end+1}=str_html;
                handle=results_block_handle(results,i,j);
                if is_sf_handle(handle)
                    rt=Stateflow.Root;
                    ResultDetails{end+1}={rt.idToHandle(handle)};
                else
                    ResultDetails{end+1}=handle;
                end
                str_html='';
                for k=1:results_req_number(results,i,j)
                    str_html=[...
str_html...
                    ,open_row...
                    ,td(results_link(system,results,i,j,k))...
                    ,'</tr>'];
                    open_row=['<tr>',td(''),td('')];
                end
            end
        end
        ResultDescription{end+1}=[str_html,'</table></blockquote>'];
        mdladvObj.setCheckResultStatus(false);

        if~isempty(missing_docs)
            ResultDescription{1}=[missing_docs,'<p />',ResultDescription{1}];
        end
        if~isempty(all_errors)
            ResultDescription{1}=[all_errors,'<p />',ResultDescription{1}];
        end
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'id');
        end
    elseif~isempty(all_errors)||~isempty(missing_docs)
        ResultDescription{end+1}=[all_errors,'<p />',missing_docs];
        mdladvObj.setCheckResultStatus(false);
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'id');
        end
    elseif~isempty(mlCheck)
        [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'id');
        mdladvObj.setCheckResultStatus(false);
    else
        ResultDescription{end+1}=pass_string();
        mdladvObj.setCheckResultStatus(true);
    end
    ResultDetails{end+1}=[];
end

function[ResultDescription,ResultDetails]=check_label(system,filters)
    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    results=results_make_empty();

    all_errors='';
    missing_docs='';


    proxy_hosts=containers.Map('KeyType','char','ValueType','any');
    proxy_warning='';

    modelH=bdroot(system);


    isLegacyData=~rmidata.isExternal(modelH);

    hBlocks=rmisl.blockTable(system,'get',true);
    for i=1:length(hBlocks)
        try










            [reqs,filterMatched,destIdsInReqSet]=rmi.reqsWithFilterFlags(hBlocks(i),filters,~isLegacyData);
        catch mexception
            if strcmp(mexception.identifier,'Simulink:Commands:InvSimulinkObjHandle')



                rmisl.blockTable(modelH,'clear');
                hBlocks=rmisl.blockTable(bdroot(system),'get',true);

                [reqs,filterMatched,destIdsInReqSet]=rmi.reqsWithFilterFlags(hBlocks(i),filters,~isLegacyData);
            else
                rethrow(mexception);
            end
        end

        for j=1:length(reqs)

            if~reqs(j).linked
                continue;
            end

            if~filterMatched(j)
                continue;
            end

            if~isLegacyData
                if strcmp(reqs(j).reqsys,'linktype_rmi_slreq')



                    continue;
                elseif~isempty(destIdsInReqSet{j})




                    try
                        proxy_hosts=updateProxyHostsMap(proxy_hosts,destIdsInReqSet{j});
                    catch Mex
                        this_error=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'label');
                        if~contains(all_errors,this_error)
                            all_errors=[all_errors,'<li>',this_error,'</li>'];
                        end
                    end
                    continue;
                end
            end

            try






                if any(strcmp(reqs(j).reqsys,{'linktype_rmi_simulink','linktype_rmi_matlab'}))
                    if rmisl.isHarnessIdString(reqs(j).doc)
                        parentName=strtok(reqs(j).doc,':');
                        if strcmp(parentName,get_param(modelH,'Name'))
                            [~,objPath]=rmi.objinfo(hBlocks(i));
                            error(message('Slvnv:reqmgt:mdlAdvCheck:UnableToCheckHarnessLink',objPath,num2str(j)));
                        end
                    end
                end
                [status,new_description]=rmi('check',hBlocks(i),'description',j);
                if~status&&~rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,new_description{1},j);
                end
            catch Mex
                if rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    continue;
                end

                if contains(Mex.message,getString(message('Slvnv:reqmgt:getLinktype:UnregisteredExt','.mn')))
                    rmiut.warnNoBacktrace('Slvnv:reqmgt:linktype_rmi_mupad:MuPADLinkSkipped','MuPAD Notebook');
                    continue;
                end


                [this_error,missing_doc]=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'label');
                if isempty(this_error)
                    missing_doc=0;
                    this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                    results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,'',j);
                end

                if missing_doc
                    if~contains(missing_docs,this_error)
                        missing_docs=[missing_docs,'<li>',this_error,'</li>'];
                    end
                else
                    if~contains(all_errors,this_error)
                        all_errors=[all_errors,'<li>',this_error,'</li>'];
                    end
                end
            end
        end
    end


    [mlCheck,all_errors]=rmisl.checkMFunctions(system,'label',all_errors);

    if~isempty(all_errors)
        all_errors=['<p /><font color=''#cc5500''><b>',DAStudio.message('Slvnv:consistency:EncounteredErrors'),'</b><ul>',all_errors,'</ul></font><hr>'];
    end
    if~isempty(missing_docs)
        missing_docs=['<p /><font color=''#cc5500''><b>'...
        ,getString(message('Slvnv:consistency:UnableToCheckMissingDoc')),'</b><ul>',missing_docs,'</ul></font><hr>'];
    end
    if~isempty(proxy_hosts)
        proxy_list=proxyHostsToList(proxy_hosts);
        if~isempty(proxy_list)
            proxy_warning=['<p /><font color=''#cc5500''><b>'...
            ,getString(message('Slvnv:consistency:UnableToCheckReferencedItem')),'</b><ul>',proxy_list,'</ul>'...
            ,getString(message('Slvnv:consistency:UnableToCheckUpdateReferences')),'</font><hr>'];
        end
    end

    if results_doc_number(results)>0
        str_html=[bold('Inconsistencies:'),'<blockquote>'...
        ,'<table><tr><td colspan="7">'...
        ,DAStudio.message('Slvnv:consistency:checkLabelResults',bold(DAStudio.message('Slvnv:consistency:update')))...
        ,'</td></tr>',empty_row(7)...
        ,tr([td(bold(DAStudio.message('Slvnv:consistency:block'))),td('&nbsp;<p />'),td(bold(DAStudio.message('Slvnv:consistency:currentDescription')))...
        ,td('&nbsp;'),td(bold(DAStudio.message('Slvnv:consistency:externalDescription'))),td('&nbsp;'),td('&nbsp;')])...
        ];
        hasLibLinks=false;
        for i=1:results_doc_number(results)
            for j=1:results_block_number(results,i)
                str_html=[str_html,'<tr><td>'];
                open_row=['</td>',td('')];
                ResultDescription{end+1}=str_html;
                handle=results_block_handle(results,i,j);
                if is_sf_handle(handle)
                    rt=Stateflow.Root;
                    ResultDetails{end+1}={rt.idToHandle(handle)};
                else
                    ResultDetails{end+1}=handle;
                end
                hBlock=results.block_table{i}(j);
                str_obj=rmi_link(system,rmisl.blockTable(system,'idx',hBlock));
                str_html='';
                for k=1:results_req_number(results,i,j)
                    req_idx=results_req_idx(results,i,j,k);
                    new_description=results_path(results,i,j,k);
                    [fix_cmd,label,hasLibLinks]=description_fix_cmd(str_obj,req_idx,new_description,hBlock,hasLibLinks);
                    str_html=[...
str_html...
                    ,open_row...
                    ,td(results_link(system,results,i,j,k))...
                    ,td('')...
                    ,td(new_description)...
                    ,td('<br/><br/>')...
                    ,td(hlink(fix_cmd,label))...
                    ,'</tr>'];
                    open_row=['<tr>',td(''),td('')];
                end
            end
        end
        if hasLibLinks
            ResultDescription{1}=insertLibLinkMessage(ResultDescription{1},7);
        end
        ResultDescription{end+1}=[str_html,'</table></blockquote>'];
        mdladvObj.setCheckResultStatus(false);

        if~isempty(proxy_warning)
            ResultDescription{1}=[proxy_warning,'<p />',ResultDescription{1}];
        end
        if~isempty(missing_docs)
            ResultDescription{1}=[missing_docs,'<p />',ResultDescription{1}];
        end
        if~isempty(all_errors)
            ResultDescription{1}=[all_errors,'<p />',ResultDescription{1}];
        end
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'label');
        end

    elseif~isempty(all_errors)||~isempty(missing_docs)
        ResultDescription{end+1}=[all_errors,'<p />',missing_docs];
        mdladvObj.setCheckResultStatus(false);
        if~isempty(proxy_warning)
            ResultDescription{end}=[ResultDescription{end},'<p />',proxy_warning];
        end
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'label');
        end
    elseif~isempty(mlCheck)
        if~isempty(proxy_warning)
            ResultDescription{end+1}=proxy_warning;
        end
        [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'label');
        mdladvObj.setCheckResultStatus(false);
    elseif~isempty(proxy_warning)
        ResultDescription{end+1}=[pass_string(),'<p />',proxy_warning];
        mdladvObj.setCheckResultStatus(true);
    else
        ResultDescription{end+1}=pass_string();
        mdladvObj.setCheckResultStatus(true);
    end
    ResultDetails{end+1}=[];
end

function[cmd,label,hasLibLinks]=description_fix_cmd(str_obj,req_idx,new_description,hBlock,hasLibLinks)
    isSf=(ceil(hBlock)==hBlock);
    if(~isSf&&length(rmi.getReqs(hBlock))<req_idx)||rmisl.inLibrary(hBlock,isSf)
        cmd=no_fix_implicit_cmd();
        label=DAStudio.message('Slvnv:consistency:fixInLib');
        hasLibLinks=true;
    else
        str_idx=num2str(req_idx);
        cmd=rmi_set(str_obj,str_idx,'description',new_description);
        label=DAStudio.message('Slvnv:consistency:update');
    end
end

function[ResultDescription,ResultDetails]=check_path(system,filters)
    ResultDescription={};
    ResultDetails={};
    results=results_make_empty();
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    hBlocks=rmisl.blockTable(system,'get',true);
    all_errors='';
    for i=1:length(hBlocks)
        [reqs,flags]=rmi.reqsWithFilterFlags(hBlocks(i),filters);
        for j=1:length(reqs)
            if~flags(j)
                continue;
            end
            try
                [status,new_path]=rmi('check',hBlocks(i),'pathtype',j);
                if~status&&~rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    results=results_add_req(...
                    results,reqs(j).doc,hBlocks(i),...
                    reqs(j).description,new_path{1},j);
                end
            catch Mex
                if rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                    continue;
                end


                this_error=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'path');
                if isempty(this_error)
                    this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                    results=results_add_req(results,reqs(j).doc,hBlocks(i),...
                    [Mex.message,': ',Mex.stack(1).name,' l',num2str(Mex.stack(1).line)],...
                    '',j);
                end

                if~contains(all_errors,this_error)
                    all_errors=[all_errors,'<li>',this_error,'</li>'];
                end
            end
        end
    end
    if~isempty(all_errors)
        all_errors=['<p /><font color=''#cc5500''><b>',DAStudio.message('Slvnv:consistency:EncounteredErrors'),'</b><ul>',all_errors,'</ul></font><hr>'];
    end


    [mlCheck,all_errors]=rmisl.checkMFunctions(system,'path',all_errors);

    doc_number=results_doc_number(results);
    if doc_number>0
        if ispc
            preferred_type=get_preferred_link_type_string();
            str_html=[DAStudio.message('Slvnv:consistency:checkPathResults',bold(preferred_type))...
            ,'<blockquote><table>'...
            ,empty_row(5)...
            ];
        else
            str_html=[DAStudio.message('Slvnv:consistency:checkPathResultsNonPC')...
            ,'<blockquote><table>'...
            ,empty_row(5)...
            ];
        end
        for i=1:doc_number
            hasLibLinks=false;
            thisDocBegin=length(ResultDescription)+1;
            str_html=[...
str_html...
            ,tr(['<td align="right">',pad(bold([DAStudio.message('Slvnv:consistency:currentPath'),':']),1,4),'</td><td colspan="4">',results_doc(results,i),'</td>'])...
            ,tr(['<td align="right">',pad(bold([DAStudio.message('Slvnv:consistency:validPath'),':']),1,4),'<p /></td><td colspan="4">',results_path(results,i,1,1),'</td>'])...
            ,tr([td(pad(bold(DAStudio.message('Slvnv:consistency:block')),2,40)),td('&nbsp;<p />'),td(pad(bold(DAStudio.message('Slvnv:consistency:requirements')),2,30)),td('&nbsp;'),td('')])...
            ];
            fix_count=0;
            for j=1:results_block_number(results,i)
                str_html=[str_html,'<tr><td>'];
                open_row=['</td>',td('')];
                ResultDescription{end+1}=str_html;
                handle=results_block_handle(results,i,j);
                if is_sf_handle(handle)
                    rt=Stateflow.Root;
                    ResultDetails{end+1}={rt.idToHandle(handle)};
                else
                    ResultDetails{end+1}=handle;
                end
                str_html='';
                for k=1:results_req_number(results,i,j)
                    [fix_cmd,label,hasLibLinks]=doc_fix_cmd(system,results,i,j,k,hasLibLinks);
                    str_html=[...
str_html...
                    ,open_row...
                    ,td(results_link(system,results,i,j,k))...
                    ,td('')...
                    ,td(hlink(fix_cmd,label)),'</tr>'];
                    if~hasLibLinks
                        fix_count=fix_count+1;
                    end
                    open_row=['<tr>',td(''),td('')];
                end
            end
            if fix_count>1
                [cmd_fix,cnt]=doc_fix_all_cmd(system,results,i);
                if cnt>1
                    str_html=[str_html...
                    ,tr([td(''),td(''),td(''),td(''),td(hlink(cmd_fix,DAStudio.message('Slvnv:consistency:fixAll')))])];
                end
            end
            str_html=[str_html,empty_row(4)];
            if hasLibLinks
                ResultDescription{thisDocBegin}=insertLibLinkMessage(ResultDescription{thisDocBegin},5);
            end
        end
        ResultDescription{end+1}=[str_html,'</table></blockquote>'];
        mdladvObj.setCheckResultStatus(false);
        if~isempty(all_errors)
            ResultDescription{1}=[all_errors,'<p />',ResultDescription{1}];
        end
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'path');
        end
    elseif~isempty(all_errors)
        ResultDescription{end+1}=all_errors;
        mdladvObj.setCheckResultStatus(false);
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'path');
        end
    elseif~isempty(mlCheck)
        [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'path');
        mdladvObj.setCheckResultStatus(false);
    else
        ResultDescription{end+1}=pass_string();
        mdladvObj.setCheckResultStatus(true);
    end
    ResultDetails{end+1}=[];
end




function results=results_make_empty()











    results.doc_table={};
    results.block_table={};
    results.req_table={};
end

function[results,idx_doc]=results_get_doc_idx(results,doc_name)
    idx_doc=find(ismember(results.doc_table,doc_name));
    if isempty(idx_doc)
        results.doc_table{end+1}=doc_name;
        idx_doc=length(results.doc_table);
        results.block_table{idx_doc}=[];
    end
end

function[results,idx_block]=results_get_block_idx(results,idx_doc,hBlock)
    idx_block=find(ismember(results.block_table{idx_doc},hBlock));
    if isempty(idx_block)
        results.block_table{idx_doc}(end+1)=hBlock;
        idx_block=length(results.block_table{idx_doc});
        results.req_table{idx_doc}{idx_block}={};
    end
end

function results=results_add_req(results,doc_name,hBlock,desc,myPath,idx)

    if ispc&&any(doc_name=='.')
        doc_name=lower(doc_name);
    end
    if isempty(strtrim(doc_name))
        doc_name=['&lt;',getString(message('Slvnv:reqmgt:mdlAdvCheck:noDocumentNameEntered')),'&gt;'];
    end
    [results,idx_doc]=results_get_doc_idx(results,doc_name);
    [results,idx_block]=results_get_block_idx(results,idx_doc,hBlock);
    results.req_table{idx_doc}{idx_block}{end+1}.desc=desc;
    results.req_table{idx_doc}{idx_block}{end}.path=myPath;
    results.req_table{idx_doc}{idx_block}{end}.idx=idx;
end

function doc_nb=results_doc_number(results)
    doc_nb=length(results.doc_table);
end

function block_nb=results_block_number(results,doc_idx)
    block_nb=length(results.block_table{doc_idx});
end

function req_nb=results_req_number(results,doc_idx,block_idx)
    req_nb=length(results.req_table{doc_idx}{block_idx});
end

function doc=results_doc(results,doc_idx)
    doc=results.doc_table{doc_idx};
end

function handle=results_block_handle(results,doc_idx,block_idx)
    handle=results.block_table{doc_idx}(block_idx);
end

function myPath=results_path(results,doc_idx,block_idx,req_idx)
    myPath=results.req_table{doc_idx}{block_idx}{req_idx}.path;
end

function req_idx=results_req_idx(results,doc_idx,block_idx,idx)
    req_idx=results.req_table{doc_idx}{block_idx}{idx}.idx;
end

function link=results_link(system,results,doc_idx,block_idx,req_idx)
    hBlock=results.block_table{doc_idx}(block_idx);
    str_obj=rmi_link(system,rmisl.blockTable(system,'idx',hBlock));
    target_index=results.req_table{doc_idx}{block_idx}{req_idx}.idx;
    desc=results.req_table{doc_idx}{block_idx}{req_idx}.desc;
    if rmisl.is_signal_builder_block(hBlock)
        [group_idx,local_idx]=sigbuilder_group_index(hBlock,target_index);
        cmd=rmi_edit_sigbuilder(str_obj,local_idx,group_idx);
    else
        cmd=rmi_edit(str_obj,target_index);
    end
    link=hlink(cmd,desc);
end

function[group_index,local_req_idx]=sigbuilder_group_index(obj,req_idx)




    modelH=rmisl.getmodelh(obj);
    if rmidata.isExternal(modelH)
        [~,grpInfo]=slreq.getSigbGrpData(obj);
        group_index=grpInfo(req_idx);
        local_req_idx=req_idx-length(grpInfo(grpInfo<group_index));
    else


        wsH=find_system(obj,'FollowLinks','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'BlockType','FromWorkspace');
        blkInfo=get_param(wsH,'VnvData');
        group_index=1;
        local_req_idx=req_idx;
        count_reqs=0;
        while group_index<blkInfo.groupCnt
            count_reqs=count_reqs+blkInfo.groupReqCnt(group_index);
            if count_reqs<req_idx
                group_index=group_index+1;
                local_req_idx=req_idx-count_reqs;
            else
                break;
            end
        end
    end
end

function[cmd,label,hasLibLinks]=doc_fix_cmd(system,results,doc_idx,block_idx,req_idx,hasLibLinks)
    hBlock=results.block_table{doc_idx}(block_idx);


    isSf=(ceil(hBlock)==hBlock);
    if(~isSf&&length(rmi.getReqs(hBlock))<req_idx)||rmisl.inLibrary(hBlock,isSf)
        cmd=no_fix_implicit_cmd();
        label=DAStudio.message('Slvnv:consistency:fixInLib');
        hasLibLinks=true;
    else
        str_obj=rmi_link(system,rmisl.blockTable(system,'idx',hBlock));
        str_idx=num2str(results.req_table{doc_idx}{block_idx}{req_idx}.idx);
        myPath=results.req_table{doc_idx}{block_idx}{req_idx}.path;
        cmd=rmi_set(str_obj,str_idx,'doc',myPath);
        label=DAStudio.message('Slvnv:consistency:fix');
    end
end

function cmd=no_fix_implicit_cmd()
    messageStr=getString(message('Slvnv:reqmgt:mdlAdvCheck:CannotModify'));
    cmd=['matlab:warndlg(''',messageStr,''', ''',getString(message('Slvnv:reqmgt:mdlAdvCheck:InconsistencyInLibrary')),''');'];
end

function result=insertLibLinkMessage(orig,cols)
    emptyRow=empty_row(cols);
    extraMessage=strrep(emptyRow,'&nbsp;',DAStudio.message('Slvnv:consistency:checkResultsLib'));
    result=strrep(orig,emptyRow,[extraMessage,emptyRow]);
end

function[cmd,cnt]=doc_fix_all_cmd(system,results,doc_idx)
    str_objs='';
    str_idxs='';
    cnt=0;
    for i=1:length(results.block_table{doc_idx})
        hBlock=results.block_table{doc_idx}(i);
        if rmisl.inLibrary(hBlock,(ceil(hBlock)==hBlock))
            continue;
        end
        b_name=rmi_link(system,rmisl.blockTable(system,'idx',hBlock));
        str_objs=[str_objs,' ',b_name];
        s_idxs='';
        for j=1:length(results.req_table{doc_idx}{i})
            s_idx=num2str(results.req_table{doc_idx}{i}{j}.idx);
            s_idxs=[s_idxs,' ',s_idx];
            cnt=cnt+1;
        end
        str_idxs=[str_idxs,' {',s_idxs,'}'];
    end
    str_objs=['{',str_objs,'}'];
    str_idxs=['{',str_idxs,'}'];
    myPath=results.req_table{doc_idx}{1}{1}.path;
    cmd=rmi_set(str_objs,str_idxs,'doc',myPath);
end

function rsMap=updateProxyHostsMap(rsMap,destIdInReqSet)

    ref=slreq.utils.getReqObjFromFullID(destIdInReqSet);
    if isempty(ref)
        error(message('Slvnv:reqmgt:linktype_rmi_excel:FailedToLocateItem',destIdInReqSet));
    elseif isKey(rsMap,ref.artifactUri)
        return;
    else
        reqData=slreq.data.ReqData.getInstance();
        reqSet=ref.getReqSet();
        topRef=reqData.findExternalRequirementByArtifactUrlId(reqSet,ref.domain,ref.artifactUri,'');
        if isempty(topRef)

            error(message('Slvnv:reqmgt:linktype_rmi_excel:FailedToLocateItem',ref.artifactUri));
        end
        rsMap(ref.artifactUri)=topRef;
    end
end

function html=proxyHostsToList(hostsMap)
    html='';

    docs=keys(hostsMap);
    for i=1:length(docs)
        doc=docs{i};
        val=hostsMap(doc);

        if docModifiedAfterImport(val.domain,doc,val.synchronizedOn)
            navToDocCmd=sprintf('matlab:rmi.navigate(''%s'',''%s'','''',''%s'')',val.domain,doc,bdroot);
            linkToDoc=sprintf('<a href="%s">%s</a>',navToDocCmd,doc);
            reqSet=val.getReqSet();
            navToProxyCmd=sprintf('matlab:rmi.navigate(''linktype_rmi_slreq'',''%s'',''%d'')',reqSet.name,val.sid);
            linkToProxy=sprintf('<a href="%s">%s:</a>',navToProxyCmd,val.summary);
            html=['<li>',linkToProxy,' &lt;&lt; ',linkToDoc,'</li>',newline];
        end
    end

    function tf=docModifiedAfterImport(domain,localPath,importTime)
        docTypeObj=rmi.linktype_mgr('resolveByRegName',domain);
        fullPath=rmi.locateFile(localPath,bdroot);
        if isempty(docTypeObj)
            tf=true;
        elseif isempty(docTypeObj.DocDateFcn)
            if docTypeObj.isFile
                fileinfo=dir(fullPath);
                if isempty(fileinfo)
                    tf=true;
                else
                    docDate=datestr(fileinfo.datenum,'local');
                    tf=datenum(docDate)>datenum(importTime);
                end
            else
                tf=true;
            end
        else
            docDate=docTypeObj.DocDateFcn(fullPath);
            try
                tf=datenum(docDate)>datenum(importTime);
            catch ex %#ok<NASGU>


                tf=true;
            end
        end
    end
end




function preferred_type=get_preferred_link_type_string()
    linkSettings=rmi.settings_mgr('get','linkSettings');
    switch(linkSettings.docPathStorage)
    case 'absolute'
        preferred_type=DAStudio.message('Slvnv:consistency:pathAbsolute');
    case 'pwdRelative'
        preferred_type=DAStudio.message('Slvnv:consistency:pathPwdRelative');
    case 'modelRelative'
        preferred_type=DAStudio.message('Slvnv:consistency:pathRelative');
    case 'none'
        preferred_type=DAStudio.message('Slvnv:consistency:pathNone');
    otherwise
        preferred_type=DAStudio.message('Slvnv:consistency:pathInvalid');
    end
end

function result=is_sf_handle(handle)
    result=(floor(handle)==handle);
end




function row_string=empty_row(cols)
    row_string=sprintf('<tr><td colspan="%d">&nbsp;</td></tr>',cols);
end

function html_string=pass_string()
    html_string=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
end

function html_string=html_tag(tag,text)
    html_string=['<',tag,'>',text,'</',tag,'>'];
end

function html_string=hlink(url,text)
    html_string=['<a href="',url,'">',text,'</a>'];
end

function html_string=bold(text)
    html_string=html_tag('b',text);
end

function html_string=td(text)
    html_string=html_tag('td',text);
end

function html_string=pad(text,head,tail)
    space='&nbsp;';
    html_string=[repmat(space,1,head),text,repmat(space,1,tail)];
end

function html_string=tr(text)
    html_string=html_tag('tr',text);
end




function cmd=rmi_edit(obj,idx)
    cmd=sprintf('matlab:rmi(''edit'', %s, %d);',obj,idx);
end

function cmd=rmi_edit_sigbuilder(obj,idx,group_idx)
    cmd=sprintf('matlab:rmi(''edit'', %s, %d, %d);',obj,idx,group_idx);
end





function quoted_str=quote(str)

    c=modeladvisorprivate('HTMLjsencode',str,'encode');
    encoded=[];
    for i=1:length(c)
        encoded=[encoded,c{i}];
    end
    quoted_str=['''',encoded,''''];
end

function cmd=rmi_set(obj,idx,field,value)
    if isempty(value)
        cmd=[...
        'matlab:rmi(''setProp'' ,',obj,',true,',idx,','...
        ,quote(field),');'...
        ];
    else
        cmd=[...
        'matlab:rmi(''setProp'',',obj,', true,',idx,','...
        ,quote(field),',',quote(value),');'...
        ];
    end
end

function cmd=rmi_link(obj,idx)
    cmd=['rmicheck.rmimdladvobj(',quote(obj),',',num2str(idx),')'];
end

