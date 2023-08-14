function fileTable=getHTMLFileInfo(obj)




    isForNewReport=obj.isSLReportV2;
    ccm=obj.Data;
    tables=cell(2,1);
    tableHeadings=cell(2,1);
    option.UseSymbol=true;
    option.ShowByDefault=false;
    option.tooltip=obj.msgs.shrink_button_tooltip;
    id_summary='fileInfo_summary_table';

    str_mdlref='';
    str_exclmain='';
    if ccm.hasKnownStat>0
        str_mdlref=obj.msgs.mdlref_file_msg;
    end
    excludedFiles=ccm.ExcludedFiles;
    if~isempty(excludedFiles)
        excludedFileStr=excludedFiles{1};
        for fileIdx=2:length(excludedFiles)
            excludedFileStr=[excludedFileStr,', ',excludedFiles{fileIdx}];%#ok<AGROW>
        end
        str_exclmain=[obj.msgs.exclude_msg,' ',excludedFileStr];
    end
    if isempty(str_mdlref)&&isempty(str_exclmain)
        summary_txt=obj.msgs.summary_msg;
    elseif~isempty(str_mdlref)&&~isempty(str_exclmain)
        summary_txt=[obj.msgs.summary_msg,' (',str_mdlref,', ',str_exclmain,')'];
    else
        summary_txt=[obj.msgs.summary_msg,' (',str_mdlref,str_exclmain,')'];
    end

    tableHeadings{1}=Advisor.Paragraph([rtw.report.Report.getRTWTableShrinkButton(id_summary,option),' ',summary_txt]);
    id_details='fileInfo_detail_table';

    rptFileInfo=obj.getReportFileInfo();
    allfiles={rptFileInfo.Name};
    tableHeadings{2}=Advisor.Paragraph([rtw.report.Report.getRTWTableShrinkButton(id_details,option),' ',obj.msgs.file_detail_msg]);
    [fullFileName,tf]=intersect(obj.getFileNames,allfiles);
    htmlfiles=obj.getLinks2SourceFiles();
    htmlfiles=htmlfiles(tf);
    file_no_html=setdiff(allfiles,fullFileName);
    if ccm.hasKnownStat
        mdlRefFileList={ccm.KnownStat.FileInfo.Name};
    else
        mdlRefFileList={};
    end
    files=[fullFileName,file_no_html];

    mdlRefFiles=setdiff(mdlRefFileList,files);
    files=[files,mdlRefFiles];
    htmlfiles=[htmlfiles,cell(1,length(mdlRefFiles)+length(file_no_html))];
    fileCol=cell(size(files));
    numTotalLOC=zeros(size(files));
    numSLOC=zeros(size(files));
    mdlref_name=cell(size(files));
    dates=cell(size(files));
    nCFiles=0;
    nCppFiles=0;
    nHFiles=0;
    nSLOC=0;
    nTotalLOC=0;
    mdlFileList={rptFileInfo.Name};
    refIdxList=ismember(files,mdlRefFiles);
    for k=1:length(files)
        fileName=files{k};
        isRefFile=refIdxList(k);
        [aPath,aName,aExt]=fileparts(fileName);
        if k<=length(fullFileName)+length(file_no_html)

            if strcmp(aPath,ccm.BuildDir)
                mdlref_name{k}=' ';
            else
                mdlref_name{k}=['<i>',obj.msgs.share_msg,'</i>'];
            end
            [tf,loc]=ismember(fileName,mdlFileList);
            assert(tf==true)
            aFileInfo=rptFileInfo(loc);
        else

            [tf,loc]=ismember(fileName,mdlRefFileList);
            assert(tf==true);
            aFileInfo=ccm.KnownStat.FileInfo(loc);
            refMdlName=aFileInfo.MdlRef;
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
            mdlref_name{k}=aElement.emitHTML;
        end
        numTotalLOC(k)=aFileInfo.NumTotalLines;
        numSLOC(k)=aFileInfo.NumCodeLines;
        dates{k}=datestr(aFileInfo.Datenum,'mm/dd/yyyy HH:MM PM');
        htmlfileFullName=htmlfiles{k};
        if~isempty(htmlfileFullName)
            if~obj.htmlfileExistMap.isKey(htmlfileFullName)
                obj.htmlfileExistMap(htmlfileFullName)=exist(htmlfileFullName,'file');
            end
        end



        if~isForNewReport


            if~isempty(htmlfileFullName)&&obj.getGenHyperlinkFlag()&&...
                (obj.InReportInfo||obj.htmlfileExistMap(htmlfileFullName))
                fileNameEntry=Advisor.Element;
                fileNameEntry.setTag('a');
                fileNameEntry.setAttribute('href',htmlfiles{k});
                fileNameEntry.setContent([aName,aExt])
                fileNameEntry.setAttribute('class','code2code');
                fileCol{k}=fileNameEntry.emitHTML;
            else
                fileCol{k}=[aName,aExt];
            end
        else


            if obj.getGenHyperlinkFlag()


                codeLoc=[aName,aExt];


                fileNameEntry=Advisor.Element;
                fileNameEntry.setContent(codeLoc);

                if~isRefFile
                    fileNameEntry.setTag('a');
                    fileNameEntry.setAttribute('href','javascript: void(0)');
                    fileNameEntry.setAttribute('class','code2code');
                    fileNameEntry.setAttribute('onclick',coder.report.internal.getPostParentWindowMessageCall('jumpToCode',codeLoc));
                else

                    fileNameEntry.setTag('span');
                end


                fileCol{k}=fileNameEntry.emitHTML;
            else
                fileCol{k}=[aName,aExt];
            end
        end
        if strcmpi(aExt,'.c')
            nCFiles=nCFiles+1;
        elseif strcmpi(aExt,'.cpp')
            nCppFiles=nCppFiles+1;
        elseif strcmpi(aExt,'.h')||strcmpi(aExt,'.hpp')
            nHFiles=nHFiles+1;
        else
            continue
        end
        nSLOC=nSLOC+aFileInfo.NumCodeLines;
        nTotalLOC=nTotalLOC+aFileInfo.NumTotalLines;
    end

    [numSLOC,tf]=sort(numSLOC,'descend');
    fileCol=fileCol(tf);
    numTotalLOC=numTotalLOC(tf);
    slocs=loc_int2str(numSLOC)';
    sizes=loc_int2str(numTotalLOC)';
    dates=dates(tf);
    mdlref_name=mdlref_name(tf);
    if obj.Data.targetisCPP
        col1={['<span style="white-space:nowrap" title="',obj.msgs.c_file_header,'">',obj.msgs.num_of_cpp_files,'</span>'],['<span style="white-space:nowrap" title="',obj.msgs.h_file_header,'">',obj.msgs.num_of_h_files,'</span>'],obj.msgs.loc,obj.msgs.lines_header};
        col2={':',':',':',':'};
        col3=[loc_int2str(nCppFiles),loc_int2str(nHFiles),loc_int2str(nSLOC),loc_int2str(nTotalLOC)];
    else
        col1={['<span style="white-space:nowrap" title="',obj.msgs.c_file_header,'">',obj.msgs.num_of_c_files,'</span>'],['<span style="white-space:nowrap" title="',obj.msgs.h_file_header,'">',obj.msgs.num_of_h_files,'</span>'],obj.msgs.loc,obj.msgs.lines_header};
        col2={':',':',':',':'};
        col3=[loc_int2str(nCFiles),loc_int2str(nHFiles),loc_int2str(nSLOC),loc_int2str(nTotalLOC)];
    end
    option.HasHeaderRow=false;
    option.HasBorder=false;
    table=obj.createTable({col1,col2,col3,cell(size(col2))},option,[1,1,1,20],{'left','left','right','right'});
    table.setStyle('Default');
    table.setAttribute('width','50%');
    table.setAttribute('cellpadding','0');
    table.setAttribute('name',id_summary);
    table.setAttribute('id',id_summary);
    tables{1}=table;
    col1=[obj.msgs.file_name_header,fileCol];
    col2=[obj.msgs.loc_header,slocs];
    col3=[obj.msgs.lines_header,sizes];
    col4=[obj.msgs.mdlref_header,mdlref_name];
    col5=[obj.msgs.modified_date_header,dates];
    option.HasHeaderRow=true;
    option.HasBorder=true;
    if ccm.hasKnownStat>0
        table=obj.createTable({col1,col2,col3,col4,col5},option,[2,1,1,1,1],{'left','right','right','right','right'});
    else
        table=obj.createTable({col1,col2,col3,col5},option,[3,2,2,2],{'left','right','right','right'});
    end
    table.setAttribute('name',id_details);
    table.setAttribute('id',id_details);
    tables{2}=table;
    fileTable=Advisor.Table(2,1);
    fileTable.setBorder(0);
    fileTable.setAttribute('width','100%');
    for i=1:length(tables)
        fileTable.setEntry(i,1,[tableHeadings{i}.emitHTML,tables{i}.emitHTML]);
    end
end


