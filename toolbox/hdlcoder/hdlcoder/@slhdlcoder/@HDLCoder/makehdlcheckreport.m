function makehdlcheckreport(this,mdlName,checks,createNewTab,callSite)



    import matlab.internal.lang.capability.Capability;
    if nargin<4
        createNewTab=false;
    end
    if nargin<5



        callSite=0;
    end




    this.NeedToGenerateHTMLReport=false;

    if strcmp(mdlName,this.ModelConnection.ModelName)
        nname=this.getStartNodeName;
        bname=this.ModelConnection.SubsystemName;
        if isempty(bname)
            [~,bname]=getmodelnodename(mdlName,nname);
            if isempty(bname)
                bname=nname;
            end
        end
    else
        bname=mdlName;
        nname=mdlName;
    end


    nname=strrep(nname,newline,' ');
    bname=vhdllegalname(bname);


    this.hdlMakeCodegendir;

    codegendir=this.hdlGetCodegendir;
    if callSite==2
        bname=[bname,'_tb'];
    end
    fileName=[this.getParameter('module_prefix'),bname,'_report.html'];
    fopenName=fullfile(codegendir,fileName);
    fid=fopen(fopenName,'w','n','utf-8');

    if fid==-1
        error(message('hdlcoder:engine:cannotopenfile',fileName));
    end

    report=hdlcodingstd.HTMLReporter;

    if callSite<2
        headerStr=message('hdlcoder:makecheckhdlreport:hdlcheckreport',nname).getString;
        titleStr=message('hdlcoder:makecheckhdlreport:title',nname).getString;
        openModelStr=sprintf('<a href="matlab:open_system(''%s'');">%s</a><BR>\n',...
        nname,message('hdlcoder:makecheckhdlreport:openmodel',nname).getString);
    else
        headerStr=message('hdlcoder:makecheckhdlreport:tbcheckreport',nname).getString;
        titleStr=message('hdlcoder:makecheckhdlreport:tbtitle',nname).getString;
        openModelStr=[];
    end
    report.createHeader(fid,nname,headerStr);

    fprintf(fid,'<body>\n');
    fprintf(fid,'<div class="container_192">\n<div class="grid_192">\n');
    fprintf(fid,' <div class="page_container"><div class="content_frame">\n');

    fprintf(fid,'<h1>');
    fprintf(fid,'%s\n',titleStr);
    fprintf(fid,'%s',openModelStr);

    fprintf(fid,'%s',...
    message('hdlcoder:makecheckhdlreport:generatedon',datestr(now,31)).getString());
    fprintf(fid,'</h1>\n');


    severityLevelHasError=false;

    if isempty(checks)

        fprintf(fid,['<H2>',message('hdlcoder:makecheckhdlreport:allset').getString,'</H2><BR>\n']);
        errorCount=0;
    else


        [errorCount,warningCount,messageCount]=this.statusCount(checks);
        summary_msg=message('hdlcoder:hdldisp:FinishCheck',mdlName,...
        num2str(errorCount),num2str(warningCount),num2str(messageCount));

        fprintf(fid,['<H2>',summary_msg.getString,'</H2><BR>\n']);
        fprintf(fid,['<H3>',message('hdlcoder:makecheckhdlreport:founderrors').getString,'</H3><BR>\n']);
        fprintf(fid,'<TABLE>\n');

        fprintf(fid,['<TR><TD> <B>',message('hdlcoder:makecheckhdlreport:slblock').getString,'</B> </TD>']);
        fprintf(fid,['<TD> <B>',message('hdlcoder:makecheckhdlreport:level').getString,'</B> </TD>']);
        fprintf(fid,['<TD> <B>',message('hdlcoder:makecheckhdlreport:desc').getString,'</B> </TD></TR>']);


        errs=[];
        warns=[];
        messg=[];
        for n=1:length(checks)
            chk=checks(n);

            switch lower(chk.level)
            case 'error'
                errs=[errs,chk];%#ok<*AGROW>
                severityLevelHasError=true;
            case 'warning'
                warns=[warns,chk];
            case 'message'
                messg=[messg,chk];
            otherwise
                errs=[errs,chk];
            end
        end



        checks=[];
        if~isempty(errs)
            checks=[checks,errs];
        end
        if~isempty(warns)
            checks=[checks,warns];
        end
        if~isempty(messg)
            checks=[checks,messg];
        end


        bgcolor={'#FFFFFF','#F0F0F0'};

        for n=1:length(checks)
            chk=checks(n);

            msg_txt=hdlRemoveHtmlonlyTags(chk.message);


            fprintf(fid,'<TR bgcolor="%s"><TD>\n',bgcolor{mod(n,2)+1});

            switch lower(chk.type)
            case 'synthetic'
                blkPath=chk.path;

                fprintf(fid,'<a alt="%s"',chk.MessageID);
                fprintf(fid,[' href="matlab:hilite(get_param(''%s'',''object''),''none'');',...
                'open_system(char(%s))">%s (synthetic)</a>\n'],...
                getMLRunnableBdrootName(),getMLRunnableName(blkPath),blkPath);

            case{'model'}
                blkPath=chk.path;


                fprintf(fid,'<a alt="%s"',checks(n).MessageID);
                fprintf(fid,[' href="matlab:hilite(get_param(char(%s),''object''),''none'');',...
                'open_system(char(%s))">%s</a>\n'],...
                getMLRunnableBdrootName(),getMLRunnableName(blkPath),blkPath);

            case{'script'}

                scriptname=chk.path;

                fprintf(fid,'<a alt="%s"',chk.MessageID);
                fprintf(fid,' href="matlab:run(''%s'')">%s.m</a>\n',scriptname,scriptname);



                msg_txt=sprintf('%s <a href="matlab:run(''%s'')">%s.m</a>',...
                msg_txt,scriptname,scriptname);

            otherwise
                filename=extractBetween(chk.path,[' ',message('hdlcommon:matlab2dataflow:LocFile').getString,' '],[' ',message('hdlcommon:matlab2dataflow:LocLine').getString,' ']);
                line=extractBetween(chk.path,[' ',message('hdlcommon:matlab2dataflow:LocLine').getString,' '],[' ',message('hdlcommon:matlab2dataflow:LocCol').getString,' ']);
                if~isempty(line)

                    if~isempty(filename)
                        cmd=sprintf('[~]=matlab.desktop.editor.openAndGoToLine(char(%s), %s);',...
                        getMLRunnableName(filename{:}),line{:});
                    else
                        blkPath=extractBetween(chk.path,1," Line: ");
                        cmd=sprintf(...
                        'sf(''Open'', sfprivate(''block2chart'', char(%s)), %s-1, -2)',...
                        getMLRunnableName(blkPath{:}),line{:});
                    end

                    fprintf(fid,'<a alt="%s" href="matlab:%s">',chk.MessageID,cmd);
                    fprintf(fid,'<div>%s</div>',chk.path);
                    fprintf(fid,'</a>');

                else


                    blkPath=chk.path;

                    if getSimulinkBlockHandle(blkPath)==-1


                        fprintf(fid,'<div alt="%s">%s</div>\n',chk.MessageID,blkPath);
                    else
                        fprintf(fid,'<a alt="%s"',chk.MessageID);
                        fprintf(fid,[' href="matlab:hilite(get_param(char(%s),''object''),''none'');',...
                        'hilite_system(char(%s))">%s</a>\n'],...
                        getMLRunnableBdrootName(),getMLRunnableName(blkPath),blkPath);
                    end
                end
            end

            fprintf(fid,'</TD>\n');
            fprintf(fid,'<TD>%s</TD>\n',chk.level);
            fprintf(fid,'<TD>%s</TD>\n',msg_txt);
            fprintf(fid,'</TR>\n');
        end
        fprintf(fid,'</TABLE>\n');
    end
    report.endBody(fid);
    fclose(fid);

    if ispc

        if~(exist(fopenName,'file')==2)
            warning(message('hdlcoder:makecheckhdlreport:missinghtml',fopenName));
        end
    end

    if~isempty(dir(fullfile(pwd,codegendir,fileName)))
        nameforuser=fullfile(pwd,codegendir,fileName);
    elseif~isempty(dir(fullfile(codegendir,fileName)))
        nameforuser=fullfile(codegendir,fileName);
    else
        error(message('hdlcoder:engine:fullfilenamenotfound'))
    end



    filePath=coder.report.internal.fileURL(nameforuser,'');

    if feature('hotlinks')
        WebLink=hdlcoder.report.getHDLCoderHyperLink(filePath,fileName);
    else
        WebLink=filePath;
    end

    isModelProtection=this.getParameter('BuildToProtectModel');
    if isModelProtection
        WebLink=fileName;
    end

    hdldisp(message('hdlcoder:hdldisp:HTMLReportGenerated',WebLink));


    hdlcoder.report.ReportInfo.getSavedRptPath(mdlName,false,nameforuser);
    if errorCount>0


        hdlcoder.report.ReportInfo.getSavedRptPath(mdlName,true,[]);
    end











    displayBrowser=true;
    if~isempty(this.DownstreamIntegrationDriver)
        hD=this.DownstreamIntegrationDriver;
        displayBrowser=hD.cliDisplay;
    end

    if WebBrowserOpenPolicy(severityLevelHasError,callSite,this.getParameter('ErrorCheckReport'))&&...
        ~isModelProtection&&displayBrowser
        if Capability.isSupported(Capability.LocalClient)

            status=web(filePath);
            switch status
            case 1
                error(message('hdlcoder:engine:webbrowsernotfound'))
            case 2
                error(message('hdlcoder:engine:webbrowserfailed'))
            otherwise

            end
        else

            hdlcoder.report.openDdg(filePath);
        end
    end
end

function ml_runnable_name=getMLRunnableName(name)




    ml_runnable_name=mat2str(name+0);
end

function ml_runnable_bdroot_name=getMLRunnableBdrootName
    bd_root_name=get_param(bdroot,'Name');
    ml_runnable_bdroot_name=getMLRunnableName(bd_root_name);
end

function flag=WebBrowserOpenPolicy(severityLevelHasError,callSite,ErrorCheckReport)


    flag=false;%#ok<NASGU> %default
    if callSite==0
        flag=ErrorCheckReport;
    else
        flag=ErrorCheckReport&&severityLevelHasError;
    end
end
