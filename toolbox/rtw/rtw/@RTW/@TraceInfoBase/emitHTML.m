function emitHTML(h,filename,varargin)




    global isV2RtwReport;%#ok
    isV2RtwReport=Simulink.report.ReportInfo.featureReportV2&&isa(h,'RTW.TraceInfo');


    if isV2RtwReport
        codeLocFuncName='printCodeLocationsV2';
    else
        codeLocFuncName='printCodeLocations';
    end


    tag_html_begin='<HTML>';
    tag_html_end='</HTML>';
    tag_head_begin='<HEAD>';
    tag_head_end='</HEAD>';
    tag_meta='<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />';
    tag_title_begin='<TITLE>';
    tag_title_end='</TITLE>';
    tag_body_begin=['<BODY ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdTraceability'),'">'];
    tag_body_end='</BODY>';
    tag_table_begin='<TABLE class="AltRow" cellspacing="0">';
    tag_tr1_begin='<TR class="odd">';
    tag_tr0_begin='<TR class="even">';
    tag_table_end='</TABLE>';
    tag_tr_begin='<TR>';
    tag_tr_end='</TR>';
    tag_td_begin='<TD>';
    tag_td_end='</TD>';
    tag_th_begin='<TH>';
    tag_th_end='</TH>';
    tag_h1_begin='<H1>';
    tag_h1_end='</H1>';
    tag_h3_begin='<H3>';
    tag_h3_end='</H3>';
    tag_h4_begin='<H4>';
    tag_h4_end='</H4>';
    tag_p_begin='<P>';
    tag_p_end='</P>';


    tag_stylesheet='<LINK rel="stylesheet" type="text/css" href="rtwreport.css" />';
    tag_style_begin='<STYLE type="text/css">';
    tag_style_end='</STYLE>';

    tag_tablestyle=['TABLE { border-style: outset; border-width: 1px; '...
    ,'width: 100% } '];
    tag_tdthstyle='';

    tag_tr1='';
    tag_tr0='';
    tag_pstyle='P { margin-top: 0; margin-bottom: 0 } ';
    tag_style_pre='PRE { margin: 0 }';

    tag_ol_begin='<OL>';
    tag_ol_end='</OL>';
    tag_ul='UL';
    tag_li_begin='<LI>';
    tag_li_end='</LI>';

    tag_div='DIV';

    sfFeatureOn=true;

    if isempty(h.SourceSystem)
        currModel=h.Model;
    else
        currModel=h.TmpModel;
    end
    machine=[];%#ok
    if sfFeatureOn
        machine=find(get_param(h.Model,'Object'),'-isa','Stateflow.Machine','name',h.Model);
    end


    includeSl=true;
    includeUntraceable=true;
    includeSf=sfFeatureOn&&~isempty(machine);
    includeEml=sfFeatureOn;


    includeSlHyperlink=true;


    if nargin>2
        for k=1:2:nargin-2
            if~ischar(varargin{k+1})
                DAStudio.error('RTW:utility:invalidArgType','char array');
            elseif strcmp(varargin{k+1},'on')
                val=true;
            elseif strcmp(varargin{k+1},'off')
                val=false;
            else
                DAStudio.error('RTW:utility:invalidInputArgs',varargin{k+1});
            end
            switch varargin{k}
            case '-un'
                includeUntraceable=val;
            case '-sl'
                includeSl=val;
            case '-sf'
                if sfFeatureOn
                    includeSf=val;
                end
            case '-eml'
                if sfFeatureOn
                    includeEml=val;
                end
            case '-hyperlink'
                includeSlHyperlink=val;
            otherwise
                DAStudio.error('RTW:utility:invalidInputArgs',varargin{k});
            end
        end
    end

    fid=fopen(filename,'w','n','UTF-8');
    try

        locWrite(fid,tag_html_begin);


        locWrite(fid,tag_head_begin);


        if isV2RtwReport
            locWrite(fid,['<script>',coder.report.internal.getPostParentWindowMessageDef,'</script>']);
        end

        locWrite(fid,tag_meta);
        title=message('RTW:report:TraceabilityReportTitle',locEscape(currModel)).getString();
        locWrite(fid,[tag_title_begin,title,tag_title_end]);
        locWrite(fid,tag_stylesheet);
        locWrite(fid,[tag_style_begin...
        ,tag_tablestyle,tag_tdthstyle...
        ,tag_tr1,tag_tr0,tag_pstyle...
        ,tag_style_pre...
        ,tag_style_end]);
        coder.internal.slcoderReport('getTraceRptJS',fid,...
        h.ModelFileNameAtBuild,h.BuildDir,h.Target,true);
        locWrite(fid,tag_head_end);


        locWrite(fid,tag_body_begin);

        locWriteTagBegin(fid,tag_div,'title','title');

        locWrite(fid,[tag_h1_begin,title,tag_h1_end]);
        href_untraceable='href_untraceable';
        href_traceable='href_traceable';
        href_sys='href_sys';


        if(ispc&&isa(h,'RTW.TraceInfo')&&...
            (license('test','Cert_Kit_IEC')||license('test','Qual_Kit_DO'))&&...
            (~isempty(ver('do'))||~isempty(ver('iec'))))
            cr=newline;
            if(~strcmp(currModel,h.Model))
                currModel=h.Model;
            end

            if isV2RtwReport
                buttonCb=['RTW.TraceInfoBase.htmlExportTraceLaunch(\''',currModel,'\'')'];
                buttonStr=[cr,'<P align="right">',...
                '<A style="text-decoration: none;" title="',DAStudio.message('RTW:report:GenerateXLSButtonTooltip'),'" '...
                ,'href="javascript: void(0)"'...
                ,'onclick = "postParentWindowMessage({message:''legacyMCall'', expr:''',buttonCb,'''})">'...
                ,'<BUTTON name="MATLAB_link">',[DAStudio.message('RTW:report:GenerateXLSButton'),'...'],'</BUTTON>'...
                ,'</A></P>',cr];
            else
                buttonStr=[cr,'<P align="right">',...
                '<A style="text-decoration: none;" title="',DAStudio.message('RTW:report:GenerateXLSButtonTooltip'),'" '...
                ,'href="matlab:RTW.TraceInfoBase.htmlExportTraceLaunch(''',currModel,''')">'...
                ,'<BUTTON name="MATLAB_link">',DAStudio.message('RTW:report:GenerateXLSButton'),'</BUTTON>'...
                ,'</A></P>',cr];
            end
            locWrite(fid,buttonStr);
        end


        locWriteTagBegin(fid,tag_div,'toc','toc');
        locWrite(fid,[tag_h3_begin,DAStudio.message('RTW:report:TableOfContents'),tag_h3_end]);
        locWrite(fid,tag_ol_begin);
        if includeUntraceable
            locWrite(fid,[tag_li_begin,locLink(href_untraceable,...
            DAStudio.message('RTW:report:secEliminatedVirtualBlocks')),tag_li_end])
        end
        if includeSl||includeSf||includeEml
            title_traceable='';
            if includeSl
                title_traceable=DAStudio.message('RTW:report:SimulinkBlocks');
            end
            if includeSf
                if~isempty(title_traceable)
                    title_traceable=[title_traceable,' / '];
                end
                title_traceable=[title_traceable...
                ,DAStudio.message('RTW:report:StateflowObjects')];
            end
            if includeEml
                if~isempty(title_traceable)
                    title_traceable=[title_traceable,' / '];
                end
                title_traceable=[title_traceable...
                ,DAStudio.message('RTW:report:MATLABFunctions')];
            end
            title_traceable=[DAStudio.message('RTW:report:Traceable'),' '...
            ,title_traceable];
            locWrite(fid,[tag_li_begin,locLink(href_traceable,title_traceable)])
            locWriteTagBegin(fid,tag_ul,'toc_systems','toc_systems');
            for k=1:length(h.SystemMap)
                if locTestIncludeSys(h,k,includeSl,includeSf,includeEml)
                    locWrite(fid,[tag_li_begin,locLink([href_sys,num2str(k-1)],h.SystemMap(k).pathname),tag_li_end]);
                end
                if includeEml||includeSf
                    emhandles=locFindEMFunctions(machine,h.SystemMap(k).pathname);
                    for n=1:length(emhandles)
                        locWrite(fid,[tag_li_begin,locLink([href_sys,num2str(k-1),'_',num2str(n-1)],...
                        [h.SystemMap(k).pathname,'/',emhandles(n).Name]),tag_li_end]);
                    end
                end
            end
            locWriteTagEnd(fid,tag_ul);
            locWrite(fid,tag_li_end);
        end
        locWrite(fid,tag_ol_end);
        locWriteTagEnd(fid,tag_div);
        locWriteTagEnd(fid,tag_div);
        locWriteTagBegin(fid,tag_div,'contents','contents');

        tmp_registry=h.getRegistry();
        if includeUntraceable

            locWriteTagBegin(fid,tag_div,'section1','sec_eliminated_virtual');
            locWrite(fid,[tag_h3_begin,locSetLink(href_untraceable,...
            DAStudio.message('RTW:report:secEliminatedVirtualBlocks')),...
            tag_h3_end]);


            table_heading=[...
tag_table_begin...
            ,tag_tr_begin...
            ,tag_th_begin,DAStudio.message('RTW:report:BlockName'),tag_th_end...
            ,tag_th_begin,DAStudio.message('RTW:report:Comment'),tag_th_end...
            ,tag_tr_end...
            ];
            table_heading_written=false;

            len=length(tmp_registry);

            alt=0;
            reasonMap=h.getBlockReductionReasons;
            for k=1:len
                if~isempty(tmp_registry(k).location)
                    continue;
                end
                reg=tmp_registry(k);
                if~table_heading_written
                    locWrite(fid,table_heading);
                    table_heading_written=true;
                end
                if alt
                    locWrite(fid,tag_tr1_begin);
                else
                    locWrite(fid,tag_tr0_begin);
                end
                alt=1-alt;

                locWrite(fid,tag_td_begin);
                locWriteBlockName(fid,reg,includeSlHyperlink);
                locWrite(fid,tag_td_end);


                locWrite(fid,tag_td_begin);
                [~,comment]=h.getReason(reasonMap,reg);
                locWrite(fid,tag_p_begin);
                if~isempty(comment)
                    locWrite(fid,comment);
                else
                    locWrite(fid,DAStudio.message('RTW:report:TraceInfoNotAvailable'));
                end
                locWrite(fid,tag_p_end);
                locWrite(fid,tag_td_end);
                locWrite(fid,tag_tr_end);
            end
            if table_heading_written
                locWrite(fid,tag_table_end);
            else
                locWrite(fid,[tag_p_begin,DAStudio.message('RTW:report:NoEliminatedBlocks'),tag_p_end]);
            end
            locWriteTagEnd(fid,tag_div);
        end
        if includeSl||includeSf||includeEml

            locWriteTagBegin(fid,tag_div,'section1','sec_traceable');
            locWrite(fid,[tag_h3_begin,locSetLink(href_traceable,title_traceable),tag_h3_end]);

            table_heading=[...
tag_tr_begin...
            ,tag_th_begin,DAStudio.message('RTW:report:colObjectName'),tag_th_end...
            ,tag_th_begin,DAStudio.message('RTW:report:colCodeLocation'),tag_th_end...
            ,tag_tr_end];

            for sys=1:length(h.SystemMap)
                if isempty(h.SystemMap(sys))
                    continue
                end
                [first,last]=locGetRegistryIndices(h,sys);
                if isempty(first)||first>last
                    continue
                end

                systemType=h.SystemMap(sys).type;
                includeSfEmlOnly=false;
                switch systemType
                case 'Root system'
                    if~includeSl,continue,end
                    isSf=false;
                    systemTypeMsg=DAStudio.message('RTW:report:RootSystem');
                case 'Subsystem'
                    if~includeSl,continue,end
                    isSf=false;
                    systemTypeMsg=DAStudio.message('RTW:report:Subsystem');
                case 'Chart'
                    if~includeSf&&~includeEml,continue,end
                    isSf=true;
                    if~includeSf
                        includeSfEmlOnly=true;
                    end
                    systemTypeMsg=DAStudio.message('RTW:report:Chart');
                case 'MATLAB Function'
                    if~includeEml,continue,end
                    isSf=true;
                    systemTypeMsg=DAStudio.message('RTW:report:MATLABFunction');
                case 'Truth Table'
                    continue
                otherwise
                    isSf=false;
                    systemTypeMsg=systemType;
                end

                if includeSlHyperlink
                    sysname=h.SystemMap(sys).hyperlink;
                    if isempty(sysname)
                        sysname=locEscape(h.SystemMap(sys).pathname);
                    elseif isV2RtwReport


                        newStr=['<a href="javascript: void(0)" onclick="postParentWindowMessage({message:''legacyMCall'', expr:''coder.internal.code2model(\\'''...
                        ,h.SystemMap(sys).sid,'\\'')''})"  name="code2model">'];
                        sysname=regexprep(sysname,'<a.+?name="code2model">',newStr);
                    end
                else
                    sysname=locEscape(h.SystemMap(sys).pathname);
                end

                if~includeSfEmlOnly
                    locWriteTagBegin(fid,tag_div,'section2',['sec_traceable_',num2str(sys)]);
                    locWrite(fid,[tag_h4_begin,systemTypeMsg,': ',locSetLink([href_sys,num2str(sys-1)],sysname),tag_h4_end]);
                end


                if strcmp(systemType,'MATLAB Function')
                    hBlk=get_param(h.SystemMap(sys).pathname,'Handle');
                    emchart=sfprivate('block2chart',hBlk);
                    hEml=idToHandle(slroot,emchart);
                    if includeSlHyperlink
                        hTrace=h;
                    else
                        hTrace=[];
                    end
                    coder.internal.eml2html(fid,hEml(1),...
                    hTrace,h.SystemMap(sys).pathname);
                    locWriteTagEnd(fid,tag_div);
                    continue;
                end

                table_heading_written=false;

                if~includeSfEmlOnly
                    alt=0;
                    for k=first:last
                        if isempty(tmp_registry(k).location)
                            continue
                        end
                        reg=tmp_registry(k);

                        if isSf&&locIsSfAuxOrSimFcn(reg.rtwname)
                            continue
                        end

                        if~table_heading_written
                            locWrite(fid,tag_table_begin);
                            locWrite(fid,table_heading);
                            table_heading_written=true;
                        end
                        if alt
                            locWrite(fid,tag_tr1_begin);
                        else
                            locWrite(fid,tag_tr0_begin);
                        end
                        alt=1-alt;


                        locWrite(fid,tag_td_begin);
                        if locIsSfObj(reg.rtwname)
                            locWriteSfType(fid,reg.pathname);
                        end
                        locWriteBlockName(fid,reg,includeSlHyperlink);
                        locWrite(fid,tag_td_end);


                        locWrite(fid,tag_td_begin);
                        coder.internal.slcoderReport(codeLocFuncName,fid,reg.location,true);
                        locWrite(fid,tag_td_end);
                        locWrite(fid,tag_tr_end);
                    end

                    if table_heading_written
                        locWrite(fid,tag_table_end);
                    else
                        locWrite(fid,[tag_p_begin,DAStudio.message('RTW:report:NoTraceableObjects',systemType),tag_p_end]);
                    end

                    locWriteTagEnd(fid,tag_div);
                end


                if includeEml&&isSf
                    eh=locFindEMFunctions(machine,h.SystemMap(sys).pathname);
                    if~isempty(eh)
                        for k=1:length(eh)
                            locWriteTagBegin(fid,tag_div,'section3',['sec_traceable_',num2str(sys),'_eml_fcn',num2str(k)]);
                            hlink=coder.internal.slcoderReport('get_code2model_hyperlink',...
                            Simulink.ID.getSID(eh(k)),'',Simulink.ID.getFullName(eh(k)));
                            locWrite(fid,[tag_h4_begin,...
                            [DAStudio.message('RTW:report:MATLABFunction'),': ']...
                            ,locSetLink([href_sys,num2str(sys-1),'_',num2str(k-1)],hlink),tag_h4_end]);

                            coder.internal.eml2html(fid,eh(k),h,...
                            h.SystemMap(sys).pathname);
                            locWriteTagEnd(fid,tag_div);
                        end
                    end
                end
            end
            locWriteTagEnd(fid,tag_div);
        end


        locWriteTagEnd(fid,tag_div);
        locWrite(fid,tag_body_end);
        locWrite(fid,tag_html_end);
    catch me
        fclose(fid);
        clear('global','isV2RtwReport');
        rethrow(me);
    end

    fclose(fid);
    clear('global','isV2RtwReport');

    function out=locEscape(content)

        out=strrep(content,'&','&amp;');
        out=strrep(out,'<','&lt;');
        out=strrep(out,'>','&gt;');

        function locWriteBlockName(fid,reg,includeHyperlink)


            global isV2RtwReport %#ok
            if~isempty(reg.hyperlink)&&includeHyperlink
                if~isV2RtwReport

                    locWrite(fid,reg.hyperlink);
                else

                    newStr=['<a href="javascript: void(0)" onclick="postParentWindowMessage({message:''legacyMCall'', expr:''coder.internal.code2model(\\'''...
                    ,reg.sid,'\\'')''})"  name="code2model"><font'];
                    newLink=regexprep(reg.hyperlink,'<a.+?><font',newStr);
                    locWrite(fid,newLink);
                end
            else
                locWrite(fid,locEscape(reg.rtwname));
            end

            function locWrite(fid,s)
                fwrite(fid,s,'char');

                function out=locIsSfObj(rtwname)


                    k=strfind(rtwname,'>');
                    out=length(rtwname)>k(1)&&rtwname(k(1)+1)==':';

                    function locWriteSfType(fid,pathname)
                        [typename,name]=RTW.getSfTypeName(pathname);
                        if~isempty(typename)
                            locWrite(fid,[typename,' ']);
                            if~isempty(name)
                                locWrite(fid,['''',name,''' ']);
                            end
                        end

                        function out=locIsSfAuxOrSimFcn(rtwname)
                            out=length(strfind(rtwname,':'))~=1;

                            function out=locLink(tag,text)
                                out=['<A href="#',tag,'">',text,'</A>'];

                                function out=locSetLink(tag,text)
                                    out=['<A id="',tag,'">',text,'</A>'];

                                    function[first,last]=locGetRegistryIndices(h,sys)

                                        first=h.SystemMap(sys).location;
                                        last=[];
                                        if isempty(first),return,end
                                        for k=sys+1:length(h.SystemMap)
                                            if~isempty(h.SystemMap(k).location)
                                                last=h.SystemMap(k).location-1;
                                                break
                                            end
                                        end
                                        if isempty(last)
                                            last=length(h.Registry);
                                        end

                                        function out=locTestIncludeSys(h,sys,includeSl,includeSf,includeEml)
                                            out=false;

                                            [first,last]=locGetRegistryIndices(h,sys);
                                            if isempty(first)||first>last
                                                return
                                            end


                                            switch h.SystemMap(sys).type
                                            case{'Root system','Subsystem'}
                                                if~includeSl,return,end
                                            case 'Chart'
                                                if~includeSf,return,end
                                            case 'MATLAB Function'
                                                if~includeEml,return,end
                                            case 'Truth Table'
                                                return
                                            end
                                            out=true;

                                            function locWriteTagBegin(fid,tag,class,id)
                                                locWrite(fid,['<',tag,' class="',class,'" id="',id,'">']);

                                                function locWriteTagEnd(fid,tag)
                                                    locWrite(fid,['</',tag,'>']);

                                                    function out=locFindEMFunctions(machine,blockpath)

                                                        chart=[];
                                                        out=[];

                                                        if~isempty(machine)
                                                            chart=find(machine,'-isa','Stateflow.Chart','Path',blockpath);
                                                        end

                                                        if~isempty(chart)
                                                            out=find(chart,'-isa','Stateflow.EMFunction');
                                                        end







