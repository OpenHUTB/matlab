






function varargout=slcoderReport(function_name,varargin)

    [varargout{1:nargout}]=feval(function_name,varargin{1:end});





    function convertC2HTML(contentsFileName,currModel,bMdlRef,buildDir,reportInfo)%#ok

        currDir=pwd;
        xtester_emulate_ctrl_c('rtw_report_generate');
        try
            if~isempty(buildDir)&&exist(buildDir,'dir')


                htmlDir=[buildDir,filesep,'html'];
                if nargin<5
                    reportInfo=[];
                end
                sortedFileInfoList=reportInfo.getSortedFileInfoList;
                protectingCurrentModel=Simulink.ModelReference.ProtectedModel.protectingModel(currModel);

                cd(htmlDir);

                delete('*_trace.html');
                delete('*_trace.xml');

                bIsERTTarget=reportInfo.IsERTTarget;

                gentrace=false;
                gentracerpt=false;
                genCode2ModelTrace=false;
                if bMdlRef
                    subsys='';
                else
                    subsys=reportInfo.SourceSubsystem;
                end
                cfg=reportInfo.Config;
                hlink=strcmp(cfg.IncludeHyperlinkInReport,'on');

                if isempty(subsys)

                    rootsys=getfullname(currModel);
                else

                    if slfeature('RightClickBuild')==0
                        rootsys=strtok(subsys,'/:');
                    else
                        rootsys=currModel;
                    end
                end
                if slfeature('RightClickBuild')~=0
                    try
                        modelPath=get_param(rootsys,'FileName');
                    catch
                        load_system(rootsys);
                        modelPath=get_param(rootsys,'FileName');
                        close_system(rootsys);
                    end
                else
                    modelPath=get_param(rootsys,'FileName');
                end


                traceRequirements=true;
                bLink2Webview=reportInfo.hasWebview;

                ssHdl=[];
                newSSName='';
                if~isValidSlObject(slroot,currModel)
                    if~isempty(reportInfo.SourceSubsystem)
                        ssHdl=get_param(reportInfo.SourceSubsystem,'Handle');
                        newSSName=reportInfo.TemporaryModelFullSSName;
                    end
                else
                    ssHdl=rtwprivate('getSourceSubsystemHandle',currModel);
                    newSSName=rtwprivate('getNewSubsystemName',currModel);
                end
                if(~isempty(subsys)||isempty(coder.internal.ModelCodegenMgr.getInstance(currModel)))
                    systemMap=reportInfo.SystemMap;
                else
                    systemMap=[];
                end

                if strcmp(cfg.GenerateTraceInfo,'on')
                    gentrace=true;
                end
                if strcmp(cfg.IncludeHyperlinkInReport,'on')&&rtw.report.ReportInfo.DisplayInCodeTrace
                    genCode2ModelTrace=true;
                end
                if strcmp(cfg.GenerateTraceReport,'on')||...
                    strcmp(cfg.GenerateTraceReportSl,'on')||...
                    strcmp(cfg.GenerateTraceReportSf,'on')||...
                    strcmp(cfg.GenerateTraceReportEml,'on')
                    gentracerpt=true;
                end


                bGenHTMLFile=~rtw.report.ReportInfo.DisplayInCodeTrace||reportInfo.hasWebview;
                bBlockSIDComment=coder.internal.isBlockSIDCommentEnabled(rootsys);
                arg={hlink,currModel,ssHdl,newSSName,...
                modelPath,buildDir,traceRequirements,bLink2Webview,bBlockSIDComment,systemMap,...
                bGenHTMLFile,fullfile(htmlDir,'define.js'),fullfile(htmlDir,filesep)};
                [nempty,ndisabled,inEncoding]=rtwprivate('rtwctags',sortedFileInfoList.FileName,...
                arg,true,...
                sortedFileInfoList.HtmlFileName,...
                gentrace||gentracerpt,'utf-8',protectingCurrentModel);
                reportInfo.Encoding=inEncoding;
                loc_exportFileLinks(reportInfo);
                if hlink&&nempty>0&&ndisabled>0
                    MSLDiagnostic('RTW:utility:hyperlinksDisabled').reportAsWarning;
                end


                traceRptName=getTraceReportFileName(currModel,htmlDir);
                hasComments=strcmp(reportInfo.Config.GenerateComments,'on');
                bSaveTraceInfo=(gentrace||gentracerpt||(bLink2Webview&&hlink));
                if slfeature('CommentOffTrace')==0
                    bSaveTraceInfo=bSaveTraceInfo&&hasComments;
                end

                if(genCode2ModelTrace&&hasComments&&...
                    (~bSaveTraceInfo||(bSaveTraceInfo&&~gentrace)))
                    filename=fullfile(reportInfo.getReportDir,[currModel,'_traceInfo.js']);
                    fid=fopen(filename,'w','n','utf-8');
                    tmp_registry=rtwprivate('rtwctags_registry','get');
                    genRTWnameSIDMap(fid,tmp_registry,reportInfo.SystemMap,rootsys,reportInfo.SourceSubsystem,true);
                    if~bSaveTraceInfo


                        rtwprivate('rtwctags_registry','reset');
                    end
                    fclose(fid);
                end
                if bSaveTraceInfo


                    traceInfo_fileList={};
                    for n=1:sortedFileInfoList.NumFiles
                        if(isequal(fileparts(sortedFileInfoList.FileName{n}),buildDir)||...
                            isequal(fileparts(sortedFileInfoList.FileName{n}),'$(BuildDir)'))
                            traceInfo_fileList{length(traceInfo_fileList)+1}=sortedFileInfoList.FileName{n};%#ok<AGROW>
                        end
                    end
                    h=saveTraceInfo(rootsys,buildDir,traceInfo_fileList,bMdlRef,subsys,currModel,reportInfo);
                    generateHighlightMessageFile(fullfile(htmlDir,'rtwmsg.html'));
                    fpath=fileparts(traceRptName);
                    if gentrace

                        h.emitJS(fullfile(fpath,[currModel,'_traceInfo.js']));
                    end
                    if bLink2Webview
                        h.emitSidMapJS(fullfile(fpath,[currModel,'_sid_map.js']));
                    end
                    if gentracerpt
                        generateTraceReport(h,traceRptName,cfg);
                    else
                        generateEmptyTraceReport(traceRptName,currModel);
                    end
                else
                    clearTraceInfo(rootsys,htmlDir);
                    if bIsERTTarget&&~protectingCurrentModel
                        generateEmptyTraceReport(traceRptName,currModel);
                    end
                end

                if bIsERTTarget
                    if strcmp(cfg.GenerateCodeMetricsReport,'on')&&~protectingCurrentModel





                        isSubsystemModelClosed=~isempty(reportInfo.SourceSubsystem)&&...
                        ~isValidSlObject(slroot,currModel);
                        isRegularModelNotInBuild=isValidSlObject(slroot,currModel)&&...
                        isempty(coder.internal.ModelCodegenMgr.getInstance(currModel));
                        if(isSubsystemModelClosed||isRegularModelNotInBuild)



                            if~slfeature('DecoupleCodeMetrics')||reportInfo.isInstrBuild
                                CMSaveDirectory=reportInfo.getReportDir;
                            else
                                CMSaveDirectory=fullfile(reportInfo.StartDir,reportInfo.ModelRefRelativeBuildDir,'tmwinternal');
                            end
                            rtw.report.CodeMetrics.generateStaticCodeMetrics(reportInfo,reportInfo.getBuildInfo(),...
                            CMSaveDirectory,subsys,true);
                        else
                            genTempCodeMetricsReport(currModel,buildDir);
                        end
                    elseif~protectingCurrentModel
                        generateEmptyMetricsReport(...
                        getCodeMetricsReportFileName(currModel,fullfile(buildDir,'html')),currModel);
                    end
                end
                jsfile=fullfile(matlabroot,'toolbox','shared','codergui','web','resources','rtwshrink.js');
                dstfile=fullfile(buildDir,'html','rtwshrink.js');
                coder.internal.coderCopyfile(jsfile,dstfile);
            end
        catch e
            cd(currDir);
            rethrow(e);
        end
        cd(currDir);






        function dirFiles=getFilesInBuildFolder(buildDir)

            extensions={'c','cpp','h'};
            pilDir=fullfile(buildDir,'pil');
            silDir=fullfile(buildDir,'sil');
            refDir=fullfile(buildDir,'referenced_model_includes');
            instrDir=fullfile(buildDir,'instrumented');
            stubDir=fullfile(buildDir,'stub');
            htmlDir=fullfile(buildDir,'htmlDir');
            coderAssumptionsDir=coder.assumptions.CoderAssumptions.getBuildFolder(...
            buildDir);
            dirFiles=rtwprivate('rtwfindfile',buildDir,extensions,...
            {pilDir,...
            silDir,...
            htmlDir,...
            refDir,...
            stubDir,...
            instrDir,...
            coderAssumptionsDir});
            if~isempty(dirFiles)








                tmpsrcFiles={};
                tmpsrcFilesNameOnly={};
                for idx=1:length(dirFiles)
                    [pathstr,srcFileName,srcFileExt]=fileparts(dirFiles{idx});
                    dupnameidex=find(ismember(tmpsrcFilesNameOnly,[srcFileName,srcFileExt])==1);
                    if isempty(dupnameidex)
                        tmpsrcFilesNameOnly{end+1}=[srcFileName,srcFileExt];%#ok<AGROW>
                        tmpsrcFiles{end+1}=dirFiles{idx};%#ok<AGROW>
                    else
                        if strncmp(fliplr(pathstr),fliplr(buildDir),length(buildDir))
                            tmpsrcFiles{dupnameidex}=dirFiles{idx};%#ok<AGROW>
                        end
                    end
                end
                dirFiles=tmpsrcFiles;
            end




            function out=getGeneratedFilesPanel(sortedFileInfoList,srcFiles_cat,categoriesId,categoriesMsg,htmlDir,reportInfo)





                expand_file_category=zeros(1,length(categoriesId));

                expand_cat_list={'Main','Model','Subsystem','Data'};
                for c=expand_cat_list
                    idx=strncmp(c,categoriesId,length(c{1}));
                    expand_file_category(idx)=1;
                end



                table_size=1;
                for i=1:length(categoriesId)
                    if~isempty(srcFiles_cat{i})
                        table_size=table_size+1;
                    end
                end

                table=Advisor.Table(table_size,1);
                table.setBorder(0);
                table.setAttribute('cellspacing','0');
                table.setAttribute('cellpadding','4');
                table.setAttribute('width','100%');
                table.setAttribute('bgcolor','#ffffff');
                txt=Advisor.Text;
                genFilesTitle=reportInfo.getGenFilesTitle();
                txt.setContent(genFilesTitle);
                txt.setBold(1);
                table.setEntry(1,1,txt);
                table_cnt=1;
                file_idx=1;
                for i=1:length(categoriesId)
                    if~isempty(srcFiles_cat{i})











                        category_table=Advisor.Table(2,2);
                        category_table.setBorder(0);
                        category_table.setAttribute('cellspacing','0');
                        category_table.setAttribute('cellpadding','1');
                        category_table.setAttribute('width','100%');
                        category_table.setAttribute('bgcolor','#ffffff');
                        category_table.setAttribute('id',categoriesId{i});
                        category_table.setAttribute('label',categoriesMsg{i});


                        category_table.setColWidth(1,0);
                        category_table.setColWidth(2,1);


                        category_table.setEntry(1,1,getRTWTableShrinkButton(categoriesId{i},...
                        categoriesMsg{i},...
                        expand_file_category(i),...
                        length(srcFiles_cat{i})));




                        if expand_file_category(i)
                            txt=categoriesMsg{i};
                        else
                            txt=[categoriesMsg{i},' (',num2str(length(srcFiles_cat{i})),')'];
                        end
                        category_table.setEntry(1,2,['<span id="',categoriesId{i},'_name"><b>',txt,'</b></span>']);



                        category_table.setEntry(2,1,['<span id="',categoriesId{i},'_indent"></span>']);


                        fileList_table=Advisor.Table(length(srcFiles_cat{i}),1);
                        fileList_table.setBorder(0);
                        fileList_table.setAttribute('cellspacing','0');
                        fileList_table.setAttribute('cellpadding','4');
                        fileList_table.setAttribute('width','100%');
                        fileList_table.setAttribute('bgcolor','#ffffff');
                        fileList_table.setAttribute('id',[categoriesId{i},'_table']);
                        if~expand_file_category(i)
                            fileList_table.setAttribute('style','display:none');
                        end
                        cnt=1;
                        for file=srcFiles_cat{i}
                            ref=Advisor.Element;
                            ref.setTag('A');
                            filechar=cell2mat(file);
                            [~,fname,ext]=fileparts(filechar);


                            if strcmp(categoriesId{i},'Shared')
                                href_value=rtwprivate('rtwGetRelativePath',sortedFileInfoList.HtmlFileName{file_idx},htmlDir);
                                ref.setAttribute('HREF',href_value);
                            else
                                ref.setAttribute('HREF',getHTMLFileName(filechar));
                            end
                            ref.setAttribute('TARGET','rtwreport_document_frame');
                            ref.setAttribute('ONCLICK','if (top) if (top.tocHiliteMe) top.tocHiliteMe(window, this, false);');
                            ref.setAttribute('ID',getHTMLFileName(filechar));
                            ref.setAttribute('NAME','rtwIdGenFileLinks');
                            ref.setContent([fname,ext]);
                            span='<span> </span>';
                            fileList_table.setEntry(cnt,1,[ref.emitHTML,span]);
                            cnt=cnt+1;
                            file_idx=file_idx+1;
                        end
                        category_table.setEntry(2,2,fileList_table);
                        table_cnt=table_cnt+1;
                        table.setEntry(table_cnt,1,category_table.emitHTML);
                    end
                end
                out=table;






                function htmlFileName=getHTMLFileName(filename)
                    [~,fname,ext]=fileparts(filename);
                    htmlFileName=[fname,'_',ext(2:end),'.html'];




                    function recReport=getStateflowSourceFiles()
                        mdlName=bdroot;
                        [~,mexf]=inmem;
                        sfIsHere=any(strcmp(mexf,'sf'));
                        if(sfIsHere)
                            machineId=sf('find','all','machine.name',mdlName);
                            if~isempty(machineId)&&machineId~=0
                                charts=sf('find','all','chart.machine',machineId);
                                targets=sf('TargetsOf',machineId);
                                rtwTargetId=sf('find',targets,'.name','rtw');
                                makeinfo=sfc('makeinfo',rtwTargetId,rtwTargetId);
                                recReport.NumberOfStateflowFiles=length(charts);
                                for k=1:length(charts)
                                    recReport.Chart(k).Name=[mdlName,'/',sf('get',charts(k),'.name')];
                                    recReport.Chart(k).File=makeinfo.fileNameInfo.chartUniqueNames{k};
                                end
                            end
                        end





                        function string=rtwSerialize(record)
                            if isstruct(record)
                                string=' {';
                                fieldNames=fieldnames(record);
                                for i=1:length(fieldNames)
                                    fieldName=char(fieldNames(i));
                                    field=eval(['record.',fieldName]);
                                    if ischar(field)
                                        string=[string,' ',fieldName,' "',field,'" '];%#ok<AGROW>
                                    else
                                        for j=1:length(field)
                                            string=[string,' ',fieldName];%#ok<AGROW>
                                            string=[string,' ',rtwSerialize(field(j))];%#ok<AGROW>
                                        end
                                    end
                                end
                                string=[string,' }'];
                            else
                                string=[' ',num2str(record)];
                            end





                            function doclink=expandLink(tagfile,tagname)
                                persistent lastfile;
                                persistent fileContents;
                                [tagpath,filename]=fileparts(tagfile);

                                if(isempty(lastfile)||~strcmp(lastfile,filename))&&exist(tagfile,'file')
                                    lastfile=filename;
                                    fid=fopen(tagfile,'r');
                                    if fid==-1
                                        DAStudio.error('RTW:utility:fileIOError',tagfile,'read');
                                    end
                                    fileContents=fread(fid,'*char')';
                                    fclose(fid);
                                end
                                l=length(tagname);
                                p=strfind(fileContents,tagname);
                                if~isempty(p)
                                    link=strrep(fileContents(p(1)+l:p(2)+l),' ','');
                                    p=strfind(link,'..');
                                    if~isempty(p)
                                        l=strfind(tagpath,filesep);
                                        doclink=[tagpath(1:l(end+1-length(p))-1),link(p(end)+2:end)];
                                    else
                                        doclink=[tagpath,filesep,link];
                                    end
                                else
                                    doclink='';
                                end





                                function retVal=getSubsysDiag(currModel,fileName,hlink,varargin)
                                    diagInfo=get_param(currModel,'CodeReuseDiagnostics');

                                    if isempty(diagInfo)
                                        return
                                    end

                                    useReportInfo=false;
                                    if nargin==3||isempty(varargin{1})
                                        reportPage=[];
                                    else
                                        reportPage=varargin{1};
                                        useReportInfo=true;
                                    end

                                    tSt='<TR>';
                                    tEn='</TR>';
                                    eSt='<TD>';
                                    eEn='</TD>';
                                    bSt='<B>';
                                    bEn='</B>';

                                    tHead=[tSt,...
                                    eSt,bSt,'Subsystem',bEn,eEn,...
                                    eSt,bSt,'Reuse Setting',bEn,eEn,...
                                    eSt,bSt,'Reuse Outcome',bEn,eEn,...
                                    eSt,bSt,'Outcome Diagnostic',bEn,eEn,...
                                    tEn];


                                    retVal=cell(1,1+length(diagInfo));
                                    retVal{1}=tHead;
                                    for i=1:length(diagInfo)
                                        if useReportInfo
                                            nameCol=sprintf('<S%d>',diagInfo(i).SystemID);
                                        else
                                            nameCol=sprintf('&lt;S%d&gt;',diagInfo(i).SystemID);
                                        end

                                        if hlink
                                            nameCol=getSIDHyperlink(diagInfo(i).BlockSID,currModel,nameCol,reportPage);
                                        end
                                        if~isempty(diagInfo(i).Blockers)
                                            exStr='<FONT COLOR="red">[exceptions]</FONT>';
                                            blkerCol=['<A HREF="',fileName,'#S',...
                                            int2str(diagInfo(i).SystemID),'blker"',...
'TARGET="rtwreport_document_frame">'...
                                            ,exStr,'</A>'];
                                        else
                                            blkerCol='<FONT COLOR="green">normal</FONT>';
                                        end
                                        userSetCol=diagInfo(i).UserReuseFlag;

                                        rSetCol=diagInfo(i).ReuseFlag;
                                        if(strncmp(rSetCol,'Reus',4)||strncmp(rSetCol,'Func',4))&&...
                                            ~isempty(diagInfo(i).FileName)&&~isempty(diagInfo(i).FcnName)
                                            link=['<A HREF="',diagInfo(i).FileName,'_c.html#fcn_',...
                                            diagInfo(i).FcnName,'" TARGET="rtwreport_document_frame">',...
                                            rSetCol,'</A>'];
                                        else
                                            link=rSetCol;
                                        end
                                        currStr=[tSt,...
                                        eSt,nameCol,eEn,...
                                        eSt,userSetCol,eEn,...
                                        eSt,link,eEn,...
                                        eSt,blkerCol,eEn,...
                                        tEn];
                                        retVal{i+1}=currStr;
                                    end

                                    return








                                    function retVal=getReuseBlockers(currModel,hlink)
                                        diagInfo=get_param(currModel,'CodeReuseDiagnostics');
                                        retVal={};
                                        reportPage=[];

                                        for i=1:length(diagInfo)
                                            if~isempty(diagInfo(i).Blockers)
                                                nl=newline;
                                                if hlink
                                                    nameCol=sprintf('&lt;S%d&gt;',diagInfo(i).SystemID);
                                                    nameCol=getSIDHyperlink(diagInfo(i).BlockSID,currModel,nameCol,reportPage);
                                                else
                                                    nameCol=sprintf('&lt;S%d&gt;',diagInfo(i).SystemID);
                                                end
                                                currStr=['<A NAME="S',int2str(diagInfo(i).SystemID),...
                                                'blker">','<B>Contents of ',...
                                                nameCol,...
                                                ' not reusable because:</B><BR />',nl];
                                                retVal{end+1}=currStr;%#ok<AGROW>
                                                for k=1:length(diagInfo(i).Blockers)
                                                    srcName=diagInfo(i).Blockers(k).SrcBlock;
                                                    if hlink
                                                        srcName=getSIDHyperlink(diagInfo(i).Blockers(k).SrcBlock,...
                                                        currModel,srcName,...
                                                        reportPage);
                                                    end
                                                    retVal{end+1}=['<ul>',nl];%#ok<AGROW>
                                                    retVal{end+1}=['<li>',diagInfo(i).Blockers(k).Reason,...
                                                    ' [',srcName,']</li>'];%#ok<AGROW>
                                                    retVal{end+1}=['</ul>',nl];%#ok<AGROW>
                                                end
                                            end
                                        end
                                        return



                                        function out=getSIDHyperlink(h,currModel,text,reportPage)

                                            sid=Simulink.ID.getSID(h);
                                            if isempty(reportPage)
                                                ss=rtwprivate('getSourceSubsystemHandle',currModel);
                                                if~isempty(ss)

                                                    sid=Simulink.ID.getSubsystemBuildSID(sid,ss);
                                                end
                                            else
                                                ss=reportPage.SourceSubsystem;
                                                if~isempty(ss)

                                                    sid=Simulink.ID.getSubsystemBuildSID(sid,ss);
                                                end
                                            end
                                            if isempty(sid)


                                                sanitized=contains(text,'&lt;')||...
                                                contains(text,'&gt;')||...
                                                contains(text,'&amp;');

                                                if~sanitized
                                                    out=rtwprivate('rtwhtmlescape',text);
                                                else
                                                    out=text;
                                                end
                                            else
                                                if~isempty(reportPage)&&isa(reportPage,'rtw.report.ReportPage')
                                                    out=reportPage.getHyperlink(sid,text);
                                                else
                                                    out=sprintf(...
                                                    ['<a href="javascript:top.rtwHilite(''%s'');">'...
                                                    ,'<FONT COLOR="blue"><I>%s</I></FONT></a>'],...
                                                    sid,text);
                                                end
                                            end






                                            function h=saveTraceInfo(model,buildDir,srcFiles,bMdlRef,subsys,currModel,reportInfo)

                                                h=RTW.TraceInfo.instance(model);
                                                if~isa(h,'RTW.TraceInfo')
                                                    h=RTW.TraceInfo(model);
                                                else
                                                    h.clear;
                                                end
                                                if bMdlRef
                                                    h.setBuildDir(buildDir,'-noload','-mdlref');
                                                else
                                                    h.setBuildDir(buildDir,'-noload','-standalone');
                                                end

                                                h.setRegistry(srcFiles);

                                                if~isempty(reportInfo.ReducedBlocks)
                                                    reducedBlocks=reportInfo.ReducedBlocks.Data;
                                                else
                                                    reducedBlocks=[];
                                                end
                                                if~isempty(reportInfo.InsertedBlocks)
                                                    insertedBlocks=reportInfo.InsertedBlocks.Data;
                                                else
                                                    insertedBlocks=[];
                                                end
                                                h.setTlcTraceInfo(reportInfo.Summary.TimeStamp,reducedBlocks,...
                                                insertedBlocks);


                                                h.setSubsystemInfo(subsys,currModel);


                                                h.IsTestHarness=reportInfo.IsTestHarness;
                                                if h.IsTestHarness
                                                    h.HarnessName=reportInfo.getActiveModelName;
                                                    h.HarnessOwner=reportInfo.HarnessOwner;
                                                    h.OwnerFileName=reportInfo.OwnerFileName;
                                                end

                                                h.saveTraceInfo;





                                                function clearTraceInfo(model,buildDir)
                                                    h=get_param(model,'RTWTraceInfo');
                                                    if~isempty(h)
                                                        if isa(h,'RTW.TraceInfo')
                                                            h.delete;
                                                        end
                                                        set_param(model,'RTWTraceInfo',[]);
                                                    end

                                                    matFile=fullfile(buildDir,'html','traceInfo.mat');
                                                    if exist(matFile,'file')
                                                        delete(matFile);
                                                    end





                                                    function generateTraceReport(hTrace,fname,cfg)

                                                        if isa(hTrace,'RTW.TraceInfo')
                                                            un=cfg.GenerateTraceReport;
                                                            sl=cfg.GenerateTraceReportSl;
                                                            sf=cfg.GenerateTraceReportSf;
                                                            eml=cfg.GenerateTraceReportEml;
                                                            hlink=cfg.IncludeHyperlinkInReport;
                                                            hTrace.emitHTML(fname,'-un',un,'-sl',sl,'-sf',sf,'-eml',eml,'-hyperlink',hlink);
                                                        end





                                                        function out=getTraceReportFileName(model,htmlDir)
                                                            if~ischar(model)
                                                                model=get_param(model,'Name');
                                                            end
                                                            out=fullfile(htmlDir,[model,'_trace.html']);





                                                            function out=getCodeInfoReportFileName(model,htmlDir)
                                                                if~ischar(model)
                                                                    model=get_param(model,'Name');
                                                                end
                                                                out=fullfile(htmlDir,[model,'_interface.html']);


                                                                function out=existTrace(model)
                                                                    out=existTraceInfo(model);
                                                                    if~out&&slfeature('CommentOffTrace')
                                                                        inCodeTraceInfo=coder.trace.getTraceInfo(model);
                                                                        out=~isempty(inCodeTraceInfo)&&~isempty(inCodeTraceInfo.files);
                                                                    end










                                                                    function out=existTraceInfo(model)


                                                                        try
                                                                            hTrace=RTW.TraceInfo.instance(model);
                                                                            if~isa(hTrace,'RTW.TraceInfo')
                                                                                hTrace=RTW.TraceInfo(model);
                                                                            end
                                                                            if~isempty(hTrace.BuildDir)
                                                                                out=true;
                                                                            else
                                                                                out=hTrace.existTraceInfo();
                                                                            end
                                                                        catch
                                                                            out=false;
                                                                        end


                                                                        function out=showHighlightCodeMenu(modelName)
                                                                            if nargin<1
                                                                                modelName=bdroot;
                                                                            end
                                                                            if ecoderinstalled()&&...
                                                                                strcmp(get_param(modelName,'IsERTTarget'),'on')
                                                                                out=true;
                                                                            else
                                                                                out=false;
                                                                            end









                                                                            function out=enableHighlightCodeMenu(modelName)

                                                                                if nargin<1
                                                                                    modelName=bdroot;
                                                                                end
                                                                                if strcmp(get_param(modelName,'GenerateTraceInfo'),'on')&&...
                                                                                    existTrace(modelName)
                                                                                    out=true;
                                                                                else
                                                                                    out=false;
                                                                                end





                                                                                function out=enableHighlightHDLCodeMenu(modelName)

                                                                                    if nargin<1
                                                                                        modelName=bdroot;
                                                                                    end
                                                                                    lockstatus=get_param(modelName,'lock');
                                                                                    if strcmpi(lockstatus,'on')
                                                                                        out=false;
                                                                                        return;
                                                                                    end

                                                                                    hTrace=slhdlcoder.TraceInfo.instance(modelName);
                                                                                    if~isa(hTrace,'slhdlcoder.TraceInfo')
                                                                                        hTrace=slhdlcoder.TraceInfo(modelName);
                                                                                    end

                                                                                    if~isempty(hTrace.BuildDir)
                                                                                        buildDir=hTrace.BuildDir;
                                                                                    else
                                                                                        buildDir=hTrace.getBuildDir();
                                                                                    end

                                                                                    out=false;

                                                                                    if~isempty(buildDir)
                                                                                        tInfoMat=fullfile(hTrace.BuildDirRoot,hTrace.getTraceInfoFileName);
                                                                                        if exist(tInfoMat,'file')
                                                                                            out=true;
                                                                                        end
                                                                                    end





                                                                                    function out=enableHighlightPLCCodeMenu(modelName)

                                                                                        if nargin<1
                                                                                            modelName=bdroot;
                                                                                        end
                                                                                        lockstatus=get_param(modelName,'lock');
                                                                                        if strcmpi(lockstatus,'on')
                                                                                            out=false;
                                                                                            return;
                                                                                        end

                                                                                        hTrace=PLCCoder.TraceInfo.instance(modelName);
                                                                                        if~isa(hTrace,'PLCCoder.TraceInfo')
                                                                                            hTrace=PLCCoder.TraceInfo(modelName);
                                                                                        end

                                                                                        if~isempty(hTrace.BuildDir)
                                                                                            buildDir=hTrace.BuildDir;
                                                                                        else
                                                                                            buildDir=hTrace.getBuildDir();
                                                                                        end

                                                                                        out=false;

                                                                                        if~isempty(buildDir)
                                                                                            tInfoMat=fullfile(pwd,hTrace.getTraceInfoFileName);
                                                                                            if exist(tInfoMat,'file')
                                                                                                out=true;
                                                                                            end
                                                                                        end






                                                                                        function out=getTraceDirWidgetValue(model)

                                                                                            out='';
                                                                                            try
                                                                                                hTrace=RTW.TraceInfo.instance(model);
                                                                                                if isa(hTrace,'RTW.TraceInfo')
                                                                                                    out=hTrace.BuildDir;
                                                                                                end
                                                                                            catch
                                                                                            end






                                                                                            function generateHighlightMessageFile(filename)


                                                                                                title='Block-to-Code Highlighting Message';
                                                                                                css='<link rel="stylesheet" type="text/css" href="rtwreport.css" />';


                                                                                                imgname='hilite_warning.png';
                                                                                                imgname=coder.internal.coderReport('copyIcon',fileparts(filename),imgname);
                                                                                                if~isempty(imgname)
                                                                                                    img=['<img src="',imgname,'" vspace="3px" align="top" />'];
                                                                                                else
                                                                                                    img='';
                                                                                                end


                                                                                                body=[...
                                                                                                '<p id="rtwMsg_notTraceable" style="display: none">',img,DAStudio.message('RTW:traceInfo:notTraceable','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_virtualBlock" style="display: none">',img,DAStudio.message('RTW:traceInfo:virtualBlock','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_reducedBlock" style="display: none">',img,DAStudio.message('RTW:traceInfo:reducedBlock','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_reusableFunction" style="display: none">',img,DAStudio.message('RTW:traceInfo:reusableFunction','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_blockOutsideSystem" style="display: none">',img,DAStudio.message('RTW:traceInfo:blockOutsideSystem','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_illegalCharacter" style="display: none">',img,DAStudio.message('RTW:traceInfo:illegalCharacter','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_maskedSubSystem" style="display: none">',img,DAStudio.message('RTW:traceInfo:maskedSubSystem','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_noTraceForSelectedBlocks" style="display: none">',img,DAStudio.message('RTW:traceInfo:NoTraceForSelectedBlocks'),'</p>'...
                                                                                                ,'<p id="rtwMsg_CodeGenerationReducedBlock" style="display: none">',img,DAStudio.message('RTW:traceInfo:CodeGenerationReducedBlock','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_SimulationReducedBlock" style="display: none">',img,DAStudio.message('RTW:traceInfo:SimulationReducedBlock','%s'),'</p>'...
                                                                                                ,'<p id="rtwMsg_optimizedSfObject" style="display: none">',img,DAStudio.message('RTW:traceInfo:optimizedSfObject','%s'),'</p>'...
                                                                                                ];


                                                                                                nl=newline;
                                                                                                s=[...
                                                                                                '<html><head><title>',title,'</title>',nl...
                                                                                                ,css,nl...
                                                                                                ,'<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',nl...
                                                                                                ,'</head><body onload="if (top.rtwDisplayMessage) top.rtwDisplayMessage();">',nl...
                                                                                                ,'<h1>',title,'</h1>',nl...
                                                                                                ,body,nl...
                                                                                                ,'</body></html>'];


                                                                                                fid=fopen(filename,'w','n','utf-8');
                                                                                                fprintf(fid,'%s',s);
                                                                                                fclose(fid);





                                                                                                function generateEmptyTraceReport(filename,model)
                                                                                                    title=DAStudio.message('RTW:report:TraceabilityReportTitle',model);
                                                                                                    msg=DAStudio.message('RTW:report:TraceabilityReportEmpty');
                                                                                                    bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdTraceability'),'"'];
                                                                                                    generateEmptyReport(filename,title,msg,bodyOption);





                                                                                                    function generateEmptyMetricsReport(filename,model)
                                                                                                        title=DAStudio.message('RTW:report:MetricsReportTitle',model);
                                                                                                        msg=DAStudio.message('RTW:report:MetricsReportEmpty');
                                                                                                        bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdCodeMetrics'),'"'];
                                                                                                        generateEmptyReport(filename,title,msg,bodyOption);





                                                                                                        function generateEmptyCodeInfoReport(model,htmlDir)
                                                                                                            filename=getCodeInfoReportFileName(model,htmlDir);
                                                                                                            title=['Interface of Code Generated from ',model];
                                                                                                            msg='Code interface report not generated due to an internal error.';
                                                                                                            bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdCodeInterface'),'"'];
                                                                                                            generateEmptyReport(filename,title,msg,bodyOption);





                                                                                                            function generateEmptyReport(filename,title,msg,bodyOption)
                                                                                                                css='<LINK rel="stylesheet" type="text/css" href="rtwreport.css" />';
                                                                                                                imgname='hilite_warning.png';
                                                                                                                img=['<IMG src="',imgname,'" />'];
                                                                                                                coder.internal.coderReport('copyIcon',fileparts(filename),imgname);

                                                                                                                if~isempty(bodyOption)
                                                                                                                    bodyOption=[' ',bodyOption];
                                                                                                                end
                                                                                                                nl=newline;
                                                                                                                s=[...
                                                                                                                '<HTML><HEAD><TITLE>',title,'</TITLE>',nl...
                                                                                                                ,css,nl...
                                                                                                                ,'<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',nl...
                                                                                                                ,'</HEAD><BODY',bodyOption,'>',nl...
                                                                                                                ,'<H1>',title,'</H1>',nl...
                                                                                                                ,'<P>',img,msg,'</P>',nl...
                                                                                                                ,'</BODY></HTML>'];


                                                                                                                fid=fopen(filename,'w','n','utf-8');
                                                                                                                fprintf(fid,'%s',s);
                                                                                                                fclose(fid);






                                                                                                                function varargout=printCodeLocations(fid,locs,bCodeLink)
                                                                                                                    prev='';
                                                                                                                    out='';
                                                                                                                    funcname=getTraceRptJS([]);
                                                                                                                    hyperlink='';
                                                                                                                    hyperlinkEnd='';
                                                                                                                    if bCodeLink
                                                                                                                        linebreak='<BR />';
                                                                                                                    else
                                                                                                                        linebreak=newline;
                                                                                                                    end
                                                                                                                    for k=1:length(locs)
                                                                                                                        [~,file,ext]=fileparts(locs(k).file);
                                                                                                                        ln=sprintf('%d',locs(k).line);
                                                                                                                        if bCodeLink
                                                                                                                            hyperlink=['<A href="javascript:',funcname,'(''',file,''',''',ext(2:end),''',''',ln,''');">'];
                                                                                                                            hyperlinkEnd='</A>';
                                                                                                                        end
                                                                                                                        buf='';
                                                                                                                        if~strcmp(locs(k).file,prev)
                                                                                                                            if~isempty(prev)
                                                                                                                                buf=[buf,linebreak];%#ok<AGROW>
                                                                                                                            end
                                                                                                                            buf=[buf,hyperlink,file,ext,':',ln,hyperlinkEnd];%#ok<AGROW>
                                                                                                                            prev=locs(k).file;
                                                                                                                        else
                                                                                                                            buf=[', ',hyperlink,ln,hyperlinkEnd];
                                                                                                                        end
                                                                                                                        if~isempty(fid)
                                                                                                                            fwrite(fid,buf,'char');
                                                                                                                        end
                                                                                                                        if nargout==1
                                                                                                                            out=[out,buf];%#ok<AGROW>
                                                                                                                        end
                                                                                                                    end
                                                                                                                    if nargout==1
                                                                                                                        varargout{1}=out;
                                                                                                                    end







                                                                                                                    function varargout=printCodeLocationsV2(fid,locs,bCodeLink)
                                                                                                                        prev='';
                                                                                                                        out='';
                                                                                                                        hyperlink='';
                                                                                                                        hyperlinkEnd='';
                                                                                                                        if bCodeLink
                                                                                                                            linebreak='<BR />';
                                                                                                                            hyperlinkEnd='</a>';
                                                                                                                        else
                                                                                                                            linebreak=newline;
                                                                                                                        end
                                                                                                                        for k=1:length(locs)
                                                                                                                            [~,file,ext]=fileparts(locs(k).file);
                                                                                                                            ln=locs(k).line;
                                                                                                                            lnStr=num2str(ln);

                                                                                                                            if bCodeLink
                                                                                                                                codeLoc=[file,ext,':',lnStr];
                                                                                                                                postArg=['{message:''jumpToCode'', location:'''...
                                                                                                                                ,codeLoc,'''}'];
                                                                                                                                hyperlink=['<a href="javascript: void(0)" onclick="postParentWindowMessage(',postArg,')">'];
                                                                                                                            end
                                                                                                                            buf='';
                                                                                                                            if~strcmp(locs(k).file,prev)
                                                                                                                                if~isempty(prev)
                                                                                                                                    buf=[buf,linebreak];%#ok<AGROW>
                                                                                                                                end
                                                                                                                                buf=[buf,hyperlink,file,ext,':',lnStr,hyperlinkEnd];%#ok<AGROW>
                                                                                                                                prev=locs(k).file;
                                                                                                                            else
                                                                                                                                buf=[', ',hyperlink,lnStr,hyperlinkEnd];
                                                                                                                            end
                                                                                                                            if~isempty(fid)
                                                                                                                                fwrite(fid,buf,'char');
                                                                                                                            end
                                                                                                                            if nargout==1
                                                                                                                                out=[out,buf];%#ok<AGROW>
                                                                                                                            end
                                                                                                                        end
                                                                                                                        if nargout==1
                                                                                                                            varargout{1}=out;
                                                                                                                        end





                                                                                                                        function out=getTraceRptJS(fid,modelPath,buildDir,target,bLink2Webview)
                                                                                                                            if nargin<4
                                                                                                                                target=[];
                                                                                                                            end
                                                                                                                            funcname='rtwTraceHilite';
                                                                                                                            if~isempty(fid)
                                                                                                                                nl=newline;
                                                                                                                                fwrite(fid,...
                                                                                                                                [getRtwHiliteJS(modelPath,buildDir,false,target,bLink2Webview),nl...
                                                                                                                                ,'<SCRIPT language="JavaScript" type="text/javascript"> ',nl...
                                                                                                                                ,'<!--',nl...
                                                                                                                                ,'function ',funcname,'(file,ext,ln) { ',nl...
                                                                                                                                ,'    function loc_hilite(file,ext,ln) { ',nl...
                                                                                                                                ,'        if (top.rtwMainReloadNoPanel) top.rtwMainReloadNoPanel(file+"."+ext+":"+ln); ',nl...
                                                                                                                                ,'        else window.location = file+"_"+ext+".html#"+ln; ',nl...
                                                                                                                                ,'    } ',nl]);
                                                                                                                                if strcmp(target,'rtw')&&rtw.report.ReportInfo.DisplayInCodeTrace
                                                                                                                                    fwrite(fid,...
                                                                                                                                    [
                                                                                                                                    '    var webviewFrame = top.document.getElementById(''rtw_webviewMidFrame'');',nl...
                                                                                                                                    ,'    if (webviewFrame) {',nl...
                                                                                                                                    ,'       loc_hilite(file,ext,ln);',nl...
                                                                                                                                    ,'       return;',nl...
                                                                                                                                    ,'    } else {',nl...
                                                                                                                                    ,'        if (top && top.rtwreport_document_frame) ',nl...
                                                                                                                                    ,'            top.rtwreport_document_frame.location.href = file+"_"+ext+".html#"+ln; ',nl...
                                                                                                                                    ,'    } ',nl]);

                                                                                                                                else
                                                                                                                                    fwrite(fid,['loc_hilite(file,ext,ln);',nl]);
                                                                                                                                end
                                                                                                                                fwrite(fid,['}',nl,'//-->',nl...
                                                                                                                                ,'</SCRIPT>']);
                                                                                                                            end
                                                                                                                            out=funcname;





                                                                                                                            function out=getRtwHiliteJS(~,~,~,~,link2Webview)

                                                                                                                                if nargin<5
                                                                                                                                    link2Webview=false;
                                                                                                                                end

                                                                                                                                if link2Webview&&Simulink.report.ReportInfo.featureReportV2==false
                                                                                                                                    nl=newline;
                                                                                                                                    out=['<SCRIPT type="text/javascript" language="JavaScript" src="slwebview.js"></SCRIPT>',nl...
                                                                                                                                    ,'<SCRIPT type="text/javascript" language="JavaScript" src="id_mapping.js"></SCRIPT>',nl];
                                                                                                                                else
                                                                                                                                    out='';
                                                                                                                                end




                                                                                                                                function out=getHdlHiliteJS(modelPath,buildDir,includeTag,varargin)

                                                                                                                                    if nargin<3
                                                                                                                                        includeTag=true;
                                                                                                                                    end
                                                                                                                                    out=getRtwHiliteJS(modelPath,buildDir,includeTag,'hdl',true);




                                                                                                                                    function out=getPLCHiliteJS(modelPath,buildDir,includeTag,varargin)

                                                                                                                                        if nargin<3
                                                                                                                                            includeTag=true;
                                                                                                                                        end
                                                                                                                                        out=getRtwHiliteJS(modelPath,buildDir,includeTag,'plc',true);




                                                                                                                                        function out=getJavaScriptMATLAB(funcName,varargin)
                                                                                                                                            hiliteCmd='code2model';

                                                                                                                                            switch funcName
                                                                                                                                            case 'rtwHilite'
                                                                                                                                                out=['if ~isempty(which(''private/rtwbindmodel'')), '...
                                                                                                                                                ,'rtwprivate rtwbindmodel ''%s'' ''%s'' ''%s'', end; '...
                                                                                                                                                ,'rtwprivate ',hiliteCmd,' %s %s;'];
                                                                                                                                            otherwise
                                                                                                                                                out='';
                                                                                                                                            end




                                                                                                                                            function out=getRtwHiliteJSForModel(model,buildDir,includeTag,target,bLink2Webview)

                                                                                                                                                modelPath=get_param(getSourceModel(model),'FileName');
                                                                                                                                                if isempty(modelPath)
                                                                                                                                                    out='';
                                                                                                                                                else
                                                                                                                                                    out=getRtwHiliteJS(modelPath,buildDir,includeTag,target,bLink2Webview);
                                                                                                                                                end




                                                                                                                                                function out=getSourceModel(model)
                                                                                                                                                    out=model;

                                                                                                                                                    if strcmp(get_param(model,'ModelReferenceTargetType'),'NONE')
                                                                                                                                                        h=rtwprivate('getSourceSubsystemHandle',model);
                                                                                                                                                        if ishandle(h)
                                                                                                                                                            out=get_param(bdroot(h),'name');
                                                                                                                                                        end
                                                                                                                                                    end





                                                                                                                                                    function out=getRTWTableShrinkButton(category,categoryMsg,expand_file_category,numFiles)


                                                                                                                                                        tooltip='Click to shrink or expand category';
                                                                                                                                                        if expand_file_category
                                                                                                                                                            out=['<span style="background-color:#ffffff;width:100%;cursor:pointer;white-space:nowrap" title="',tooltip,'" onclick="',getRTWTableShrinkCall(['this,''',category,''',''',categoryMsg,''',''',num2str(numFiles),''''])...
                                                                                                                                                            ,'"><span style="font-family:monospace" id = "',category,'_button">[-]</span></span>'];
                                                                                                                                                        else
                                                                                                                                                            out=['<span style="background-color:#ffffff;width:100%;cursor:pointer;white-space:nowrap" title="',tooltip,'" onclick="',getRTWTableShrinkCall(['this,''',category,''',''',categoryMsg,''',''',num2str(numFiles),''''])...
                                                                                                                                                            ,'"><span style="font-family:monospace" id = "',category,'_button">[+]</span></span>'];
                                                                                                                                                        end






                                                                                                                                                        function[newHyp,status]=editMCallHyperlinkForV2(oldLink)


                                                                                                                                                            hrefRegexp='href="matlab:(.+?)"';
                                                                                                                                                            out=regexp(oldLink,hrefRegexp,'tokens');

                                                                                                                                                            if isempty(out)
                                                                                                                                                                newHyp=oldLink;
                                                                                                                                                                status=false;
                                                                                                                                                                return;
                                                                                                                                                            end

                                                                                                                                                            out=out{1};

                                                                                                                                                            if isempty(out)
                                                                                                                                                                newHyp=oldLink;
                                                                                                                                                                status=false;
                                                                                                                                                                return;
                                                                                                                                                            end

                                                                                                                                                            out=out{1};
                                                                                                                                                            out2=replace(out,"'","\\'");
                                                                                                                                                            hrefReplace1='href="javascript: void(0)"';
                                                                                                                                                            hrefReplace2=sprintf(...
                                                                                                                                                            'onclick="postParentWindowMessage({message:''legacyMCall'', expr:''%s''})"',...
out2...
                                                                                                                                                            );

                                                                                                                                                            hrefReplaceStr=sprintf('%s %s ',hrefReplace1,hrefReplace2);
                                                                                                                                                            newHyp=regexprep(oldLink,hrefRegexp,hrefReplaceStr);

                                                                                                                                                            status=true;





                                                                                                                                                            function newHtmlStr=editMCallHyperlinkForV2Html(htmlStr)


                                                                                                                                                                hrefRegexp='href="matlab:(.+?)"';
                                                                                                                                                                outTokens=regexp(htmlStr,hrefRegexp,'tokens');

                                                                                                                                                                if isempty(outTokens)
                                                                                                                                                                    newHtmlStr=[];
                                                                                                                                                                    return;
                                                                                                                                                                end

                                                                                                                                                                innerReplace=sprintf('strrep($1, %s, %s)','"\''"','"\\\''"');
                                                                                                                                                                hrefReplace1='href="javascript: void(0)"';
                                                                                                                                                                hrefReplace2=sprintf('onclick="postParentWindowMessage({message:\''legacyMCall\'', expr:\''${%s}\''})"',innerReplace);
                                                                                                                                                                hrefReplaceStr=sprintf('%s %s ',hrefReplace1,hrefReplace2);
                                                                                                                                                                newHtmlStr=regexprep(htmlStr,hrefRegexp,hrefReplaceStr);





                                                                                                                                                                function out=getRTWTableShrinkCall(arg)

                                                                                                                                                                    out=['rtwFileListShrink(',arg,')'];




                                                                                                                                                                    function out=generateWebViewOn(modelname)
                                                                                                                                                                        out=strcmp(get_param(modelname,'GenerateWebview'),'on');




                                                                                                                                                                        function out=generateCodeMetricsReportOn(modelname)
                                                                                                                                                                            out=strcmp(get_param(modelname,'GenerateCodeMetricsReport'),'on');




                                                                                                                                                                            function out=generateCodeReplacementReportOn(modelname)
                                                                                                                                                                                out=strcmp(get_param(modelname,'GenerateCodeReplacementReport'),'on');




                                                                                                                                                                                function out=generateMissedCodeReplacementReportOn(modelname)
                                                                                                                                                                                    out=strcmp(get_param(modelname,'GenerateMissedCodeReplacementReport'),'on');






                                                                                                                                                                                    function[script,onload]=getRTWAnnotationJS(~,srcFile)
                                                                                                                                                                                        jsfile='rtwannotate.js';
                                                                                                                                                                                        script=['<SCRIPT type="text/javascript" src="',jsfile,'"></SCRIPT>',newline];
                                                                                                                                                                                        [~,srcFileBase,ext]=fileparts(srcFile);
                                                                                                                                                                                        xmlfile=[srcFileBase,'_',ext(2:end),'_cov.xml'];
                                                                                                                                                                                        onload=['if (typeof rtwannotate === ''function'') {rtwannotate(''',xmlfile,''');}'];





                                                                                                                                                                                        function refresh

                                                                                                                                                                                            dlg=coder.internal.showHtml;
                                                                                                                                                                                            if isa(dlg,'DAStudio.Dialog')
                                                                                                                                                                                                dlg.refresh;
                                                                                                                                                                                            end







                                                                                                                                                                                            function checkCommentOptions(config)


                                                                                                                                                                                                if(get_param(config,'ObfuscateCode')>0)&&...
                                                                                                                                                                                                    (strcmp(get_param(config,'IncludeHyperlinkInReport'),'on')||...
                                                                                                                                                                                                    strcmp(get_param(config,'GenerateTraceInfo'),'on')||...
                                                                                                                                                                                                    strcmp(get_param(config,'GenerateTraceReport'),'on')||...
                                                                                                                                                                                                    strcmp(get_param(config,'GenerateTraceReportSl'),'on')||...
                                                                                                                                                                                                    strcmp(get_param(config,'GenerateTraceReportSf'),'on')||...
                                                                                                                                                                                                    strcmp(get_param(config,'GenerateTraceReportEml'),'on'))
                                                                                                                                                                                                    DAStudio.error('RTW:traceInfo:obfuscationOn',get_param(config.getModel(),'Name'));
                                                                                                                                                                                                end




                                                                                                                                                                                                function insertSfcnFile(reportInfo,buildInfo)
                                                                                                                                                                                                    filesInSfcnGroup=getSourceFiles(buildInfo,1,1,{'Sfcn'});
                                                                                                                                                                                                    stubFolder=fullfile(reportInfo.BuildDirectory,'stub');

                                                                                                                                                                                                    sfcnFilesInReport=filesInSfcnGroup(~strncmp(stubFolder,filesInSfcnGroup,length(stubFolder)));
                                                                                                                                                                                                    group='interface';
                                                                                                                                                                                                    for i=1:length(sfcnFilesInReport)
                                                                                                                                                                                                        file=sfcnFilesInReport{i};
                                                                                                                                                                                                        [filePath,name,ext]=fileparts(file);
                                                                                                                                                                                                        if strcmp(ext,'.c')||strcmp(ext,'.cpp')
                                                                                                                                                                                                            fileType='source';
                                                                                                                                                                                                        else
                                                                                                                                                                                                            fileType='header';
                                                                                                                                                                                                        end
                                                                                                                                                                                                        reportInfo.addFileInfo([name,ext],group,fileType,filePath);
                                                                                                                                                                                                    end




                                                                                                                                                                                                    function insertCustomFile(reportInfo,fileInfo,customFile,buildInfo)

                                                                                                                                                                                                        fileNameList=cell(1,length(fileInfo));
                                                                                                                                                                                                        if iscell(fileInfo)
                                                                                                                                                                                                            for i=1:length(fileInfo)
                                                                                                                                                                                                                fileNameList{i}=fileInfo{i}.FileName;
                                                                                                                                                                                                            end
                                                                                                                                                                                                        else
                                                                                                                                                                                                            for i=1:length(fileInfo)
                                                                                                                                                                                                                fileNameList{i}=fileInfo(i).FileName;
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end
                                                                                                                                                                                                        fileNames={};
                                                                                                                                                                                                        fullFileNames={};



                                                                                                                                                                                                        custom_src=getSourceFiles(buildInfo,1,1,{},'Legacy');
                                                                                                                                                                                                        custom_hdr=getIncludeFiles(buildInfo,1,1,{'CustomCode'});
                                                                                                                                                                                                        custom_src=[custom_src,customFile,custom_hdr];
                                                                                                                                                                                                        for i=1:length(custom_src)
                                                                                                                                                                                                            [fpath,fname,ext]=fileparts(custom_src{i});



                                                                                                                                                                                                            if~isempty(fpath)&&~exist(custom_src{i},'file')&&~exist(fpath,'dir')
                                                                                                                                                                                                                fpathCorrectedTwoLevel=fullfile('..','..',fpath);
                                                                                                                                                                                                                fpathCorrectedOneLevel=fullfile('..',fpath);
                                                                                                                                                                                                                if exist(fpathCorrectedOneLevel,'dir')
                                                                                                                                                                                                                    fpath=fpathCorrectedTwoLevel;


                                                                                                                                                                                                                else

                                                                                                                                                                                                                    continue;
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end

                                                                                                                                                                                                            switch ext
                                                                                                                                                                                                            case{'.c','.cpp'}
                                                                                                                                                                                                                fileType='source';
                                                                                                                                                                                                            case{'.h','.hpp'}
                                                                                                                                                                                                                fileType='header';
                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                fileType='other';
                                                                                                                                                                                                            end
                                                                                                                                                                                                            fname=[fname,ext];%#ok<AGROW>
                                                                                                                                                                                                            if any(strcmp(fileNameList,fname))
                                                                                                                                                                                                                continue;
                                                                                                                                                                                                            end
                                                                                                                                                                                                            if isempty(fpath)
                                                                                                                                                                                                                if isempty(fileNames)
                                                                                                                                                                                                                    [fileNames,fullFileNames]=findfiles(buildInfo);
                                                                                                                                                                                                                end
                                                                                                                                                                                                                aFileInfo=createCustomFileInfo(fname,fileNames,fullFileNames,fileType);
                                                                                                                                                                                                            else
                                                                                                                                                                                                                aFileInfo=newFileInfo(fname,'legacy',fileType,fpath);
                                                                                                                                                                                                            end
                                                                                                                                                                                                            if~isempty(aFileInfo)
                                                                                                                                                                                                                aFileInfo=reportInfo.tokenPath(aFileInfo);
                                                                                                                                                                                                            end
                                                                                                                                                                                                            if~isempty(aFileInfo)
                                                                                                                                                                                                                if iscell(fileInfo)
                                                                                                                                                                                                                    fileInfo{end+1}=aFileInfo;%#ok<AGROW>
                                                                                                                                                                                                                elseif isempty(fileInfo)
                                                                                                                                                                                                                    fileInfo=aFileInfo;
                                                                                                                                                                                                                else
                                                                                                                                                                                                                    fileInfo(end+1)=aFileInfo;%#ok<AGROW>
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end
                                                                                                                                                                                                            reportInfo.FileInfo=fileInfo;
                                                                                                                                                                                                        end






                                                                                                                                                                                                        function[fileNames,fullFileNames]=findfiles(h)
                                                                                                                                                                                                            fileNames={};
                                                                                                                                                                                                            fullFileNames={};


                                                                                                                                                                                                            paths=h.getSourcePaths(true);
                                                                                                                                                                                                            paths=[paths,h.getIncludePaths(true)];
                                                                                                                                                                                                            paths=unique(paths);

                                                                                                                                                                                                            exts={'*.h','*.c','*.cpp'};
                                                                                                                                                                                                            sep=filesep;

                                                                                                                                                                                                            for i=1:length(paths)
                                                                                                                                                                                                                for j=1:length(exts)
                                                                                                                                                                                                                    dirFiles=dir(fullfile(paths{i},exts{j}));
                                                                                                                                                                                                                    fnames={dirFiles(:).name};
                                                                                                                                                                                                                    fileNames=[fileNames,fnames];%#ok<AGROW>
                                                                                                                                                                                                                    if~isempty(fnames)
                                                                                                                                                                                                                        fullFileNames=[fullFileNames,strcat([paths{i},sep],fnames)];%#ok<AGROW>
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end





                                                                                                                                                                                                            function fileInfo=createCustomFileInfo(fileName,fileNames,fullFileNames,fileType)
                                                                                                                                                                                                                file=fullFileNames(strmatch(fileName,fileNames,'exact'));%#ok<MATCH3>
                                                                                                                                                                                                                if~isempty(file)
                                                                                                                                                                                                                    if iscell(file)
                                                                                                                                                                                                                        file=file{end};
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                    fpath=fileparts(file);
                                                                                                                                                                                                                    fileInfo=newFileInfo(fileName,'legacy',fileType,fpath);
                                                                                                                                                                                                                else
                                                                                                                                                                                                                    fileInfo={};
                                                                                                                                                                                                                end





                                                                                                                                                                                                                function tf=hasCustomFile(currModel)
                                                                                                                                                                                                                    try
                                                                                                                                                                                                                        tf=false;
                                                                                                                                                                                                                        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(currModel);
                                                                                                                                                                                                                        buildInfo=modelCodegenMgr.BuildInfo;
                                                                                                                                                                                                                        cust_src=getSourceFiles(buildInfo,1,1,{'CustomCode','ModelSources'});
                                                                                                                                                                                                                        if~isempty(cust_src)
                                                                                                                                                                                                                            tf=true;
                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                    catch
                                                                                                                                                                                                                        tf=true;
                                                                                                                                                                                                                    end





                                                                                                                                                                                                                    function out=getCodeMetricsReportFileName(model,htmlDir)
                                                                                                                                                                                                                        if~ischar(model)
                                                                                                                                                                                                                            model=get_param(model,'Name');
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        out=fullfile(htmlDir,[model,'_metrics.html']);





                                                                                                                                                                                                                        function genTempCodeMetricsReport(model,buildDir)
                                                                                                                                                                                                                            if rtw.report.ReportInfo.featureReportV2
                                                                                                                                                                                                                                htmlDir=fullfile(buildDir,'html','pages');
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                htmlDir=fullfile(buildDir,'html');
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            rpt=getCodeMetricsReportFileName(model,htmlDir);
                                                                                                                                                                                                                            doc=Advisor.Document;
                                                                                                                                                                                                                            title=['Static Code Metrics Report for ',model];
                                                                                                                                                                                                                            doc.setTitle(title);
                                                                                                                                                                                                                            doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
                                                                                                                                                                                                                            doc.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
                                                                                                                                                                                                                            elem=Advisor.Element;
                                                                                                                                                                                                                            elem.setTag('H3');
                                                                                                                                                                                                                            elem.setContent('Static Code Metrics Report is being generated. <a href="javascript:location.reload(true)"> Refresh</a> this page when code generation is finished.');
                                                                                                                                                                                                                            doc.addItem(elem);
                                                                                                                                                                                                                            fid=fopen(rpt,'w','n','utf-8');
                                                                                                                                                                                                                            fwrite(fid,doc.emitHTML,'char');
                                                                                                                                                                                                                            fclose(fid);





                                                                                                                                                                                                                            function out=getCodeReplacementReportFileName(model,htmlDir)
                                                                                                                                                                                                                                if~ischar(model)
                                                                                                                                                                                                                                    model=get_param(model,'Name');
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                out=fullfile(htmlDir,[model,'_replacements.html']);





                                                                                                                                                                                                                                function varargout=hiliteCode(folder,file,line,varargin)


                                                                                                                                                                                                                                    persistent sep;

                                                                                                                                                                                                                                    sep='?';

                                                                                                                                                                                                                                    if~rtw.report.ReportInfo.featureReportV2

                                                                                                                                                                                                                                        if nargout>0,varargout{1}=[];end


                                                                                                                                                                                                                                        if~exist(folder,'dir'),DAStudio.error('RTW:utility:invalidPath',folder),end
                                                                                                                                                                                                                                        htmlrpt=dir(fullfile(folder,'html','*_codegen_rpt.html'));
                                                                                                                                                                                                                                        if isempty(htmlrpt)

                                                                                                                                                                                                                                            try
                                                                                                                                                                                                                                                reportInfo=rtw.report.getReportInfo('',folder);
                                                                                                                                                                                                                                                reportInfo.generate;
                                                                                                                                                                                                                                            catch
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            htmlrpt=dir(fullfile(folder,'html','*_codegen_rpt.html'));
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        if isempty(htmlrpt)
                                                                                                                                                                                                                                            DAStudio.error('RTW:report:ReportNotFound',folder)
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        line=sprintf(',%d',line);
                                                                                                                                                                                                                                        query=[sep,file,':',line(2:end)];


                                                                                                                                                                                                                                        for k=1:2:length(varargin)
                                                                                                                                                                                                                                            file=varargin{k};
                                                                                                                                                                                                                                            line=sprintf(',%d',varargin{k+1});
                                                                                                                                                                                                                                            query=strcat(query,'&',file,':',line(2:end));
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        fileURL=Simulink.document.fileURL(fullfile(folder,'html',htmlrpt.name),query);
                                                                                                                                                                                                                                        if~Simulink.report.ReportInfo.featureReportV2








                                                                                                                                                                                                                                            coder.internal.showHtml(fileURL,'UseWebBrowserWidget');
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        if nargout>0,varargout{1}=fileURL;end
                                                                                                                                                                                                                                    else

                                                                                                                                                                                                                                        varargout{1}=[];
                                                                                                                                                                                                                                        oldRptInfo=rtw.report.getReportInfo('',folder);
                                                                                                                                                                                                                                        model=oldRptInfo.ModelName;
                                                                                                                                                                                                                                        rptInfo=rtw.report.getLatestReportInfo(model);


                                                                                                                                                                                                                                        rptInfo.show;









                                                                                                                                                                                                                                        if numel(line)==1
                                                                                                                                                                                                                                            data={
                                                                                                                                                                                                                                            struct('file',file,'line',line);
                                                                                                                                                                                                                                            };
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            data=cell(numel(line),1);
                                                                                                                                                                                                                                            for k=1:numel(line)
                                                                                                                                                                                                                                                lineNum=line(k);
                                                                                                                                                                                                                                                data{k}=struct('file',file,'line',lineNum);
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        input=[];
                                                                                                                                                                                                                                        input.title=message('SimulinkCoderApp:report:HighlightCode').getString();
                                                                                                                                                                                                                                        input.data=data;

                                                                                                                                                                                                                                        simulinkcoder.internal.util.highlightInCode(model,input);
                                                                                                                                                                                                                                    end





                                                                                                                                                                                                                                    function out=getModelNameSuffix(codeFormat)
                                                                                                                                                                                                                                        switch codeFormat
                                                                                                                                                                                                                                        case 'S-Function'
                                                                                                                                                                                                                                            out='_sf';
                                                                                                                                                                                                                                        case 'Accelerator_S-Function'
                                                                                                                                                                                                                                            out='_acc';
                                                                                                                                                                                                                                        otherwise
                                                                                                                                                                                                                                            out='';
                                                                                                                                                                                                                                        end





                                                                                                                                                                                                                                        function out=getContentsFileName(model,codeFormat)

                                                                                                                                                                                                                                            out=[model,getModelNameSuffix(codeFormat),'_contents.html'];





                                                                                                                                                                                                                                            function out=getReportFileName(model,codeFormat)

                                                                                                                                                                                                                                                out=[model,getModelNameSuffix(codeFormat),'_codegen_rpt.html'];





                                                                                                                                                                                                                                                function out=getReportConfig(model)

                                                                                                                                                                                                                                                    param={...
                                                                                                                                                                                                                                                    'LaunchReport',...
                                                                                                                                                                                                                                                    'IncludeHyperlinkInReport',...
                                                                                                                                                                                                                                                    'GenerateTraceInfo',...
                                                                                                                                                                                                                                                    'GenerateTraceReport',...
                                                                                                                                                                                                                                                    'GenerateTraceReportSl',...
                                                                                                                                                                                                                                                    'GenerateTraceReportSf',...
                                                                                                                                                                                                                                                    'GenerateTraceReportEml',...
                                                                                                                                                                                                                                                    'GenerateCodeMetricsReport',...
                                                                                                                                                                                                                                                    'GenerateCodeReplacementReport',...
                                                                                                                                                                                                                                                    'GenerateWebview',...
                                                                                                                                                                                                                                                    };
                                                                                                                                                                                                                                                    value=cellfun(@(x)get_param(model,x),param,'UniformOutput',false);
                                                                                                                                                                                                                                                    c=[param;value];
                                                                                                                                                                                                                                                    out=struct(c{:});






                                                                                                                                                                                                                                                    function out=getReportConfigFromMAT(reportInfoFile)
                                                                                                                                                                                                                                                        out=[];
                                                                                                                                                                                                                                                        m=load(reportInfoFile);
                                                                                                                                                                                                                                                        if isfield(m,'reportInfo')&&isfield(m.reportInfo,'Config')
                                                                                                                                                                                                                                                            out=m.reportInfo.Config;
                                                                                                                                                                                                                                                        end





                                                                                                                                                                                                                                                        function result=setGenUtilsPath(model,utilsPath)
                                                                                                                                                                                                                                                            result='';

                                                                                                                                                                                                                                                            reportInfo=rtw.report.ReportInfo.instance(model);
                                                                                                                                                                                                                                                            if~isempty(reportInfo)
                                                                                                                                                                                                                                                                if utilsPath(end)==filesep
                                                                                                                                                                                                                                                                    utilsPath=utilsPath(1:end-1);
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                reportInfo.GenUtilsPath=utilsPath;
                                                                                                                                                                                                                                                            end





                                                                                                                                                                                                                                                            function result=setTlcTraceInfo(model,tlcTraceInfo)
                                                                                                                                                                                                                                                                result='';

                                                                                                                                                                                                                                                                reportInfo=rtw.report.ReportInfo.instance(model);
                                                                                                                                                                                                                                                                if~isempty(reportInfo)
                                                                                                                                                                                                                                                                    reportInfo.Summary.TimeStamp=tlcTraceInfo.TimeStamp;
                                                                                                                                                                                                                                                                    reportInfo.Summary.CoderVersion=tlcTraceInfo.Version;
                                                                                                                                                                                                                                                                    if isfield(tlcTraceInfo,'ReducedBlock')
                                                                                                                                                                                                                                                                        reportInfo.ReducedBlocks=...
                                                                                                                                                                                                                                                                        rtw.report.ReducedBlocks(model,cell2mat(tlcTraceInfo.ReducedBlock));
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if isfield(tlcTraceInfo,'InsertedBlock')
                                                                                                                                                                                                                                                                        reportInfo.InsertedBlocks=...
                                                                                                                                                                                                                                                                        rtw.report.InsertedBlocks(model,tlcTraceInfo.InsertedBlock);
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                end




                                                                                                                                                                                                                                                                function result=addFileInfo(model,name,group,fileType,filePath)
                                                                                                                                                                                                                                                                    result='';

                                                                                                                                                                                                                                                                    reportInfo=rtw.report.ReportInfo.instance(model);
                                                                                                                                                                                                                                                                    if~isempty(reportInfo)
                                                                                                                                                                                                                                                                        reportInfo.addFileInfo(name,group,fileType,filePath);
                                                                                                                                                                                                                                                                    end





                                                                                                                                                                                                                                                                    function result=setReportInfo(model,name,val)
                                                                                                                                                                                                                                                                        result='';

                                                                                                                                                                                                                                                                        reportInfo=rtw.report.ReportInfo.instance(model);
                                                                                                                                                                                                                                                                        if~isempty(reportInfo)
                                                                                                                                                                                                                                                                            reportInfo.(name)=val;
                                                                                                                                                                                                                                                                        end




                                                                                                                                                                                                                                                                        function aFileInfo=newFileInfo(fileName,group,type,fpath)
                                                                                                                                                                                                                                                                            aFileInfo=rtw.report.ReportInfo.newFileInfo(fileName,...
                                                                                                                                                                                                                                                                            group,...
                                                                                                                                                                                                                                                                            type,...
                                                                                                                                                                                                                                                                            fpath);




                                                                                                                                                                                                                                                                            function href=get_code2model_hyperlink(sid,pid,name)
                                                                                                                                                                                                                                                                                if~rtw.report.ReportInfo.featureReportV2
                                                                                                                                                                                                                                                                                    if isempty(pid)
                                                                                                                                                                                                                                                                                        href=sprintf('<a href="matlab:coder.internal.code2model(''%s'')" name="code2model" class="code2model">%s</a>',...
                                                                                                                                                                                                                                                                                        sid,name);
                                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                                        href=sprintf('<a href="matlab:coder.internal.code2model(''%s'',''%s'')" name="code2model" class="code2model">%s</a>',...
                                                                                                                                                                                                                                                                                        sid,pid,name);
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                    if isempty(pid)
                                                                                                                                                                                                                                                                                        href=['<a href="javascript: void(0)" onclick="postParentWindowMessage({message:''legacyMCall'', expr:''coder.internal.code2model(\'''...
                                                                                                                                                                                                                                                                                        ,sid,'\'')''})"  name="code2model" class="code2model">'...
                                                                                                                                                                                                                                                                                        ,name,'</a>'];
                                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                                        href=['<a href="javascript: void(0)" onclick="postParentWindowMessage({message:''legacyMCall'', expr:''coder.internal.code2model(\'''...
                                                                                                                                                                                                                                                                                        ,sid,'\'', \''',pid,'\'')''})"  name="code2model" class="code2model">'...
                                                                                                                                                                                                                                                                                        ,name,'</a>'];
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                end



                                                                                                                                                                                                                                                                                function genRTWnameSIDMap(fid,registry,systemMap,modelName,sourceSubsystem,isRTW)
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('function RTW_rtwnameSIDMap() {\n'),'char');
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('\tthis.rtwnameHashMap = new Array();\n'),'char');
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('\tthis.sidHashMap = new Array();\n'),'char');

                                                                                                                                                                                                                                                                                    isSIDComment=isRTW&&strcmp(slprivate('getBlockCommentType',modelName),'BlockSIDComment');
                                                                                                                                                                                                                                                                                    str=sprintf('\tthis.rtwnameHashMap["<Root>"] = {sid: "%s"};\n\tthis.sidHashMap["%s"] = {rtwname: "<Root>"};\n',modelName,modelName);
                                                                                                                                                                                                                                                                                    fwrite(fid,str,'char');
                                                                                                                                                                                                                                                                                    if~isempty(systemMap)
                                                                                                                                                                                                                                                                                        for i=1:length(systemMap)
                                                                                                                                                                                                                                                                                            sid=systemMap{i};
                                                                                                                                                                                                                                                                                            if~isSIDComment
                                                                                                                                                                                                                                                                                                rtwName=['<S',num2str(i),'>'];
                                                                                                                                                                                                                                                                                                str=sprintf('\tthis.rtwnameHashMap["%s"] = {sid: "%s"};\n\tthis.sidHashMap["%s"] = {rtwname: "%s"};\n',rtwName,sid,sid,rtwName);
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                if isempty(sourceSubsystem)
                                                                                                                                                                                                                                                                                                    [~,compactSID]=strtok(sid,':');
                                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                                    compactSID=Simulink.ID.getSubsystemBuildSID(sid,sourceSubsystem,'');
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                                str=sprintf('\tthis.rtwnameHashMap["%s"] = {sid: "%s"};\n\tthis.sidHashMap["%s"] = {rtwname: "%s"};\n',compactSID,sid,sid,compactSID);
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            fwrite(fid,str,'char');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                                    if slfeature('TraceVarSource')<2
                                                                                                                                                                                                                                                                                        for i=1:length(registry)
                                                                                                                                                                                                                                                                                            reg=registry(i);
                                                                                                                                                                                                                                                                                            rtwName=reg.rtwname;
                                                                                                                                                                                                                                                                                            sid=reg.sid;
                                                                                                                                                                                                                                                                                            rtwName=Simulink.report.ReportInfo.escapeSpecialCharInJS(rtwName);
                                                                                                                                                                                                                                                                                            if~isSIDComment
                                                                                                                                                                                                                                                                                                str=sprintf('\tthis.rtwnameHashMap["%s"] = {sid: "%s"};\n\tthis.sidHashMap["%s"] = {rtwname: "%s"};\n',rtwName,sid,sid,rtwName);
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                if isempty(sourceSubsystem)
                                                                                                                                                                                                                                                                                                    [~,compactSID]=strtok(sid,':');
                                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                                    compactSID=Simulink.ID.getSubsystemBuildSID(sid,sourceSubsystem);
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                                str=sprintf('\tthis.rtwnameHashMap["%s"] = {sid: "%s"};\n\tthis.sidHashMap["%s"] = {rtwname: "%s"};\n',compactSID,sid,sid,compactSID);
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            fwrite(fid,str,'char');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    else


                                                                                                                                                                                                                                                                                        rtwNameToURLs=containers.Map;
                                                                                                                                                                                                                                                                                        for i=1:length(registry)
                                                                                                                                                                                                                                                                                            reg=registry(i);
                                                                                                                                                                                                                                                                                            rtwName=reg.rtwname;
                                                                                                                                                                                                                                                                                            sid=reg.sid;
                                                                                                                                                                                                                                                                                            rtwName=Simulink.report.ReportInfo.escapeSpecialCharInJS(rtwName);
                                                                                                                                                                                                                                                                                            if~isSIDComment
                                                                                                                                                                                                                                                                                                nameKey=rtwName;
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                if isempty(sourceSubsystem)
                                                                                                                                                                                                                                                                                                    [~,nameKey]=strtok(sid,':');
                                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                                    nameKey=Simulink.ID.getSubsystemBuildSID(sid,sourceSubsystem);
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            str=sprintf('\tthis.sidHashMap["%s"] = {rtwname: "%s"};\n',sid,nameKey);
                                                                                                                                                                                                                                                                                            fwrite(fid,str,'char');


                                                                                                                                                                                                                                                                                            if slfeature('TraceVarSource')>0&&rtwNameToURLs.isKey(nameKey)
...
...
...
...
...
...
                                                                                                                                                                                                                                                                                                rtwNameToURLs(nameKey)=[rtwNameToURLs(nameKey),',',sid];
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                rtwNameToURLs(nameKey)=sid;
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        RTWKeys=keys(rtwNameToURLs);
                                                                                                                                                                                                                                                                                        URLs=values(rtwNameToURLs);
                                                                                                                                                                                                                                                                                        for i=1:length(RTWKeys)

                                                                                                                                                                                                                                                                                            comStr=sprintf('\tthis.rtwnameHashMap["%s"] = {sid: "%s"};\n',RTWKeys{i},URLs{i});
                                                                                                                                                                                                                                                                                            fwrite(fid,comStr,'char');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('\tthis.getSID = function(rtwname) { return this.rtwnameHashMap[rtwname];}\n'),'char');
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('\tthis.getRtwname = function(sid) { return this.sidHashMap[sid];}\n}\n'),'char');
                                                                                                                                                                                                                                                                                    fwrite(fid,sprintf('RTW_rtwnameSIDMap.instance = new RTW_rtwnameSIDMap();\n'),'char');




                                                                                                                                                                                                                                                                                    function loc_exportFileLinks(reportInfo)
                                                                                                                                                                                                                                                                                        if rtw.report.ReportInfo.featureReportV2
                                                                                                                                                                                                                                                                                            defineJSFile=fullfile(reportInfo.getReportDir,'pages','define.js');
                                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                                            defineJSFile=fullfile(reportInfo.getReportDir,'define.js');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        fid=fopen(defineJSFile,'a','n','utf-8');
                                                                                                                                                                                                                                                                                        fprintf(fid,'var testHarnessInfo = {OwnerFileName: "%s", HarnessOwner: "%s", HarnessName: "%s", IsTestHarness: "%d"};\n',...
                                                                                                                                                                                                                                                                                        javascriptEscape(reportInfo.OwnerFileName),javascriptEscape(reportInfo.HarnessOwner),...
                                                                                                                                                                                                                                                                                        javascriptEscape(reportInfo.HarnessName),reportInfo.IsTestHarness);
                                                                                                                                                                                                                                                                                        rel_path=coder.report.ReportInfoBase.getRelativePathToFile(fullfile(reportInfo.getBuildDir,'ert_main.c'),fullfile(reportInfo.getReportDir,'h'));
                                                                                                                                                                                                                                                                                        fprintf(fid,'var relPathToBuildDir = "%s";\n',rel_path);
                                                                                                                                                                                                                                                                                        if strcmp(filesep,'\')

                                                                                                                                                                                                                                                                                            fprintf(fid,'var fileSep = "\\\\";\n');
                                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                                            fprintf(fid,'var fileSep = "/";\n');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        if ispc
                                                                                                                                                                                                                                                                                            fprintf(fid,'var isPC = true;\n');
                                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                                            fprintf(fid,'var isPC = false;\n');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        fprintf(fid,'function Html2SrcLink() {\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\tthis.html2SrcPath = new Array;\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\tthis.html2Root = new Array;\n');
                                                                                                                                                                                                                                                                                        sortedFileInfoList=reportInfo.getSortedFileInfoList;
                                                                                                                                                                                                                                                                                        fileList=cell(1,length(sortedFileInfoList.HtmlFileName));
                                                                                                                                                                                                                                                                                        for i=1:length(sortedFileInfoList.HtmlFileName)
                                                                                                                                                                                                                                                                                            [~,hFile,ext]=fileparts(sortedFileInfoList.HtmlFileName{i});
                                                                                                                                                                                                                                                                                            rel_path=coder.report.ReportInfoBase.getRelativePathToFile(...
                                                                                                                                                                                                                                                                                            sortedFileInfoList.FileName{i},sortedFileInfoList.HtmlFileName{i});
                                                                                                                                                                                                                                                                                            rel_path1=coder.report.ReportInfoBase.getRelativePathToFile(...
                                                                                                                                                                                                                                                                                            sortedFileInfoList.HtmlFileName{i},fullfile(reportInfo.getReportDir,'h'));
                                                                                                                                                                                                                                                                                            fprintf(fid,'\tthis.html2SrcPath["%s"] = "%s";\n',[hFile,ext],rel_path);
                                                                                                                                                                                                                                                                                            fprintf(fid,'\tthis.html2Root["%s"] = "%s";\n',[hFile,ext],rel_path1);
                                                                                                                                                                                                                                                                                            fileList{i}=[hFile,ext];
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        fprintf(fid,'\tthis.getLink2Src = function (htmlFileName) {\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\t\t if (this.html2SrcPath[htmlFileName])\n\t\t\t return this.html2SrcPath[htmlFileName];\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\t\t else\n\t\t\t return null;\n\t}\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\tthis.getLinkFromRoot = function (htmlFileName) {\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\t\t if (this.html2Root[htmlFileName])\n\t\t\t return this.html2Root[htmlFileName];\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'\t\t else\n\t\t\t return null;\n\t}\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'}\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'Html2SrcLink.instance = new Html2SrcLink();\n');
                                                                                                                                                                                                                                                                                        fprintf(fid,'var fileList = [\n');
                                                                                                                                                                                                                                                                                        for i=1:length(fileList)
                                                                                                                                                                                                                                                                                            if i~=1
                                                                                                                                                                                                                                                                                                fprintf(fid,',');
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            fprintf(fid,'"%s"',fileList{i});
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        fprintf(fid,'];\n');
                                                                                                                                                                                                                                                                                        fclose(fid);


                                                                                                                                                                                                                                                                                        function str=javascriptEscape(str)
                                                                                                                                                                                                                                                                                            str=strrep(str,'\','\\');
                                                                                                                                                                                                                                                                                            str=strrep(str,'"','\"');















