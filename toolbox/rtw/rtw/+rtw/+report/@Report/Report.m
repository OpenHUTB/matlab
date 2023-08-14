


classdef Report<handle
    properties
        ReportFileName='';
        Doc='';
    end
    properties(Hidden=true,Access=private)
        toc='';
        BuildDir='';
        bGenHyperlink=false;
        bHasShrinkButton=false;
        sectionNum=0;
        html_id=0;
        TableID=0;
    end
    methods
        function rpt=Report(reportFileName,buildDir,bGenHyperlink)
            rpt.ReportFileName=reportFileName;
            rpt.bGenHyperlink=bGenHyperlink;
            rpt.BuildDir=buildDir;

            rpt.Doc=Advisor.Document;
            rpt.toc=Advisor.List;
            rpt.setJavaScript();
            rpt.sectionNum=0;
            rpt.TableID=0;
        end
        function setOnloadFcn(rpt,jsFcn)
            rpt.Doc.setBodyAttribute('ONLOAD',jsFcn);
        end
        function setTitle(rpt,title)
            rpt.Doc.setTitle(title);
        end
        function addItem(rpt,item)
            rpt.Doc.addItem(item);
        end
        function createToc(rpt,title)
            tocTitle=Advisor.Element;
            tocTitle.setContent(title);
            tocTitle.setTag('h3');
            rpt.addItem(tocTitle);
            rpt.addItem(rpt.toc);
        end





        function html=emitHTML(rpt)
            if rpt.bHasShrinkButton
                [rptDir,~]=fileparts(rpt.ReportFileName);
                nl=sprintf('\n');
                if~exist(fullfile(rptDir,'rtwshrink.js'),'file')
                    jsfile=fullfile(matlabroot,'toolbox','shared','codergui',...
                    'web','resources','rtwshrink.js');
                    dstfile=fullfile(rptDir,'rtwshrink.js');
                    copyfile(jsfile,dstfile);
                    fileattrib(dstfile,'+w');
                end
                rpt.Doc.addHeadItem(['<SCRIPT type="text/javascript" language="JavaScript" src="rtwshrink.js"></SCRIPT>',nl]);
            end
            html=rpt.Doc.emitHTML();
        end










        function addSection(rpt,id,title,summary,contents,option)
            rpt.sectionNum=rpt.sectionNum+1;

            section=Advisor.Element;

            aTitle=Advisor.Element;
            aTitle.setTag('a');
            if option.AddSectionNumber
                aTitle.setContent([int2str(rpt.sectionNum),'. ',title]);
            else
                aTitle.setContent(title);
            end

            name=['sec_',strrep(title,' ','_')];
            aTitle.setAttribute('name',name);
            aTitle.setAttribute('id',id);
            aTitle.setTag('h3');
            if~isempty(summary)&&~isempty(contents)
                t=Advisor.Table(2,1);
                t.setBorder(0);
                t.setEntry(1,1,summary);
                t.setEntry(2,1,contents);
                t.setAttribute('width','100%');
                contents=t;
            end
            if isempty(contents)
                rpt.addItem(aTitle);
            else
                if option.AddShrinkButton
                    rpt.bHasShrinkButton=true;
                    rpt.TableID=rpt.TableID+1;
                    id=['rtwIdCodeMetrics_table_',sprintf('%03d',rpt.TableID)];
                    option.UseSymbol=false;
                    option.ShowByDefault=false;
                    option.tooltip='Click to shrink or expand section';
                    aTitle.setContent([aTitle.content,' ',rpt.getRTWTableShrinkButton(id,option)]);
                    rpt.Doc.addItem(aTitle);
                    contents.setAttribute('name',id);
                    contents.setAttribute('id',id);
                else
                    section.setContent(aTitle.emitHTML);
                    rpt.Doc.addItem(aTitle);
                end
                rpt.Doc.addItem(contents);
            end


            aHref=Advisor.Element;
            aHref.setTag('a');
            aHref.setContent(title);
            aHref.setAttribute('href',['#',name]);
            if option.AddSectionNumber
                rpt.toc.setType('Numbered');
            end
            if option.AddToToc
                rpt.toc.addItem(aHref);
            end
        end
        function table=create_tree_table(rpt,headings,...
            rows,rowIndent,...
            colWidthsInPercent,colAlignment,...
            tableId,idOffset,subTableId)
            if nargin<8
                idOffset=0;
            end
            if nargin<9
                subTableId='';
            end
            rpt.bHasShrinkButton=true;
            [nRows,nCols]=size(rows);
            if nRows~=length(rowIndent)||nCols~=length(headings)
                table=Advisor.Table(1,1);
                return;
            end
            locs=find(rowIndent==0);
            nSub=length(locs);
            table=Advisor.Table(nSub+1,1);
            table.setBorder(1);
            table.setAttribute('width','100%');
            table.setAttribute('cellpadding','0');
            table.setAttribute('cellspacing','0');
            table.setAttribute('name',tableId);
            table.setAttribute('id',tableId);
            table.setAttribute('class','treeTable');
            option.HasHeaderRow=true;
            option.HasBorder=false;
            myheadings=cell(length(headings),1);
            for i=1:length(headings)
                myheadings{i}=headings(i);
            end
            headingTable=rtw.report.Report.create_html_table(...
            myheadings,...
            option,colWidthsInPercent,colAlignment);
            table.setEntry(1,1,headingTable.emitHTML);
            nRow=0;
            rowSize=size(rows);
            mId=idOffset;
            for i=1:nSub
                i1=locs(i);
                if i==nSub
                    i2=rowSize(1);
                else
                    i2=locs(i+1);
                end
                [elem_table,mId,nRow]=loc_getSubTable(colWidthsInPercent,colAlignment,...
                rows(i1:i2,:),...
                rowIndent(i1:i2),...
                subTableId,nRow,mId);
                table.setEntry(i+1,1,elem_table.emitHTML);
            end
        end





        function emitToFile(rpt,filename)
            fid=fopen(filename,'w','n','utf-8');
            if fid<0
                DAStudio.error('RTW:utility:fileIOError',rptFileName,'open');
            end
            fwrite(fid,rpt.emitHTML,'char');
            fclose(fid);
        end




        function id=getUniqueID(rpt)
            id=num2str(rpt.html_id);
            rpt.html_id=rpt.html_id+1;
        end
    end
    methods(Access=private,Hidden=true)
        function setJavaScript(rpt)
            [rptDir,~]=fileparts(rpt.ReportFileName);
            nl=sprintf('\n');
            if exist(fullfile(rptDir,'rtwreport.css'),'file')
                rpt.Doc.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
                if rpt.bGenHyperlink

                    includeTag=false;
                    rtwHiliteJS=coder.internal.slcoderReport('getRtwHiliteJS',...
                    '',rpt.BuildDir,includeTag);
                else
                    rtwHiliteJS='';
                end

                rpt.Doc.addHeadItem(['<script language="JavaScript" type="text/javascript">',nl...
                ,'/*<![CDATA[*/',nl...
                ,rpt.getRTWRunMatlabCmd(),nl...
                ,'/*]]>*/',nl...
                ,'</script>',nl...
                ,rtwHiliteJS...
                ]);
            else
                rpt.Doc.addHeadItem(['<script language="JavaScript" type="text/javascript">',nl...
                ,'/*<![CDATA[*/',nl...
                ,rpt.getRTWRunMatlabCmd(),nl...
                ,'/*]]>*/',nl...
                ,'</script>',nl...
                ]);
            end
        end
    end
    methods(Static)




        function out=getRTWTableShrinkButton(id,option)
            if option.UseSymbol
                if option.ShowByDefault
                    text='[+]';
                else
                    text='[-]';
                end
                text_style='style="cursor:pointer;font-family:monospace;font-weight:normal;"';
                isSymbol='true';
            else
                if option.ShowByDefault
                    text='[<u>show</u>]';
                else
                    text='[<u>hide</u>]';
                end
                text_style='style="cursor:pointer;font-weight:normal;"';
                isSymbol='false';
            end
            if~isfield(option,'tooltip')
                tooltip='Click to shrink or expand table';
            else
                tooltip=option.tooltip;
            end
            out=['<span name="button_',id,'" id="button_',id,'" title="',tooltip,'" '...
            ,text_style,' onclick ="',rtw.report.Report.getRTWTableShrinkCall('this',id,isSymbol)...
            ,'"><span class="shrink-button">',text,'</span></span>'];
        end





        function out=getRTWTableShrinkCall(obj,id,isSymbol)
            out=['if (rtwTableShrink) rtwTableShrink(window.document, ',obj,', ''',id,''', ',isSymbol,')'];
        end





        function out=getRTWRunMatlabCmd()
            nl=sprintf('\n');
            out=[...
            'function rtwRunMatlabCmd(cmd) {',nl...
            ,'  try { ',nl...
            ,'    window.location.href="matlab: " + cmd;',nl...
            ,'  } catch (e) { ',nl...
            ,'  } ',nl...
            ,'}'];
        end




        function table=create_html_table(contents,option,col_width_vec,align_vec)
            assert(length(col_width_vec)==length(contents));
            table=Advisor.Table(1,1);

            if isempty(contents)
                return;
            end
            numCol=length(contents);
            numRow=length(contents{1});
            if numRow==0
                return;
            end
            table=Advisor.Table(numRow,numCol);
            if option.HasBorder
                table.setBorder(1);
            else
                table.setBorder(0);
            end
            if isfield(option,'BeginWithWhiteBG')&&option.BeginWithWhiteBG
                table.setStyle('AltRowBgColorBeginWithWhite');
            else
                table.setStyle('AltRowBgColor');
            end
            table.setAttribute('width','100%');
            for i=1:numCol
                table.setColWidth(i,col_width_vec(i));
            end
            for j=1:numCol
                for i=1:numRow
                    if isempty(contents{j}{i})
                        aText=Advisor.Text('');
                    else
                        aText=Advisor.Text(contents{j}{i});
                    end
                    aText.ContentsContainHTML=true;
                    table.setEntry(i,j,aText);

                    if j>1
                        table.setEntryAlign(i,j,align_vec{j});
                    end
                end
            end
            if option.HasHeaderRow
                for j=1:numCol
                    element=Advisor.Element;
                    element.setContent(table.getEntry(1,j).emitHTML);
                    element.setTag('b');
                    table.setEntry(1,j,element);
                end
            end
            table.setAttribute('cellpadding','2');
        end
    end
end


function[table,mId,nRow]=loc_getSubTable(colWidthsInPercent,colAlignment,...
    rows,...
    rowIndent,...
    subTableId,nRow,mId)
    my_indent=rowIndent(1);
    child_indent=my_indent+1;
    locs=find(rowIndent==child_indent);
    nSub=length(locs);
    rowSize=size(rows);
    table=Advisor.Table(1+nSub,1);
    table.setBorder(0);
    table.setAttribute('width','100%');
    table.setAttribute('cellpadding','0');
    table.setAttribute('cellspacing','0');
    table.setAttribute('style','border-style: none');
    table.setAttribute('name',subTableId);
    table.setAttribute('id',subTableId);
    if my_indent>0
        table.setAttribute('style','display:none;border-style:none');
    else
        table.setAttribute('style','border-style:none');
    end
    mId=mId+1;
    id=[subTableId,'_sub',num2str(mId)];
    if nSub>0
        option.UseSymbol=true;
        option.ShowByDefault=true;
        option.tooltip='Click to shrink or expand tree';
        button=rtw.report.Report.getRTWTableShrinkButton(id,option);
    else
        prefix='&#160;&#160;';
        button=['&#160;<span style="font-family:monospace">',prefix,'</span>&#160;'];
    end
    indent='';
    indent(1:my_indent*6)=' ';
    indent=strrep(indent,' ','&#160;');
    indent=[indent,button];
    rows{1,1}=['<span>',indent,'&#160;',rows{1,1},'</span>'];
    option.HasHeaderRow=false;
    option.HasBorder=false;
    if mod(nRow,2)
        option.BeginWithWhiteBG=false;
    else
        option.BeginWithWhiteBG=true;
    end
    nCol=rowSize(2);
    myRow=cell(nCol,1);
    for i=1:nCol
        myRow{i}=rows(1,i);
    end
    contentTable=rtw.report.Report.create_html_table(myRow,option,...
    colWidthsInPercent,colAlignment);
    nRow=nRow+1;
    table.setEntry(1,1,contentTable.emitHTML);
    for i=1:nSub
        i1=locs(i);
        if i==nSub
            i2=rowSize(1);
        else
            i2=locs(i+1)-1;
        end
        [subTable,mId,nRow]=loc_getSubTable(colWidthsInPercent,colAlignment,...
        rows(i1:i2,:),...
        rowIndent(i1:i2),...
        id,nRow,mId);
        table.setEntry(i+1,1,subTable.emitHTML);
    end
end


