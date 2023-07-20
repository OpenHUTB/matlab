function writeReport(this)



    this.makeSummary();
    this.reportname=this.makeReportName(this.docname);


    fid=fopen(this.reportname,'w');
    if fid<0
        errordlg({getString(message('Slvnv:rmiref:Check:writeReport:CouldNotCreateFile')),...
        this.reportname,...
        ' ',...
        getString(message('Slvnv:rmiref:Check:writeReport:MakeSureWritePermission'))},...
        getString(message('Slvnv:rmiref:Check:writeReport:FailedToWriteReportFile')),'modal');
        return;
    end

    titleStr=getString(message('Slvnv:rmiref:Check:writeReport:ReqLinkingReportFor',this.summary.docname));

    write_html_head(fid,titleStr);

    write_header(fid,titleStr,1);
    write_timestamp(fid,this.docname);

    write_summary_info(fid,this.summary);

    if this.summary.badModels+this.summary.badObjects<this.summary.totalBad
        invalidLinks=this.links(this.isBad&~(this.badModel|this.badObject));
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:RefsWithInvalidCommands')),invalidLinks,'invalid','red',this.sessionId);
    end

    if this.summary.badModels>0
        badModelLinks=this.links(this.badModel);
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:RefsWithUnresolvedModels')),badModelLinks,'models','red',this.sessionId);
    end

    if this.summary.badObjects>0
        badObjectLinks=this.links(this.badObject);
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:RefsWithUnresolvedObjects')),badObjectLinks,'objects','red',this.sessionId);
    end

    if this.summary.pathsFixed>0
        pathFixedLinks=this.links(this.pathFixed);
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:InconsistentModelPaths')),pathFixedLinks,'paths','darkGreen',this.sessionId);
    end

    if this.summary.labelsFixed>0
        labelFixedLinks=this.links(this.labelFixed);
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:InconsistentObjectLabels')),labelFixedLinks,'labels','darkGreen',this.sessionId);
    end

    if this.summary.totalLinks>this.summary.totalBad+this.summary.skipped
        verifiedLinks=this.links(~this.isBad&strcmp(this.skipped,''));
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:AllFunctionalLinks')),verifiedLinks,'functional','black',this.sessionId);
    end

    if this.summary.isOneWay>0
        oneWayLinks=this.links(this.isOneWay);
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:RefsWithOneWayLinks')),oneWayLinks,'oneway','darkGreen',this.sessionId);
    end


    if this.summary.skipped>0
        pick=~strcmp(this.skipped,'');
        skippedLinks=this.links(pick);

        skipReasons=this.skipped(pick);
        pickIdx=find(pick);
        for i=1:length(pickIdx)
            skippedLinks(i).issue=skipReasons{i};
        end
        write_section(fid,getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedLinks')),skippedLinks,'skipped','blud',this.sessionId);

    end

    write_html_end(fid);
    fclose(fid);
    web(this.reportname);
    rmiref.docCheckCallback('store',this);

    if this.summary.pathsFixed+this.summary.labelsFixed>0
        msg={getString(message('Slvnv:rmiref:Check:writeReport:SomeInconsistenciesWereCorrected'))};
        if this.summary.pathsFixed>0
            msg{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:ModelPathsAdjusted',num2str(this.summary.pathsFixed)));
        end
        if this.summary.labelsFixed>0
            msg{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:TooltipLabelsAdjusted',num2str(this.summary.labelsFixed)));
        end
        msg{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:SaveDocumentNow'));
        reply=questdlg(msg,...
        getString(message('Slvnv:rmiref:Check:writeReport:UnsavedChangesIn',this.summary.docname)),...
        getString(message('Slvnv:rmiref:Check:writeReport:Save')),...
        getString(message('Slvnv:rmiref:Check:writeReport:Continue')),...
        getString(message('Slvnv:rmiref:Check:writeReport:Save')));
        if isempty(reply)
            reply=getString(message('Slvnv:rmiref:Check:writeReport:Continue'));
        end
        if strcmp(reply,getString(message('Slvnv:rmiref:Check:writeReport:Save')))
            this.saveDocument();
        end
    end
end

function write_html_head(fid,titleStr)
    fprintf(fid,'\n <HTML>');
    fprintf(fid,'\n <HEAD>');
    fprintf(fid,'%s \n',define_styles);
    fprintf(fid,'\n <TITLE>%s</TITLE>',titleStr);
    fprintf(fid,'\n </HEAD>');
    fprintf(fid,'\n ');
    fprintf(fid,'\n <BODY>');
end

function write_html_end(fid)
    fprintf(fid,'\n</BODY>');
    fprintf(fid,'\n</HTML>\n');
end

function str=define_styles
    styles=[...
    'p.issueLabel {margin-left: 20px; font-weight: bold}',sprintf('\n')...
    ,'p.moreindent {margin-left: 45px}',sprintf('\n')...
    ,'p.options {margin-left: 45px;line-height: 160%}',sprintf('\n')...
    ,'table.minimumBorder {border-collapse: collapse;}',sprintf('\n')...
    ,'h3.red {color:red}',sprintf('\n')...
    ,'h3.green {color:green}',sprintf('\n')...
    ];
    str=sprintf('<style type="text/css">\n%s</style>\n',styles);
end

function write_header(fid,header,level)
    fprintf(fid,'\n<h%d>%s</h%d>\n',level,header,level);
end

function write_timestamp(fid,docname)
    nowDate=date;
    nowTime=clock;
    nowTimestamp=sprintf('%s %d:%d',nowDate,nowTime(4),nowTime(5));
    fprintf(fid,'<i>%s %s</i> \n',getString(message('Slvnv:rmiref:Check:writeReport:GeneratedOn')),nowTimestamp);
    recheck=['matlab: ',sprintf('rmiref.checkDoc(''%s'');',strrep(docname,'\','/'))];
    fprintf(fid,[' [',make_link(recheck,getString(message('Slvnv:rmiref:Check:writeReport:Refresh'))),']']);
    fprintf(fid,'<br>\n');
end

function write_summary_info(fid,summary)
    fprintf(fid,'<p>&nbsp;</p>\n');
    fprintf(fid,'\n<p class="moreindent">');

    fprintf(fid,'<table>\n');
    widths=[300,300];
    rowspans=[1,1];
    fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocName')),'</b>'],summary.docname));
    fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocLocation')),'</b>'],summary.location));
    fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocLastSaved')),'</b>'],summary.modified));
    fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTotalLinks')),'</b>'],num2str(summary.totalLinks)));
    fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTotalModels')),'</b>'],num2str(summary.totalModels)));

    if summary.totalBad>0
        dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryBrokenLinks',num2str(summary.totalBad)));
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b><font color="red">',dispStr,'</font></b>']));
        totalInvalid=summary.totalBad-summary.badModels-summary.badObjects;
        if totalInvalid>0
            dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryInvalidCommands'));
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<font color="red">&nbsp;&nbsp;&nbsp;&nbsp;',dispStr,'</font>'],link_if_any(totalInvalid,'invalid')));
        end
        if summary.badModels>0
            dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryUnresolvedModels'));
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<font color="red">&nbsp;&nbsp;&nbsp;&nbsp;',dispStr,'</font>'],link_if_any(summary.badModels,'models')));
        end
        if summary.badObjects>0
            dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryUnresolvedObjects'));
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<font color="red">&nbsp;&nbsp;&nbsp;&nbsp;',dispStr,'</font>'],link_if_any(summary.badObjects,'objects')));
        end
    else
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:NoBrokenLinks')),'</b>']));
    end
    totalFixed=summary.pathsFixed+summary.labelsFixed;
    if totalFixed>0
        dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryFixedLinks',num2str(totalFixed)));
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b><font color="darkGreen">',dispStr,'</font></b>']));
        if summary.pathsFixed>0
            dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryFixedPaths'));
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<font color="darkGreen">&nbsp;&nbsp;&nbsp;&nbsp;',dispStr,'</font>'],link_if_any(summary.pathsFixed,'paths')));
        end
        if summary.labelsFixed>0
            dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryFixedLabels'));
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<font color="darkGreen">&nbsp;&nbsp;&nbsp;&nbsp;',dispStr,'</font>'],link_if_any(summary.labelsFixed,'labels')));
        end
    end
    if summary.isOneWay>0
        dispStr=getString(message('Slvnv:rmiref:Check:writeReport:SummaryOneWayLinks'));
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',dispStr,'</b>'],link_if_any(summary.isOneWay,'oneway')));
    end
    if summary.skipped>0
        dispStr=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedLinks'));
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b><font color="blud">',dispStr,'</color></b>'],link_if_any(summary.skipped,'skipped')));
    end

    fprintf(fid,'</table>\n');
    fprintf(fid,'</p>\n');
end


function dispStr=link_if_any(count,anchor)
    if count==0
        dispStr='none';
    elseif count==1
        dispStr=sprintf('<a href="#%s">%d item</a>',anchor,count);
    else
        dispStr=sprintf('<a href="#%s">%d items</a>',anchor,count);
    end
end


function write_section(fid,title,myLinks,anchor,color,sessionId)
    fprintf(fid,'<p>&nbsp;</p>\n');
    totals=[num2str(length(myLinks)),' link'];
    if length(myLinks)>1
        totals=[totals,'s'];
    end
    if strcmp(anchor,'skipped')


        uniqueDetails=unique({myLinks.issue});
    else
        uniqueDetails=unique({myLinks.details});
    end
    if~strcmp(color,'black')&&~strcmp(anchor,'oneway')

        problems=[num2str(length(uniqueDetails)),' unique problem'];
        if length(uniqueDetails)>1
            problems=[problems,'s'];
        end
        totals=[problems,' in ',totals];
    end
    write_header(fid,sprintf('<a name="%s"><font color="%s">%s</font> - <i>%s</i></a>',anchor,color,title,totals),3);
    fprintf(fid,'\n<p class="moreindent">');
    fprintf(fid,'\n<table class="minimumBorder" border="1" cellpadding="5">\n');
    widths=[500,500];
    rowspans=[1,1];
    switch anchor
    case 'invalid'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocCommand')),'</b>']));
    case 'models'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTargetModel')),'</b>']));
    case 'objects'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTargetObject')),'</b>']));
    case 'paths'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocModelPath')),'</b>']));
    case 'labels'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocReferenceLabel')),'</b>']));
    case 'functional'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTargetInSimulink')),'</b>']));
    case 'oneway'
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocTargetInSimulink')),'</b>']));
    case 'skipped'
        widths=[300,300,400];
        rowspans=[1,1,1];
        fprintf(fid,'%s\n',html_table_row(widths,rowspans,['<b>',getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedLinkType')),'</b>'],...
        ['<b>',getString(message('Slvnv:rmiref:Check:writeReport:DocContent')),'</b>'],['<b>',getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedLinkTarget')),'</b>']));
    otherwise
        error(message('Slvnv:rmiref:Check:writeReport:InvalidSectionType',anchor));
    end
    for i=1:length(uniqueDetails)
        details=uniqueDetails{i};
        if strcmp(anchor,'skipped')

            moreWidths={details,widths};
            take=strcmp({myLinks.issue},details);
            subset=myLinks(take);
            write_table_rows(fid,moreWidths,{subset.docText},{subset.details},{subset.idx},sessionId,color);
        else
            take=strcmp({myLinks.details},details);
            subset=myLinks(take);

            write_table_rows(fid,widths,{subset.docText},{details},{subset.idx},sessionId,color);
        end
    end
    fprintf(fid,'</table></p>\n');
end


function write_table_rows(fid,widths,column1,column2,idx,sessionId,color)
    if iscell(widths)

        column0=widths{1};
        widths=widths{2};
    else
        column0='';
    end
    if length(column2)==1&&length(column1)>1
        rowspans=[1,length(column1)];
    elseif~isempty(column0)
        rowspans=[length(column1),1,1];
    else
        rowspans=[1,1];
    end
    for j=1:length(column1)
        docURL=make_doc_url(sessionId,idx{j});
        txt1=htmlEscape(column1{j});
        linkToDocument=make_link(docURL,txt1);
        if j>length(column2)
            col2='';
        else
            txt2=htmlEscape(column2{j});
            if needsHyperlinkToTarget(color,column0)
                slURL=make_sl_url(sessionId,idx{j});
                details=txt2;
                fixed=strfind(details,' -> ');
                if isempty(fixed)
                    col2=make_link(slURL,details);
                else
                    col2=['<font color="red">',details(1:fixed(1)),'</font> -&gt; ',make_link(slURL,details(fixed(1)+4:end))];
                end
            elseif strcmp(color,'red')
                [tkn,rem]=strtok(txt2,'( ');
                if strncmp(tkn,'GIDa_',length('GIDa_'))&&length(tkn)>10
                    tkn=[getString(message('Slvnv:rmiref:Check:writeReport:TargetObjectIdEndingWith'))...
                    ,tkn(end-10:end)];
                end
                col2=['<font color="red">',tkn,'</font>',rem];
            else
                col2=txt2;
            end
        end
        if~isempty(column0)

            fprintf(fid,'%s\n',html_table_row(widths,rowspans,column0,linkToDocument,strrep(col2,'\','\\')));
            rowspans=[0,1,1];
        else
            fprintf(fid,'%s\n',html_table_row(widths,rowspans,linkToDocument,strrep(col2,'\','\\')));
            rowspans=[1,0];
        end
    end
end

function yesno=needsHyperlinkToTarget(color,type)
    if any(strcmp(color,{'black','darkGreen'}))
        yesno=true;
    else

        multiLinkIssue=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedMultilink'));
        yesno=(strcmp(color,'blud')&~strcmp(type,multiLinkIssue));
    end
end

function out=htmlEscape(in)
    out=strrep(in,'&','&amp;');
    out=strrep(out,'<','&lt;');
    out=strrep(out,'>','&gt;');
end

function out=html_table_row(widths,rowspans,varargin)
    out='<tr>';
    for i=1:length(varargin)
        if rowspans(i)==0
            continue;
        elseif rowspans(i)==1
            span='';
        else
            span=[' rowspan="',num2str(rowspans(i)),'"'];
        end
        if i<=length(widths)
            width=[' width="',num2str(widths(i)),'"'];
        else
            width='';
        end
        out=[out,sprintf('<td%s%s>',span,width),varargin{i},'</td>'];%#ok<AGROW>
    end
    out=[out,'</tr>'];
end

function out=make_link(url,label)
    out=sprintf('<a href="%s">%s</a>',url,label);
end

function out=make_doc_url(sessionId,idx)
    out=['matlab: ',sprintf('rmiref.docCheckCallback(''viewInDocument'', ''%s'', %d);',sessionId,idx)];
end

function out=make_sl_url(sessionId,idx)
    out=['matlab: ',sprintf('rmiref.docCheckCallback(''viewInSimulink'', ''%s'', %d);',sessionId,idx)];
end
