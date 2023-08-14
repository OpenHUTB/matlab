function fillFileInformation(obj,chapter)
    import mlreportgen.dom.*;
    ccm=obj.Data;

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

    p=Paragraph(Text(summary_txt));
    p.Style={Bold};
    chapter.append(p);

    rptFileInfo=obj.Data.getReportFileInfo();
    allfiles={rptFileInfo.Name};
    fullFileName=intersect(obj.getFileNames,allfiles);
    file_no_html=setdiff(allfiles,fullFileName);
    if ccm.hasKnownStat
        mdlRefFileList={ccm.KnownStat.FileInfo.Name};
    else
        mdlRefFileList={};
    end
    files=[fullFileName,file_no_html];

    mdlRefFiles=setdiff(mdlRefFileList,files);
    files=[files,mdlRefFiles];
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
    for k=1:length(files)
        fileName=files{k};
        [aPath,aName,aExt]=fileparts(fileName);
        if k<=length(fullFileName)+length(file_no_html)

            if strcmp(aPath,ccm.BuildDir)
                mdlref_name{k}=' ';
            else
                mdlref_name{k}=obj.msgs.share_msg;
            end
            [tf,loc]=ismember(fileName,mdlFileList);
            assert(tf==true)
            aFileInfo=rptFileInfo(loc);
        else

            [tf,loc]=ismember(fileName,mdlRefFileList);
            assert(tf==true);
            aFileInfo=ccm.KnownStat.FileInfo(loc);
            mdlref_name{k}=aFileInfo.MdlRef;
        end
        numTotalLOC(k)=aFileInfo.NumTotalLines;
        numSLOC(k)=aFileInfo.NumCodeLines;
        dates{k}=datestr(aFileInfo.Datenum,'mm/dd/yyyy HH:MM PM');
        fileCol{k}=[aName,aExt];
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
        col1={obj.msgs.num_of_cpp_files,obj.msgs.num_of_h_files,obj.getMessage('LOCHeaderText'),obj.getMessage('LineHeaderText')}';
        col2={':',':',':',':'}';
        col3=[loc_int2str(nCppFiles),loc_int2str(nHFiles),loc_int2str(nSLOC),loc_int2str(nTotalLOC)]';
    else
        col1={obj.msgs.num_of_c_files,obj.msgs.num_of_h_files,obj.getMessage('LOCHeaderText'),obj.getMessage('LineHeaderText')}';
        col2={':',':',':',':'}';
        col3=[loc_int2str(nCFiles),loc_int2str(nHFiles),loc_int2str(nSLOC),loc_int2str(nTotalLOC)]';
    end
    table=Table([col1,col2,col3],'TableStyleAltRowNormal');
    chapter.append(table);
    chapter.append(Paragraph);
    col1=[obj.getMessage('FileNameHeaderText'),fileCol]';
    col2=[obj.getMessage('LOCHeaderText'),slocs]';
    col3=[obj.getMessage('LineHeaderText'),sizes]';
    col4=[obj.getMessage('MdlrefHeaderText'),mdlref_name]';
    col5=[obj.getMessage('ModifiedDataHeaderText'),dates]';
    if ccm.hasKnownStat>0
        table=Table([col1,col2,col3,col4,col5],'TableStyleAltRowRightAlign');
    else
        table=Table([col1,col2,col3,col5],'TableStyleAltRowRightAlign');
    end
    p=Paragraph(Text(obj.msgs.file_detail_msg));
    p.Style={Bold};
    chapter.append(p);
    chapter.append(table);
    chapter.append(Paragraph);
end
