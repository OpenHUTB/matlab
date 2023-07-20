function domObjs=emitDOMforTaskNode(obj,report)



    domObjs=loc_emitDOMforTaskNode(report,obj.TaskNode,obj.counterStructure.generateTime,1,'',0);
end

function[resultHTML,dot_counter]=loc_emitDOMforTaskNode(rptObj,this,generateTime,level,FolderNumbering,dot_counter)

    if isa(this,'ModelAdvisor.Task')
        if this.MACIndex~=0
            fprintf('%s','.');
            dot_counter=dot_counter+1;
            if mod(dot_counter,80)==0
                fprintf('\n');
            end
            resultHTML=emitDOMforLeafNode(rptObj,this,generateTime,level);
        else
            resultHTML='';
        end
    else

        counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',this);
        FolderNumberingText=mlreportgen.dom.Text(FolderNumbering);
        FolderNumberingText.Color='#800000';

        sectionTitle=mlreportgen.dom.Heading(level);
        DOM_insert_whitespace(sectionTitle,1);
        FolderImage=mlreportgen.dom.Image(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','icon_folder.png'));
        sectionTitle.append(FolderImage);
        DOM_insert_whitespace(sectionTitle,1);



        sectionTitle.append(this.DisplayName);
        if level>1
            DOM_insert_whitespace(sectionTitle,4);
            enumList=enumeration(ModelAdvisor.CheckStatus.NotRun);
            enumList=enumList(enumList~=ModelAdvisor.CheckStatus.Informational);
            for i=length(enumList):-1:1
                imageLink=mlreportgen.dom.Image(fullfile(matlabroot,ModelAdvisor.CheckStatusUtil.getIcon(enumList(i),'task')));
                sectionTitle.append(imageLink);
                st=[char(enumList(i)),'Ct'];
                sectionTitle.append(mlreportgen.dom.Text(num2str(counterStructure.(st))));
                DOM_insert_whitespace(sectionTitle,1);
            end
        end

        if level>1
            resultHTML={DOM_insert_newline,sectionTitle};
        else
            resultHTML={sectionTitle};
        end
        level=level+1;









        subFolderNumbering=0;
        for i=1:length(this.ChildrenObj)
            if isa(this.ChildrenObj{i},'ModelAdvisor.Group')
                subFolderNumbering=subFolderNumbering+1;
            end

            if isempty(FolderNumbering)
                tempFolderNumbering=num2str(subFolderNumbering);
            else
                tempFolderNumbering=[FolderNumbering,'.',num2str(subFolderNumbering)];
            end

            [subNodeResult,dot_counter]=...
            loc_emitDOMforTaskNode(rptObj,this.ChildrenObj{i},generateTime,level,tempFolderNumbering,dot_counter);

            resultHTML={resultHTML{:},subNodeResult{:}};%#ok<CCAT>
        end

    end
end

function DOM_insert_whitespace(parentObj,count)
    whiteSpace=mlreportgen.dom.Text(' ');
    whiteSpace.WhiteSpace='preserve';
    for i=1:count
        parentObj.append(clone(whiteSpace));
    end
end

function clonedNewline=DOM_insert_newline
    newLine=mlreportgen.dom.Text(char(10));

    clonedNewline=clone(newLine);
end

function resultHTML=emitDOMforLeafNode(rptObj,this,generateTime,level)
    dp=mlreportgen.dom.DocumentPart(rptObj,'CheckSection');
    open(dp);
    while~strcmp(dp.CurrentHoleId,'#end#')
        switch dp.CurrentHoleId
        case 'CheckTitle'

            CheckTitle=mlreportgen.dom.Heading(level);
            CheckTitle.WhiteSpace='preserve';
            imageIcon=DOM_Get_icon(this);
            CheckTitle.append(imageIcon);
            CheckTitle.append(' ');
            CheckTitle.append(this.Displayname);
            if~strcmp(this.Severity,'Optional')
                requirestring=[' (',DAStudio.message('Simulink:tools:MARequired'),')'];
            else
                requirestring='';
            end
            CheckTitle.append(requirestring);
            if(this.RunTime~=0)&&(this.RunTime<generateTime)&&~strcmp(this.State,'None')
                outofdatewarn=[' (',loc_getDateString(this.RunTime),')'];
            else
                outofdatewarn='';
            end
            CheckTitle.append(outofdatewarn);
            append(dp,CheckTitle);
        case 'CheckResult'
            if this.State~=ModelAdvisor.CheckStatus.NotRun
                if this.MACIndex<0
                    htmlString=['<p />',ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC),{'fail'}).emitHTML];
                    checkResult=mlreportgen.dom.HTML(htmlString);
                else
                    htmlString=this.Check.ResultInHTML;
                    if this.MAObj.ShowActionResultInRpt
                        htmlString=[htmlString,loc_emitActionResult(this.Check)];
                    end
                    htmlString=regexprep(htmlString,'<!-- pdfreport_ignore_start -->(.*?)<!-- pdfreport_ignore_finish -->','');
                    htmlString=strrep(htmlString,'<!-- mdladv_ignore_finish --><p /><p />','');
                    htmlString=strrep(htmlString,'<br>','<br />');
                    htmlString=strrep(htmlString,'<hr>','<hr />');
                    htmlString=strrep(htmlString,'<br&#160;/>','<br />');
                    htmlString=strrep(htmlString,'&nbsp;',' ');
                    htmlString=strrep(htmlString,'<pre>','');
                    htmlString=strrep(htmlString,'</pre>','');
                    htmlString=strrep(htmlString,'style="display:'''';"','');
                    htmlString=strrep(htmlString,sprintf('\n'),' ');
                    subbar='_________________________________________________________________________________________';
                    short_subbar='________________________________________________________________________';
                    htmlString=strrep(htmlString,subbar,short_subbar);
                    htmlString=html_tailor_invalidtagsinsidep(htmlString);
                    htmlString=html_tailor_divsinsidetd(htmlString);
                    htmlString=html_tailor_imginsidespan(htmlString);
                    htmlString=html_tailor_ulinsidefont(htmlString);
                    htmlString=regexprep(htmlString,'<a name="([^"]{40,})">','<a name="${mlreportgen.utils.hash($1)}">');
                    htmlString=html_tailor_li_inside_td_without_ulol(htmlString);
                    htmlString=html_tailor_newlineinsideli(htmlString);
                    htmlString=html_tailor_linkToMatlab(htmlString);
                    htmlString=html_tailor_unpaired_tags(htmlString);
                    htmlString=strrep(htmlString,'& ','&amp; ');
                    htmlString=strrep(htmlString,'&&&#160;','&amp;&amp;&#160;');
                    htmlString=strrep(htmlString,'<!-- mdladv_ignore_start -->','');
                    htmlString=strrep(htmlString,'<!-- mdladv_ignore_finish -->','');
                    htmlString=strrep(htmlString,'<!-- inputparam_section_start -->','');
                    htmlString=strrep(htmlString,'<!-- inputparam_section_finish -->','');
                    checkResult=mlreportgen.dom.HTML(htmlString);

                    checkResult.Style=[checkResult.Style,{mlreportgen.dom.OuterMargin('0.15in','0in')}];
                    childhtmlobj=checkResult.Children;
                    for childCounter=1:length(childhtmlobj)
                        childhtmlobj(childCounter).Style=[childhtmlobj(childCounter).Style,{mlreportgen.dom.OuterMargin('0.15in','0in')}];
                    end
                end
            else
                checkResult=mlreportgen.dom.Paragraph(DAStudio.message('Simulink:tools:MANotRunMsg'));
                checkResult.Style=[checkResult.Style,{mlreportgen.dom.OuterMargin('0.15in','0in')}];
                if this.MAObj.IsLibrary&&~this.MAObj.CheckCellArray{this.MACIndex}.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
                    checkResult.append(['. ',DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary')]);
                end
            end
            append(dp,checkResult);
        end
        moveToNextHole(dp);
    end
    resultHTML={dp};
end

function clonedImageIcon=DOM_Get_icon(this)
    icon=this.getDisplayIcon;
    if contains(icon,'task_warning_h')
        icon=strrep(icon,'task_warning_h','task_warning');
    end
    clonedImageIcon=mlreportgen.dom.Image(fullfile(matlabroot,icon));
end

function space_str=spaces(n)
    space_str='';
    for i=1:n
        space_str(end+1)=' ';
    end
end

function[output,p_pairs]=html_tailor_invalidtagsinsidep(str)
    begin_of_p=regexp(str,'<p>');
    end_of_p=regexp(str,'</p>');
    output=str;
    if isempty(begin_of_p)||isempty(end_of_p)
        return;
    end
    if length(begin_of_p)~=length(end_of_p)
        return
    end
    p_pairs={};
    index_pairs={};
    while~isempty(begin_of_p)
        current_begin_tag=begin_of_p(end);
        for i=1:length(end_of_p)
            if current_begin_tag<end_of_p(i)

                p_pairs{end+1}=str(current_begin_tag:end_of_p(i)+3);
                index_pairs{end+1}={current_begin_tag,end_of_p(i)};
                end_of_p(i)=[];
                begin_of_p(end)=[];
                break
            end
        end
    end
    for i=1:length(p_pairs)
        if~isempty(strfind(p_pairs{i},'<table'))||~isempty(strfind(p_pairs{i},'<ul'))||length(strfind(p_pairs{i},'<p>'))>1
            output(index_pairs{i}{1}:index_pairs{i}{1}+2)='   ';
            output(index_pairs{i}{2}:index_pairs{i}{2}+3)='    ';
        end
    end
end

function[output]=html_tailor_divsinsidetd(str)
    output=str;
    newstr='';
    while(~strcmp(output,newstr))
        newstr=output;
        output=regexprep(output,'(<td[^<>]*?>)(.*?)(<div[^<>]*?>)(.*?)(</div>)(.*?)(</td>)','$1$2$4$6$7');
    end
    return

    begin_of_td=regexp(str,'<td');
    end_of_td=regexp(str,'</td>');
    output=str;
    if isempty(begin_of_td)||isempty(end_of_td)
        return;
    end
    if length(begin_of_td)~=length(end_of_td)
        return
    end
    index_pairs={};
    while~isempty(begin_of_td)
        current_begin_tag=begin_of_td(end);
        for i=1:length(end_of_td)
            if current_begin_tag<end_of_td(i)
                index_pairs{end+1}={current_begin_tag,end_of_td(i)};
                end_of_td(i)=[];
                begin_of_td(end)=[];
                break
            end
        end
    end
    exclusive_index_pairs={};
    for i=1:length(index_pairs)
        this_td_tag_is_wrapped_inside_another_td=false;

        for j=i:length(index_pairs)


            if(index_pairs{i}{2}<index_pairs{j}{2})
                this_td_tag_is_wrapped_inside_another_td=true;
                break;
            end

        end
        if~this_td_tag_is_wrapped_inside_another_td
            exclusive_index_pairs{end+1}=index_pairs{i};
        end
    end
    newstr='';
    if exclusive_index_pairs{end}{1}>1
        newstr=str(1:exclusive_index_pairs{end}{1}-1);
    end
    for i=length(exclusive_index_pairs):-1:1
        current_td_pair=str(exclusive_index_pairs{i}{1}:exclusive_index_pairs{i}{2}+4);
        current_td_pair=regexprep(current_td_pair,'</div>','');
        newstr=[newstr,regexprep(current_td_pair,'<div.*?>','')];%#ok<*AGROW>
        if i>1
            newstr=[newstr,str(exclusive_index_pairs{i}{2}+5:exclusive_index_pairs{i-1}{1}-1)];
        end
    end
    if exclusive_index_pairs{1}{2}+5<length(str)
        newstr=[newstr,str(exclusive_index_pairs{1}{2}+5:end)];
    end
    output=newstr;
end

function[output]=html_tailor_imginsidespan(str)
    begin_of_span=regexp(str,'<span');
    end_of_span=regexp(str,'</span>');
    output=str;
    if isempty(begin_of_span)||isempty(end_of_span)
        return;
    end
    if length(begin_of_span)~=length(end_of_span)
        return
    end
    index_pairs={};
    while~isempty(begin_of_span)
        current_begin_tag=begin_of_span(end);
        for i=1:length(end_of_span)
            if current_begin_tag<end_of_span(i)
                index_pairs{end+1}={current_begin_tag,end_of_span(i)};
                end_of_span(i)=[];
                begin_of_span(end)=[];
                break
            end
        end
    end
    exclusive_index_pairs={};
    for i=1:length(index_pairs)
        this_td_tag_is_wrapped_inside_another_td=false;

        for j=i:length(index_pairs)


            if(index_pairs{i}{2}<index_pairs{j}{2})
                this_td_tag_is_wrapped_inside_another_td=true;
                break;
            end

        end
        if~this_td_tag_is_wrapped_inside_another_td
            exclusive_index_pairs{end+1}=index_pairs{i};
        end
    end
    newstr='';
    if exclusive_index_pairs{end}{1}>1
        newstr=str(1:exclusive_index_pairs{end}{1}-1);
    end
    for i=length(exclusive_index_pairs):-1:1
        current_span_pair=str(exclusive_index_pairs{i}{1}:exclusive_index_pairs{i}{2}+6);
        newstr=[newstr,regexprep(current_span_pair,'<img.*?>','')];
        if i>1
            newstr=[newstr,str(exclusive_index_pairs{i}{2}+7:exclusive_index_pairs{i-1}{1}-1)];
        end
    end
    if exclusive_index_pairs{1}{2}+7<length(str)
        newstr=[newstr,str(exclusive_index_pairs{1}{2}+7:end)];
    end
    output=newstr;
end

function[output]=html_tailor_ulinsidefont(str)
    [begin_of_font,begin_of_font_end]=regexp(str,'<font.*?>');
    end_of_font=regexp(str,'</font>');
    output=str;
    if isempty(begin_of_font)||isempty(end_of_font)
        return;
    end
    if length(begin_of_font)~=length(end_of_font)
        return
    end
    index_pairs={};
    while~isempty(begin_of_font)
        current_begin_tag=begin_of_font(end);
        current_begin_tag_ends=begin_of_font_end(end);
        for i=1:length(end_of_font)
            if current_begin_tag<end_of_font(i)
                index_pairs{end+1}={current_begin_tag,end_of_font(i),current_begin_tag_ends};
                end_of_font(i)=[];
                begin_of_font(end)=[];
                begin_of_font_end(end)=[];
                break
            end
        end
    end
    end_of_ul=regexp(str,'</ul>');
    need_nuke_it=zeros(length(index_pairs));
    for i=1:length(end_of_ul)
        for j=1:length(index_pairs)
            if end_of_ul(i)>index_pairs{j}{1}&&end_of_ul(i)<index_pairs{j}{2}

                need_nuke_it(j)=1;
            end
        end
    end
    newstr=str;
    for i=1:length(index_pairs)
        if need_nuke_it(i)
            newstr(index_pairs{i}{1}:index_pairs{i}{3})=spaces(index_pairs{i}{3}-index_pairs{i}{1}+1);
            newstr(index_pairs{i}{2}:index_pairs{i}{2}+5)='      ';
        end
    end
    output=newstr;
end


function[output]=html_tailor_newlineinsideli(str)
    [begin_of_li,begin_of_li_end]=regexp(str,'<li>');
    end_of_li=regexp(str,'</li>');
    output=str;
    if isempty(begin_of_li)||isempty(end_of_li)
        return;
    end
    if length(begin_of_li)~=length(end_of_li)
        return
    end
    index_pairs={};
    while~isempty(begin_of_li)
        current_begin_tag=begin_of_li(end);
        current_begin_tag_ends=begin_of_li_end(end);
        for i=1:length(end_of_li)
            if current_begin_tag<end_of_li(i)
                index_pairs{end+1}={current_begin_tag,end_of_li(i),current_begin_tag_ends};
                end_of_li(i)=[];
                begin_of_li(end)=[];
                begin_of_li_end(end)=[];
                break
            end
        end
    end
    newstr='';
    if index_pairs{end}{1}>1
        newstr=str(1:index_pairs{end}{1}-1);
    end
    for i=length(index_pairs):-1:1
        current_td_pair=str(index_pairs{i}{1}:index_pairs{i}{2}+4);
        newstr=[newstr,regexprep(current_td_pair,'\n',' ')];%#ok<*AGROW>
        if i>1
            newstr=[newstr,str(index_pairs{i}{2}+5:index_pairs{i-1}{1}-1)];
        end
    end
    if index_pairs{1}{2}+5<length(str)
        newstr=[newstr,str(index_pairs{1}{2}+5:end)];
    end
    output=newstr;
end

function[output]=html_tailor_li_inside_td_without_ulol(str)
    begin_of_td=regexp(str,'<td');
    end_of_td=regexp(str,'</td>');
    output=str;
    if isempty(begin_of_td)||isempty(end_of_td)
        return;
    end
    if length(begin_of_td)~=length(end_of_td)
        return
    end
    index_pairs={};
    while~isempty(begin_of_td)
        current_begin_tag=begin_of_td(end);
        for i=1:length(end_of_td)
            if current_begin_tag<end_of_td(i)
                index_pairs{end+1}={current_begin_tag,end_of_td(i)};
                end_of_td(i)=[];
                begin_of_td(end)=[];
                break
            end
        end
    end
    exclusive_index_pairs={};
    for i=1:length(index_pairs)
        this_td_tag_is_wrapped_inside_another_td=false;

        for j=i:length(index_pairs)


            if(index_pairs{i}{2}<index_pairs{j}{2})
                this_td_tag_is_wrapped_inside_another_td=true;
                break;
            end

        end
        if~this_td_tag_is_wrapped_inside_another_td
            exclusive_index_pairs{end+1}=index_pairs{i};
        end
    end
    newstr='';
    if exclusive_index_pairs{end}{1}>1
        newstr=str(1:exclusive_index_pairs{end}{1}-1);
    end
    for i=length(exclusive_index_pairs):-1:1
        current_td_pair=str(exclusive_index_pairs{i}{1}:exclusive_index_pairs{i}{2}+4);
        end_of_li=regexp(current_td_pair,'</li>');
        if~isempty(end_of_li)&&(length(regexp(current_td_pair(end_of_li:end),'</ul>'))-length(regexp(current_td_pair(end_of_li:end),'<ul>'))<=0)...
            &&(length(regexp(current_td_pair(end_of_li:end),'</ol>'))-length(regexp(current_td_pair(end_of_li:end),'<ol>'))<=0)
            current_td_pair=regexprep(current_td_pair,'<li>','<ul><li>');
            current_td_pair=regexprep(current_td_pair,'</li>','</li></ul>');
        end
        newstr=[newstr,current_td_pair];
        if i>1
            newstr=[newstr,str(exclusive_index_pairs{i}{2}+5:exclusive_index_pairs{i-1}{1}-1)];
        end
    end
    if exclusive_index_pairs{1}{2}+5<length(str)
        newstr=[newstr,str(exclusive_index_pairs{1}{2}+5:end)];
    end
    output=newstr;
end

function[output]=html_tailor_unpaired_tags(str)
    begin_of_p=regexp(str,'<p>');
    end_of_p=regexp(str,'</p>');
    output=str;
    if length(begin_of_p)~=length(end_of_p)
        output=strrep(output,'<p>','');
        output=strrep(output,'</p>','');
    end
end

function output=html_tailor_linkToMatlab(str)

    str=regexprep(str,'<a href="matlab: modeladvisorprivate hiliteSystem USE_SID:([^<]*?)">\s*\.\.\.\.(.*?)</a>','${Advisor.Utils.getFullName($1)}');


    str=regexprep(str,'<a href="matlab: modeladvisorprivate hiliteSystem ([^<]*?)">\s*\.\.\.\.(.*?)</a>','${modeladvisorprivate(''HTMLjsencode'',$1,''decode'')}');
    output=regexprep(str,'<a href="matlab: (.*?)">(.*?)</a>','$2');
end




function dateString=loc_getDateString(timeInfo)

    locale=feature('locale');
    lang=locale.messages;

    if strncmpi(lang,'ja',2)||strncmp(lang,'zh_CN',5)||strncmpi(lang,'ko_KR',5)
        dateString=datestr(timeInfo,'yyyy/mm/dd HH:MM:SS');
    else
        dateString=datestr(timeInfo);
    end
end

function output=loc_emitActionResult(check)
    output='';
    if isa(check,'ModelAdvisor.Check')&&isa(check.Action,'ModelAdvisor.Action')&&~isempty(check.Action.ResultInHTML)
        Heading=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:ActionLog'),{'bold'});
        output=modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion',['<!-- actionresult_section_start -->'...
        ,'<div class="subsection"><H5>',Heading.emitHTML,'</H5>',check.Action.ResultInHTML,'</div>'...
        ,'<!-- actionresult_section_finish -->']);
    end
end
