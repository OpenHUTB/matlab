
classdef HDLCheckReporter<hdlcodingstd.HTMLReporter
    properties(Access=public)
        hdlChecks;
        functionName;
        hHDLDriver;
    end

    methods(Access=public)

        function this=HDLCheckReporter(fileName,checks)
            this.hHDLDriver=hdlcurrentdriver;
            this.hdlChecks=checks;
            this.functionName=fileName;
        end

        function[nerr,nwarn,nmsg,sortedChecks]=createCheckTable(this,fid)
            [nerr,nwarn,nmsg]=deal(0);
            checks=this.hdlChecks;
            sortedChecks=struct('errs',[],'warns',[],'messg',[]);
            if isempty(checks)
                fprintf(fid,['<div class="content_container"><H3>',message('hdlcoder:makecheckhdlreport:allset').getString(),'</H3><BR/></div>\n']);
            else


                errs=[];
                warns=[];
                messg=[];



                for n=1:length(checks)
                    level=checks(n).level;
                    if(ischar(level))
                        level=lower(level);
                    end


                    switch level
                    case{'error',1}
                        errs=[errs,checks(n)];%#ok<AGROW>
                    case{'warning',2}
                        warns=[warns,checks(n)];%#ok<AGROW>
                    case{'message',0}
                        messg=[messg,checks(n)];%#ok<AGROW>
                    otherwise
                        errs=[errs,checks(n)];%#ok<AGROW>
                    end
                end

                nerr=length(errs);
                nwarn=length(warns);
                nmsg=length(checks)-nwarn-nerr;


                fprintf(fid,'<div class="content_container"><H3>%s</H3><BR/></DIV>\n',message('hdlcoder:matlabhdlcoder:ConformanceSummary',num2str(nerr),num2str(nwarn),num2str(nmsg)).getString());
                fprintf(fid,'<DIV class="content_container"><TABLE class="tabledata">\n');

                fprintf(fid,['<TR><TD> <B>',message('hdlcoder:makecheckhdlreport:funcloc').getString(),'</B> </TD>']);
                fprintf(fid,['<TD>',message('hdlcoder:makecheckhdlreport:level').getString(),'<B></B> </TD>']);
                fprintf(fid,['<TD> <B>',message('hdlcoder:makecheckhdlreport:desc').getString(),'</B> </TD></TR>']);

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

                sortedChecks=struct('errs',errs,'warns',warns,'messg',messg);

                relCheckFilePath=getCheckFilePath(this);




                level_desc={message('hdlcoder:makecheckhdlreport:mesg').getString(),...
                message('hdlcoder:makecheckhdlreport:warn').getString(),...
                message('hdlcoder:makecheckhdlreport:err').getString()};


                for n=1:length(checks)


                    fprintf(fid,'<TR><TD>\n');
                    nm=checks(n).fileName;
                    if isempty(nm)
                        nm=this.functionName;
                    end
                    lnn=checks(n).lineNum;
                    msgid=checks(n).MessageID;
                    fp=which(fullfile(relCheckFilePath,nm));
                    fprintf(fid,'<a alt="%s" href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'', %d);">%s:%d</a></TD>\n',...
                    msgid,fp,lnn,nm,lnn);


                    if(isnumeric(checks(n).level))

                        if(checks(n).level>2||checks(n).level<0)
                            checks(n).level=0;%#ok<AGROW>
                        end
                        level=level_desc{1+checks(n).level};
                    else
                        level=checks(n).level;
                    end
                    checks(n).level=level;%#ok<AGROW>

                    fprintf(fid,'<TD>%s</TD>\n',level);
                    fprintf(fid,'<TD>%s</TD>\n',checks(n).message);
                    fprintf(fid,'</TR>\n');
                end
                fprintf(fid,'</TABLE></DIV>\n');
                this.hdlChecks=checks;
            end

        end

        function relCheckFilePath=getCheckFilePath(this)


            using_fixpt=this.hHDLDriver.cginfo.HDLConfig.IsFixPtConversionDone;


            if(using_fixpt)
                relCheckFilePath=this.hHDLDriver.cgInfo.fxpBldDir;
            else
                relCheckFilePath=pwd();
            end
        end



        function makehdlCheckReport(this,genChecks,openReport,cgDir,errorCheckReport)

            fcnName=this.functionName;
            fileName=[hdlgetparameter('module_prefix'),fcnName,'_hdl_conformance_report.html'];
            filePath=fullfile(cgDir,fileName);



            fid=fopen(filePath,'w','n','utf-8');
            if fid==-1
                error(message('hdlcoder:matlabhdlcoder:cannotopenfile',fileName));
            end


            reportTitle=message('hdlcoder:makecheckhdlreport:title',fcnName).getString();

            this.createHeader(fid,fcnName,reportTitle);

            bodyHeader=sprintf('%s\n',reportTitle);
            this.beginBody(fid,bodyHeader);


            [nerr,nwarn,nmsg,sortedChecks]=createCheckTable(this,fid);

            emlhdlcoder.EmlChecker.generateEmlGeneralReport(genChecks,fid);
            this.endBody(fid);
            fclose(fid);

            link=sprintf('<a href="matlab:web(''%s'')">%s</a>',filePath,fileName);
            hdldisp(message('hdlcoder:matlabhdlcoder:ConformanceCheckDone',link).getString());


            hdldisp(message('hdlcoder:matlabhdlcoder:ConformanceSummary',num2str(nerr),num2str(nwarn),num2str(nmsg)).getString());



            if openReport||nerr>0
                nameforuser=filePath;

                if(isempty(dir(nameforuser)))
                    relCheckFilePath=getCheckFilePath(this);
                    nameforuser=fullfile(relCheckFilePath,nameforuser);
                end



                if(errorCheckReport)

                    webHandleMsgId='MATLAB:web:BrowserOuptputArgRemovedInFutureRelease';
                    webWarnPrev=warning('query',webHandleMsgId);
                    warning('off',webHandleMsgId);
                    status=web(nameforuser);
                    warning(webWarnPrev.state,webHandleMsgId);
                    switch status
                    case 1
                        error(message('hdlcoder:matlabhdlcoder:webbrowsernotfound'))
                    case 2
                        error(message('hdlcoder:matlabhdlcoder:webbrowserfailed'))
                    otherwise

                    end
                    emlhdlcoder.WorkFlow.Manager.AddWebBrowser(nameforuser);
                else

                    [~,baseName,~]=fileparts(nameforuser);
                    matlabURL=['<a href="matlab:web(''',nameforuser,''')">',baseName,'</a>'];
                    hdldisp(message('hdlcoder:matlabhdlcoder:ConformanceWebLink',matlabURL).getString());
                end
            end


            if(isfield(this.hHDLDriver,'DebugLevel'))
                if(hdlCfg.DebugLevel>0)
                    check2str=@(x)sprintf('%s @ file %s , ID %s',x.message,x.filename,x.MessageID);
                    mesg=message('hdlcoder:makecheckhdlreport:mesg').getString();
                    arrayfun(@(x)fprintf([mesg,' : %s',check2str(x(itr))]),sortedChecks.messg)
                    arrayfun(@(x)warning(check2str(x(itr))),sortedChecks.warns);
                    arrayfun(@(x)error(check2str(x(itr))),sortedChecks.errs);
                end
            end

        end
    end
end



