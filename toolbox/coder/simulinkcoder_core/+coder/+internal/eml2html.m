function varargout=eml2html(fid,hEml,hTrace,block)




    if isempty(fid)
        nargoutchk(1,1)
    else
        nargoutchk(0,1)
    end

    if nargin<4


        block=hEml.Path;
    end
    codelink=~isempty(fid);
    emlScript=locGetEmbeddedMATLABScript(hEml,block,hTrace,codelink);
    if nargout==1
        varargout{1}=emlScript;
    end
    if isempty(fid)
        return
    end

    fwrite(fid,'<TABLE class="eml">');
    fwrite(fid,'<TR><TH></TH><TH>Script</TH><TH>Code Location</TH></TR>');
    alt=0;

    maxlength=41;
    for k=1:size(emlScript,1)
        fprintf(fid,'\n<TR class="d%d"><TD>',alt);
        alt=1-alt;
        fwrite(fid,emlScript{k,1});
        fprintf(fid,'</TD><TD><PRE>');
        line=emlScript{k,2};
        if length(line)<=maxlength
            fwrite(fid,locEscape(line));
        else
            ldots=' <FONT color="blue">...</FONT>';
            fwrite(fid,[locEscape(line(1:maxlength-4)),ldots]);
        end
        fwrite(fid,'</PRE></TD><TD>');
        fwrite(fid,emlScript{k,3});
        fwrite(fid,'</TD></TR>');
    end
    fwrite(fid,'</TABLE>');





    function out=locGetHyperlink(registry,ssid,name)

        if~isempty(ssid)
            sid=[registry.sid,':',ssid];
            pid=Simulink.ID.getParent(sid);
            out=coder.internal.slcoderReport('get_code2model_hyperlink',sid,pid,name);
        else
            href=[strtok(registry.hyperlink,'>'),'>'];
            out=[href,name,'</a>'];
        end

        function out=locEscape(txt)

            txt=strrep(txt,'&','&amp;');
            txt=strrep(txt,'<','&lt;');
            out=strrep(txt,'>','&gt;');

            function out=locGetEmbeddedMATLABScript(hEml,block,hTrace,bCodeLink)


                out=[];
                registry=[];
                if~isempty(hTrace)
                    try
                        tmp=Simulink.ID.getSID(block);
                        block=tmp;
                    catch
                    end

                    registry=hTrace.getRegistry(block);
                end


                if isa(hEml,'Stateflow.EMChart')
                    chart=sf('get',hEml.Id,'.states');
                    ssIdNum=sf('get',chart,'.ssIdNumber');
                elseif isa(hEml,'Stateflow.EMFunction')
                    ssIdNum=hEml.SSIdNumber;
                else
                    return
                end

                emlScript=hEml.Script;


                lines=textscan(emlScript,'%s','Whitespace','','Delimiter','\n');
                lines=lines{1};
                blank=false;
                for n=1:length(lines)
                    tok=strtok(lines{n});
                    if~isempty(tok)
                        if tok(1)=='%',continue,end
                        blank=false;
                    else
                        if blank,continue,end
                        blank=true;
                    end
                    linenum=num2str(n);

                    if~isempty(registry)
                        out{end+1,1}=locGetHyperlink(registry,[num2str(ssIdNum),':',linenum],linenum);%#ok
                    else
                        out{end+1,1}=linenum;%#ok
                    end

                    out{end,2}=lines{n};

                    if~isempty(hTrace)

                        locs=hTrace.getCodeLocations([block,sprintf(':%d:%d',ssIdNum,n)]);
                        if rtw.report.ReportInfo.featureReportV2

                            location=coder.internal.slcoderReport('printCodeLocationsV2',[],locs,bCodeLink);
                        else
                            location=coder.internal.slcoderReport('printCodeLocations',[],locs,bCodeLink);
                        end
                        out{end,3}=location;
                    else
                        out{end,3}='';
                    end
                end


