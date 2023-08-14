function pm_profilerreport(iProfInfo,iOutputDir,iModelName,iBlockName)







    structArray=iProfInfo.FunctionTable;
    clockPrec=iProfInfo.ClockPrecision;
    clockSpeed=iProfInfo.ClockSpeed;
    pname=iProfInfo.Name;

    structArray=ComputeTimes(structArray);

    structArray=ParseFunctionNames(pname,structArray,iModelName);



    if isempty(iOutputDir)
        fname=tempname;
    else
        fname=fullfile(iOutputDir,iModelName);
    end
    [path,name]=fileparts(fname);
    if(isempty(path))
        path=pwd;
    end
    frameName=[name,'.html'];
    contentsName=[name,'_contents','.html'];
    summaryName=[name,'_summary','.html'];
    detailsName=[name,'_details','.html'];
    helpName=[name,'_help','.html'];

    PrintHTMLFrames(path,frameName,contentsName,summaryName,pname);
    PrintHTMLContentsFrame(path,iModelName,contentsName,summaryName,...
    detailsName,helpName,pname);
    PrintHTMLSummaryFrame(path,summaryName,detailsName,...
    structArray,clockPrec,clockSpeed,pname,iBlockName);
    PrintHTMLFunctionsFrame(path,detailsName,structArray,...
    clockPrec,pname);


    if strcmp(pname,'Simulink')
        PrintHTMLHelpFrame(path,helpName,pname);
    end

    htmlFile=fullfile(path,frameName);





    function PrintHTMLFrames(path,frameName,contentsName,summaryName,pname)


        fid=fopen(fullfile(path,frameName),'wt');
        if(fid<0)
            pm_error('physmod:common:foundation:mli:pm_profilerreport:CannotOpenFileWrite',fullfile(path,frameName));
        end
        fprintf(fid,'<html> \n');

        fprintf(fid,'<script language="JavaScript">\n');
        fprintf(fid,'        setTimeout ("forceToTop()", 0);\n');
        fprintf(fid,'        function forceToTop() {\n');
        fprintf(fid,'                if (self != top) {\n');
        fprintf(fid,'                     top.location = document.location;\n');
        fprintf(fid,'                }\n');
        fprintf(fid,'        }\n');
        fprintf(fid,'</script>\n');

        fprintf(fid,'<head> \n');
        fprintf(fid,'<title>%s Profiler Report</title>\n',pname);
        fprintf(fid,'</head>\n');

        fprintf(fid,'<frameset rows="50,*">\n');
        fprintf(fid,'   <frame name="Frame 1" src="%s" scrolling="auto"> \n',...
        contentsName);
        fprintf(fid,'   <frame name="Frame 2" src="%s" scrolling="auto"> \n',...
        summaryName);

        fprintf(fid,'</frameset> \n');

        fprintf(fid,'<body> \n');
        fprintf(fid,'</body> \n');
        fprintf(fid,'</html> \n');
        fclose(fid);






        function PrintHTMLContentsFrame(path,iModelName,contentsName,summaryName,...
            detailsName,helpName,pname)


            fid=fopen(fullfile(path,contentsName),'wt');
            if(fid<0)
                pm_error('physmod:common:foundation:mli:pm_profilerreport:CannotOpenFileWrite',fullfile(path,contentsName));
            end
            fprintf(fid,'<html> \n');
            fprintf(fid,'<head> \n');
            fprintf(fid,'</head>\n');

            fprintf(fid,'<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
            fprintf(fid,'<a href="%s" target="Frame 2">Summary</a>\n',summaryName);
            fprintf(fid,'&nbsp;|&nbsp; <a href="%s" target="Frame 2">Function Details</a>\n',...
            detailsName);
            if strcmp(pname,'Simulink')
                fprintf(fid,'&nbsp;|&nbsp; <a href="%s" target="Frame 2">Simulink Profiler Help</a>\n',...
                helpName);
                fprintf(fid,['&nbsp;|&nbsp; <a href="matlab: slprofile_unhilite_system'...
                ,' %s"> Clear Highlighted Blocks </a>\n'],iModelName);
            end
            fprintf(fid,'</body>\n');
            fprintf(fid,'</html> \n');
            fclose(fid);






            function PrintHTMLSummaryFrame(path,summaryName,detailsName,...
                structArray,clockPrec,clockSpeed,pname,iBlockName)


                fid=fopen(fullfile(path,summaryName),'wt');
                if(fid<0)
                    pm_error('physmod:common:foundation:mli:pm_profilerreport:CannotOpenFileWrite',fullfile(path,summaryName));
                end

                fprintf(fid,'<html>\n');
                fprintf(fid,'<head>\n');
                fprintf(fid,'</head>\n');
                fprintf(fid,'<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
                fprintf(fid,'<h1>%s Profile Report:  Summary</h1>\n',pname);
                fprintf(fid,'<h2>%s</h2>\n',iBlockName);

                fprintf(fid,'<p><em> Report generated %s </em></p>\n',datestr(now));

                totalTime=sum([structArray.SelfTime]);
                [counts,typenames]=CountFuncs(structArray);

                fprintf(fid,'<table>\n');
                fprintf(fid,'<tr> <td> Total recorded time: </td>\n');
                fprintf(fid,'<td align="right"> %6.2f&nbsp;s </td> </tr>\n',totalTime);

                for k=1:length(counts)
                    if(counts(k)>0)
                        fprintf(fid,'<tr> <td> Number of %ss: </td>\n',typenames{k});
                        fprintf(fid,'<td align="right"> %d </td> </tr>\n',counts(k));
                    end
                end

                fprintf(fid,'<tr> <td> Clock precision: </td>\n');

                digits=ceil(-log10(clockPrec));

                fprintf(fid,'<td align="right"> %s&nbsp;s </td></tr>\n',FormatTime(clockPrec,digits));

                if(clockSpeed~=0)
                    fprintf(fid,'<tr> <td> Clock Speed: </td>\n');
                    fprintf(fid,'<td align="right"> %5.0f&nbsp;Mhz </td></tr>\n',clockSpeed);
                end

                fprintf(fid,'</table>\n\n');

                PrintHTMLFunctionList(pname,fid,detailsName,structArray,clockPrec);


                fprintf(fid,'</body>\n');
                fprintf(fid,'</html>\n');

                fclose(fid);






                function PrintHTMLHelpFrame(path,helpName,pname)


                    fid=fopen(fullfile(path,helpName),'wt');
                    if(fid<0)
                        pm_error('physmod:common:foundation:mli:pm_profilerreport:CannotOpenFileWrite',fullfile(path,helpName));
                    end

                    fprintf(fid,'<html>\n');
                    fprintf(fid,'<head>\n');
                    fprintf(fid,'</head>\n');
                    fprintf(fid,'<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
                    fprintf(fid,'<h1>%s Profile Report:  Simulink Profiler Help</h1>\n',pname);

                    fprintf(fid,'<h2> Summary Legend: </h2>\n');
                    fprintf(fid,'<dl> \n');
                    fprintf(fid,['<dt> Total recorded time: <dd> Total time for simulating'...
                    ,' the model.\n']);
                    fprintf(fid,['<dt> Number of Block Methods: <dd> Total number of'...
                    ,' methods called by individual blocks in the model.\n']);
                    fprintf(fid,['<dt> Number of Internal Methods: <dd> Total number'...
                    ,' of internal Simulink methods called by the model.\n']);
                    fprintf(fid,['<dt> Number of Nonvirtual Subsystem Methods: <dd>'...
                    ,' Number of methods called by the model and any'...
                    ,' nonvirtual subsystems in the model.\n']);
                    fprintf(fid,['<dt> Clock precision: <dd> Precision of the profiler\''s'...
                    ,' time measurement.\n']);
                    fprintf(fid,'</dl>\n');
                    fprintf(fid,'<h2> Function List Legend: </h2>\n');
                    fprintf(fid,'<dl>\n');
                    fprintf(fid,['<dt> Time: <dd> Time spent in this function, including'...
                    ,' all child functions called.\n']);
                    fprintf(fid,['<dt> Calls: <dd> Number of times this function was'...
                    ,' called.\n']);
                    fprintf(fid,'<dt> Time/call: <dd> Time spent per call.\n');
                    fprintf(fid,['<dt> Self time: <dd> Total time spent in this function, '...
                    ,'not including any calls to child functions.\n']);
                    fprintf(fid,['<dt> Location: <dd> Link to the location of the block'...
                    ,' in your model.  Use the link "Clear Hilited Blocks"'...
                    ,'at the top of the page to unhilite all blocks.'...
                    ,' (Note: you must use the MATLAB Help'...
                    ,' browser to use these hyperlinks).\n']);
                    fprintf(fid,'</dl> \n');
                    fprintf(fid,['Note: In accelerated mode, individual blocks will not'...
                    ,' show up in the profiler, unless they are executed internally'...
                    ,' in Simulink (e.g. a scope runs in Simulink instead'...
                    ,' of the generated code).  Rerun in normal mode to'...
                    ,' get a more detailed analysis of the simulation.\n']);

                    fprintf(fid,'<h2> Model execution pseudocode: </h2>\n');
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,'<li>Sim()\n');
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,'<li>ModelInitialize() - Set up the model for simulation.\n');
                    fprintf(fid,['<li>ModelExecute() - Advance in time from '...
                    ,'t = Tstart to Tfinal.\n']);
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,['<li>Output() - Execute the output methods of blocks'...
                    ,' in the model at time t.\n']);
                    fprintf(fid,['<li>Update() - Execute the update methods of blocks'...
                    ,' in the model at time t.\n']);
                    fprintf(fid,'<li>Integrate states from t to tnew (minor time steps).\n');
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,['<li> Compute states from derivs using repeated calls'...
                    ,' to:\n']);
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,'<li>MinorOutput()\n');
                    fprintf(fid,'<li>MinorDeriv()\n');
                    fprintf(fid,'</ul>\n');
                    fprintf(fid,['<li>Locate any zero crossings; reset t and the'...
                    ,' states accordingly using repeated calls to:\n']);
                    fprintf(fid,'<ul>\n');
                    fprintf(fid,'<li>MinorOutput()\n');
                    fprintf(fid,'<li>MinorZeroCrossings()\n');
                    fprintf(fid,'</ul>\n');
                    fprintf(fid,'</ul>\n');
                    fprintf(fid,'<li>EndIntegrate\n');
                    fprintf(fid,'<li>Set time t = tnew.\n');
                    fprintf(fid,'</ul>\n');
                    fprintf(fid,'<li>EndModelExecute\n');
                    fprintf(fid,'<li>ModelTerminate\n');
                    fprintf(fid,'</ul>\n');
                    fprintf(fid,'<li>EndSim\n');
                    fprintf(fid,'</ul>\n');

                    fprintf(fid,'</body>\n');
                    fprintf(fid,'</html>\n');

                    fclose(fid);






                    function out=Anchor(str,name)


                        out=sprintf('<a name="%s"> %s </a>',name,str);






                        function PrintHTMLFunctionList(pname,fid,detailsName,structArray,clockPrec)


                            digits1=ceil(-log10(clockPrec));
                            digits2=digits1+ceil(log10(max([structArray.NumCalls])));

                            [junk,sortedIdx]=sort([structArray.TotalTime]);%#ok
                            sortedIdx=sortedIdx(end:-1:1);

                            totalTime=sum([structArray.SelfTime]);
                            if(totalTime==0)
                                totalTime=eps;
                            end

                            fprintf(fid,'<h2> %s </h2> \n\n',Anchor('Function List','Function List'));

                            fprintf(fid,'<table border=1>\n');
                            fprintf(fid,'<th align=left> <small> Name </small> </th>\n');
                            fprintf(fid,'<th align=left colspan=2> <small> Time </small> </th>\n');
                            fprintf(fid,'<th align=left> <small> Calls </small> </th>\n');
                            fprintf(fid,'<th align=left> <small> Time/call </small> </th>\n');
                            fprintf(fid,'<th align=left colspan=2> <small> Self time </small> </th>\n');

                            loc='Location';
                            if strcmp(pname,'Simulink')
                                loc=[loc,' (must use MATLAB Web Browser to view)'];
                            end
                            fprintf(fid,['<th align=left> <small> ',loc,' </small> </th>\n']);

                            fprintf(fid,'</tr>\n');

                            for k=1:length(structArray)
                                thisStruct=structArray(sortedIdx(k));

                                href=sprintf('%s#Fcn_%d',detailsName,sortedIdx(k));

                                fprintf(fid,'<tr>\n');

                                fprintf(fid,'<td>%s</td> \n',...
                                Link(FormatName(thisStruct.FunctionName),href));
                                fprintf(fid,'<td align="right"> <small> %s </small> </td>\n',...
                                FormatTime(thisStruct.TotalTime,digits1));
                                fprintf(fid,'<td align="right"> <small> %5.1f%% </small> </td>\n',...
                                rmnegzero(thisStruct.TotalTime*100/totalTime));
                                fprintf(fid,'<td align="right"> <small> %d </small> </td>\n',...
                                thisStruct.NumCalls);
                                fprintf(fid,'<td align="right"> <small> %s </small> </td>\n',...
                                FormatTime(thisStruct.TotalTime/thisStruct.NumCalls,digits2));
                                fprintf(fid,'<td align="right"> <small> %s </small> </td>\n',...
                                FormatTime(thisStruct.SelfTime,digits1));
                                fprintf(fid,'<td align="right"> <small> %5.1f%% </small> </td>\n',...
                                rmnegzero(thisStruct.SelfTime*100/totalTime));
                                if(~isempty(thisStruct.FileName))
                                    fprintf(fid,'<td> %s </td>\n',FormatPath(pname,thisStruct.FileName));
                                else
                                    fprintf(fid,'<td> <small> <em> %s </em> </small> </td>\n',...
                                    thisStruct.Type);
                                end

                                fprintf(fid,'</tr>\n');
                            end

                            fprintf(fid,'</table>\n');






                            function oParsedArray=ParseFunctionNames(pName,iStructArray,iModelName)

                                oParsedArray=iStructArray;




                                if strcmp(pName,'Simulink')

                                    for i=1:length(iStructArray)

                                        iStruct=iStructArray(i);
                                        iStruct.FunctionName=iStruct.CompleteName;
                                        oParsedArray(i).FunctionName=iStruct.CompleteName;
                                        switch(iStruct.Type)

                                        case 'Internal Method'
                                            oParsedArray(i).FileName=iModelName;

                                        case{'Nonvirtual Subsystem Method','Block Method'}


                                            openParens=strfind(iStruct.FunctionName,'(');
                                            oParsedArray(i).FileName=iStruct.FunctionName(1:openParens(end)-2);

                                        end
                                    end
                                else


                                    for i=1:length(iStructArray)

                                        iStruct=iStructArray(i);
                                        iStruct.FunctionName=iStruct.CompleteName;
                                        oParsedArray(i).FunctionName=iStruct.CompleteName;
                                        switch(iStruct.Type)

                                        case{'Normal Function','Output Function','Void Function',...
                                            'Script','Generate Script'}
                                            openParens=strfind(iStruct.FunctionName,'(');
                                            oParsedArray(i).FileName=iStruct.FunctionName(openParens(end)+1:end-1);
                                            oParsedArray(i).FunctionName=iStruct.FunctionName(1:openParens(end)-1);

                                        end
                                    end
                                end





                                function out=Link(in,href)


                                    out=sprintf('<a href="%s">%s</a>',href,in);




                                    function out=FormatName(name)


                                        out=sprintf('<font color="#0000FF"><tt><b>%s</b></tt></font>',...
                                        name);




                                        function v=rmnegzero(v)

                                            if(abs(v)<sqrt(eps))
                                                v=0.0;
                                            end




                                            function out=FormatTime(seconds,digits)

                                                formatStr=sprintf('%%.%df',digits);
                                                out=sprintf(formatStr,rmnegzero(seconds));




                                                function out=FormatPath(pname,pathStr)


                                                    if strcmp(pname,'Simulink')

                                                        newline=sprintf('\n');
                                                        tab=sprintf('\t');

                                                        encodedPath='';
                                                        for i=1:length(pathStr)
                                                            switch(pathStr(i))
                                                            case '\'
                                                                encodedPath(end+1:end+2)='\\';
                                                            case ' '
                                                                encodedPath(end+1:end+2)='\s';
                                                            case tab
                                                                encodedPath(end+1:end+2)='\t';
                                                            case newline
                                                                encodedPath(end+1:end+2)='\n';
                                                            case ''''
                                                                encodedPath(end+1:end+2)='\T';
                                                            case '"'
                                                                encodedPath(end+1:end+2)='\Q';
                                                            case '?'
                                                                encodedPath(end+1:end+2)='\q';
                                                            otherwise
                                                                encodedPath(end+1)=pathStr(i);
                                                            end
                                                        end

                                                        href=['matlab: slprofile_hilite_system(''encoded-path'',''',encodedPath,''');'];

                                                    else
                                                        pathStr=strrep(pathStr,'\','/');
                                                        href=['file:///',pathStr];
                                                    end
                                                    out=sprintf('<tt><a href="%s">%s</a></tt>',href,pathStr);






                                                    function PrintHTMLFunctionsFrame(path,detailsName,...
                                                        structArray,clockPrec,pname)


                                                        fid=fopen(fullfile(path,detailsName),'wt');
                                                        if(fid<0)
                                                            pm_error('physmod:common:foundation:mli:pm_profilerreport:CannotOpenFileWrite',fullfile(path,detailsName));
                                                        end

                                                        fprintf(fid,'<html>\n');
                                                        fprintf(fid,'<head>\n');
                                                        fprintf(fid,'</head>\n');
                                                        fprintf(fid,'<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');

                                                        [junk,sortedIdx]=sort([structArray.TotalTime]);%#ok
                                                        sortedIdx=sortedIdx(end:-1:1);

                                                        totalTime=sum([structArray.SelfTime]);

                                                        fprintf(fid,'<h1>%s Profile Report:  Function Details</h1>\n',pname);

                                                        fprintf(fid,'<dl>\n');
                                                        for k=1:length(structArray)
                                                            PrintHTMLFunctionDetails(fid,pname,structArray,...
                                                            sortedIdx(k),totalTime,clockPrec);
                                                        end
                                                        fprintf(fid,'</dl>\n');

                                                        fprintf(fid,'</body>\n');
                                                        fprintf(fid,'</html>\n');

                                                        fclose(fid);






                                                        function PrintHTMLFunctionDetails(fid,pname,structArray,p,...
                                                            totalTime,clockPrec)


                                                            funcStruct=structArray(p);
                                                            refStr=sprintf('Fcn_%d',p);
                                                            formattedName=FormatName(funcStruct.FunctionName);
                                                            digits1=ceil(-log10(clockPrec));
                                                            digits2=digits1+ceil(log10(max([structArray.NumCalls])));

                                                            fprintf(fid,'<dt>\n');
                                                            fprintf(fid,'<hr size=5 noshade>\n');
                                                            if(isempty(funcStruct.FileName))
                                                                fprintf(fid,'%s &nbsp;&nbsp;&nbsp;&nbsp;<em>%s</em><br>\n',...
                                                                Anchor(formattedName,refStr),funcStruct.Type);
                                                            else
                                                                fprintf(fid,'%s &nbsp;&nbsp;&nbsp;&nbsp;%s<br>\n',...
                                                                Anchor(formattedName,refStr),...
                                                                FormatPath(pname,funcStruct.FileName));
                                                            end

                                                            fprintf(fid,'Time: %s s &nbsp;&nbsp; (%4.1f%%)<br>\n',...
                                                            FormatTime(funcStruct.TotalTime,digits1),...
                                                            rmnegzero(100*funcStruct.TotalTime/(max(totalTime,eps))));
                                                            fprintf(fid,'Calls: %d <br>\n',funcStruct.NumCalls);
                                                            fprintf(fid,'Self time: %s s &nbsp;&nbsp; (%4.1f%%)<br><br>\n',...
                                                            FormatTime(funcStruct.SelfTime,digits1),...
                                                            rmnegzero(100*funcStruct.TotalTime/(max(totalTime,eps))));

                                                            fprintf(fid,'<dd>\n');
                                                            fprintf(fid,'<table border=1>\n');
                                                            fprintf(fid,'<th align=left> <small> Function: </small> </th>\n');
                                                            fprintf(fid,'<th align=left colspan=2> <small> Time </small> </th>\n');
                                                            fprintf(fid,'<th align=left> <small> Calls </small> </th>\n');
                                                            fprintf(fid,'<th align=left> <small> Time/call </small> </th>\n');
                                                            fprintf(fid,'</tr>\n');

                                                            fprintf(fid,'<tr>\n');
                                                            fprintf(fid,'<td> %s </td>\n',formattedName);
                                                            fprintf(fid,'<td align=right> <small> %s </small> </td>\n',...
                                                            FormatTime(funcStruct.TotalTime,digits1));
                                                            fprintf(fid,'<td> &nbsp; </td>\n');
                                                            fprintf(fid,'<td align=right> <small> %d </small>\n',funcStruct.NumCalls);
                                                            fprintf(fid,'<td align=right> <small> %s </small> </td>\n',...
                                                            FormatTime(funcStruct.TotalTime/funcStruct.NumCalls,digits2));
                                                            fprintf(fid,'</tr>\n');

                                                            fprintf(fid,'<tr> <td colspan=5> &nbsp; </tr>\n');

                                                            fprintf(fid,'<tr> <td colspan=5> <small> <b>Parent functions:</b> </small> </td> </tr>\n');
                                                            if(isempty(funcStruct.Parents))
                                                                fprintf(fid,'<tr> <td colspan=5> <small> <em> none </em> </small> </td> </tr> \n');
                                                            else
                                                                for k=1:length(funcStruct.Parents)
                                                                    href=sprintf('#Fcn_%d',funcStruct.Parents(k).Index);
                                                                    parentName=FormatName(structArray(funcStruct.Parents(k).Index).FunctionName);
                                                                    fprintf(fid,'<tr>\n');
                                                                    fprintf(fid,'<td colspan=3> %s </td>\n',Link(parentName,href));
                                                                    fprintf(fid,'<td align=right> <small> %d </small> </td>\n',...
                                                                    funcStruct.Parents(k).NumCalls);
                                                                    fprintf(fid,'<td> &nbsp; </td>\n');
                                                                    fprintf(fid,'<tr>\n');
                                                                end
                                                            end

                                                            fprintf(fid,'<tr> <td colspan=5> &nbsp; </tr>\n');

                                                            fprintf(fid,'<tr> <td colspan=5> <small> <b>Child functions:</b> </small> </td> </tr>\n');
                                                            kids=funcStruct.Children;
                                                            if(isempty(kids))
                                                                fprintf(fid,'<tr> <td colspan=5> <small> <em> none </em> </small> </td> </tr> \n');
                                                            else
                                                                [junk,idx]=sort(-[kids.TotalTime]);%#ok
                                                                kids=kids(idx);
                                                                for k=1:length(kids)
                                                                    href=sprintf('#Fcn_%d',kids(k).Index);
                                                                    childName=FormatName(structArray(kids(k).Index).FunctionName);
                                                                    fprintf(fid,'<tr>\n');
                                                                    fprintf(fid,'<td> %s </td>\n',Link(childName,href));
                                                                    fprintf(fid,'<td align=right> <small> %s </small> </td>\n',...
                                                                    FormatTime(kids(k).TotalTime,digits1));
                                                                    fprintf(fid,'<td align=right> <small> %4.1f%% </small> </td>\n',...
                                                                    100*kids(k).TotalTime/max(funcStruct.TotalTime,eps));
                                                                    fprintf(fid,'<td align=right> <small> %d </small> </td>\n',...
                                                                    kids(k).NumCalls);
                                                                    fprintf(fid,'<td align=right> <small> %s </small> </td>\n',...
                                                                    FormatTime(kids(k).TotalTime/...
                                                                    kids(k).NumCalls,digits2));
                                                                    fprintf(fid,'<tr>\n');
                                                                end
                                                            end
                                                            fprintf(fid,'</table><br><br>\n');

                                                            stats=LineStats(funcStruct);

                                                            if(~isempty(stats))
                                                                totalLineTime=sum([stats{:,2}]);
                                                                fprintf(fid,'%d%% of the total time in this function was spent on the following lines:<br><br>\n',...
                                                                floor(100*totalLineTime/max(funcStruct.TotalRecursiveTime,eps)));
                                                                fprintf(fid,'<table border=0> \n');
                                                                for k=1:size(stats,1)
                                                                    lineNum=stats{k,1};
                                                                    lineTime=stats{k,2};
                                                                    lineString=stats{k,3};

                                                                    if((k>1)&&(lineNum>(stats{k-1,1}+1)))
                                                                        fprintf(fid,'<tr> <td> &nbsp; </td> </tr> \n');
                                                                    end

                                                                    fprintf(fid,'<tr> \n');

                                                                    if(lineTime>0)
                                                                        fprintf(fid,'<td align=right> <code> %s </code> </td>\n',...
                                                                        FormatTime(lineTime,digits1));
                                                                        fprintf(fid,'<td align=right> <code> %d%% </code> </td>\n',...
                                                                        round(100*lineTime/...
                                                                        max(funcStruct.TotalRecursiveTime,eps)));
                                                                    else
                                                                        fprintf(fid,'<td> &nbsp; </td>\n');
                                                                        fprintf(fid,'<td> &nbsp; </td>\n');
                                                                    end

                                                                    fprintf(fid,'<td align=right> <code> %d:&nbsp; </code> </td>\n',...
                                                                    lineNum);


                                                                    lineString=strrep(lineString,char(9),'  ');
                                                                    lineString=strrep(lineString,' ','&nbsp;');
                                                                    lineString=strrep(lineString,'<','&lt;');
                                                                    lineString=strrep(lineString,'>','&gt;');
                                                                    fprintf(fid,'<td> <code> <nobr> %s </nobr> </code> </td> \n',...
                                                                    lineString);

                                                                    fprintf(fid,'</tr> \n');
                                                                end
                                                                fprintf(fid,'</table>\n');
                                                            end



                                                            function[counts,typenames]=CountFuncs(structArray)


                                                                typenames={structArray.Type};
                                                                typenames=unique(typenames);
                                                                numnames=length(typenames);
                                                                counts=zeros(numnames,1);

                                                                for k=1:length(structArray)
                                                                    idx=strcmp(structArray(k).Type,typenames);
                                                                    counts(idx)=counts(idx)+1;
                                                                end



                                                                function newArray=ComputeTimes(structArray)


                                                                    newArray=structArray;

                                                                    for k=1:length(newArray)
                                                                        childTime=0;
                                                                        for p=1:length(newArray(k).Children)
                                                                            childTime=childTime+newArray(k).Children(p).TotalTime;
                                                                        end
                                                                        newArray(k).TotalChildrenTime=childTime;
                                                                        newArray(k).SelfTime=newArray(k).TotalRecursiveTime-...
                                                                        childTime;
                                                                    end






                                                                    function stats=LineStats(funcStruct)





                                                                        if(isempty(funcStruct.ExecutedLines))
                                                                            stats=cell(0,3);
                                                                        else
                                                                            fid=fopen(funcStruct.FileName);
                                                                            if(fid<0)
                                                                                stats=cell(0,3);
                                                                            end

                                                                            if(fid>=0)
                                                                                inMat=textread(funcStruct.FileName,'%s','delimiter','\n',...
                                                                                'whitespace','','bufsize',65536);
                                                                                inMat{length(inMat)+1}='';
                                                                                fclose(fid);

                                                                                timePerLine(funcStruct.ExecutedLines(:,1))=funcStruct.ExecutedLines(:,3);
                                                                                timePerLine=timePerLine(:);
                                                                                totalTime=max(sum(timePerLine),eps);
                                                                                numInputLines=length(timePerLine);

                                                                                [bb,mfileIdx]=sort(timePerLine);
                                                                                bb=flipud(bb);
                                                                                mfileIdx=flipud(mfileIdx);




                                                                                numBusyLines=min(min(length(find((cumsum(bb)/max(totalTime,eps))>.95)),...
                                                                                10),numInputLines);
                                                                                bb=bb(1:numBusyLines);
                                                                                mfileIdx=mfileIdx(1:numBusyLines);




                                                                                if(~isempty(mfileIdx))

                                                                                    mfileIdx(bb==0)=[];
                                                                                    bb(bb==0)=[];

                                                                                    mfileLines=max(1,[mfileIdx-1;mfileIdx;mfileIdx+1]);


                                                                                    mfileLines((mfileLines<1)|(mfileLines>numInputLines))=[];

                                                                                    mfileLines=sort(mfileLines);
                                                                                    d=find(abs(diff(mfileLines))==0);
                                                                                    mfileLines(d)=[];
                                                                                else
                                                                                    mfileLines=[];
                                                                                end

                                                                                stats=cell(length(mfileLines),3);
                                                                                for m=1:length(mfileLines)
                                                                                    nextLine=inMat{mfileLines(m)};
                                                                                    k=find(mfileIdx==mfileLines(m));
                                                                                    if(isempty(k))
                                                                                        lineTime=0;
                                                                                    else
                                                                                        lineTime=bb(k);
                                                                                    end
                                                                                    stats{m,1}=mfileLines(m);
                                                                                    stats{m,2}=lineTime;
                                                                                    stats{m,3}=nextLine;
                                                                                end
                                                                            end
                                                                        end


