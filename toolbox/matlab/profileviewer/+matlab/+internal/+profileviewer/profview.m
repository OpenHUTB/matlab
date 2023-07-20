function htmlOut=profview(functionName,profInfo)






















    profileInfo=profInfo;

    if nargin<1

        functionName=0;
    end



    if ischar(functionName),
        functionNameList={profileInfo.FunctionTable.FunctionName};
        idx=find(strcmp(functionNameList,functionName)==1);
        if isempty(idx)
            error(message('MATLAB:profiler:FunctionNotFound',functionName))
        end
    else
        idx=functionName;
    end


    if idx==0
        s=makesummarypage(profileInfo);
    else
        busyLineSortKey=getpref('profiler','busyLineSortKey','time');
        s=makefilepage(profileInfo,idx,busyLineSortKeyStr2Num(busyLineSortKey));
    end

    sOut=[s{:}];

    if nargout==0
        setProfilerHtmlText(sOut);
    else
        htmlOut=sOut;
    end


    function s=makesummarypage(profileInfo)





        pixelPath=matlab.internal.profileviewer.getPathToPixelImage();
        cyanPixelGif=[pixelPath,'one-pixel-cyan.gif'];
        cyanPixelGif=matlab.internal.profileviewer.convertFileToBase64string(cyanPixelGif);
        bluePixelGif=[pixelPath,'one-pixel.gif'];
        bluePixelGif=matlab.internal.profileviewer.convertFileToBase64string(bluePixelGif);


        sortMode=getpref('profiler','sortMode','totaltime');

        allTimes=[profileInfo.FunctionTable.TotalTime];
        maxTime=max(allTimes);


        hasMem=hasMemoryData(profileInfo);


        allSelfTimes=zeros(size(allTimes));
        if hasMem
            allSelfMem=zeros(size(allTimes));
        end
        for i=1:length(profileInfo.FunctionTable)
            allSelfTimes(i)=profileInfo.FunctionTable(i).TotalTime-...
            sum([profileInfo.FunctionTable(i).Children.TotalTime]);
            if hasMem
                netMem=(profileInfo.FunctionTable(i).TotalMemAllocated-...
                profileInfo.FunctionTable(i).TotalMemFreed);
                childNetMem=(sum([profileInfo.FunctionTable(i).Children.TotalMemAllocated])-...
                sum([profileInfo.FunctionTable(i).Children.TotalMemFreed]));
                allSelfMem(i)=netMem-childNetMem;
            end
        end

        totalTimeFontWeight='normal';
        selfTimeFontWeight='normal';
        alphaFontWeight='normal';
        numCallsFontWeight='normal';
        allocMemFontWeight='normal';
        freeMemFontWeight='normal';
        peakMemFontWeight='normal';
        selfMemFontWeight='normal';



        if~hasMem&&(strcmp(sortMode,'allocmem')||...
            strcmp(sortMode,'freedmem')||...
            strcmp(sortMode,'peakmem')||...
            strcmp(sortMode,'selfmem'))
            sortMode='totaltime';
        end

        if strcmp(sortMode,'totaltime')
            totalTimeFontWeight='bold';
            [~,sortIndex]=sort(allTimes,'descend');
        elseif strcmp(sortMode,'selftime')
            selfTimeFontWeight='bold';
            [~,sortIndex]=sort(allSelfTimes,'descend');
        elseif strcmp(sortMode,'alpha')
            alphaFontWeight='bold';
            allFunctionNames={profileInfo.FunctionTable.FunctionName};
            [~,sortIndex]=sort(allFunctionNames);
        elseif strcmp(sortMode,'numcalls')
            numCallsFontWeight='bold';
            [~,sortIndex]=sort([profileInfo.FunctionTable.NumCalls],'descend');
        elseif strcmp(sortMode,'allocmem')
            allocMemFontWeight='bold';
            [~,sortIndex]=sort([profileInfo.FunctionTable.TotalMemAllocated],'descend');
        elseif strcmp(sortMode,'freedmem')
            freeMemFontWeight='bold';
            [~,sortIndex]=sort([profileInfo.FunctionTable.TotalMemFreed],'descend');
        elseif strcmp(sortMode,'peakmem')
            peakMemFontWeight='bold';
            [~,sortIndex]=sort([profileInfo.FunctionTable.PeakMem],'descend');
        elseif strcmp(sortMode,'selfmem')
            selfMemFontWeight='bold';
            [~,sortIndex]=sort(allSelfMem,'descend');
        else
            error(message('MATLAB:profiler:BadSortMode',sortMode));
        end

        s={};%#ok<*AGROW>

        s{end+1}=matlab.internal.profileviewer.makeprofilerheader();


        status=profile('status');
        s{end+1}=['<span style="font-size: 14pt; background: #FFE4B0">',getString(message('MATLAB:profiler:ProfileSummaryName')),'</span><br/>'];
        s{end+1}=['<i>',getString(message('MATLAB:profiler:GeneratedUsing',datestr(now),status.Timer)),'</i><br/>'];

        if isempty(profileInfo.FunctionTable)
            s{end+1}=['<p><span style="color:#F00">',getString(message('MATLAB:profiler:NoProfileInfo')),'</span><br/>'];
            s{end+1}=[getString(message('MATLAB:profiler:NoteAboutBuiltins')),'<p>'];
        end

        s{end+1}='<table border=0 cellspacing=0 cellpadding=6>';
        s{end+1}='<tr>';
        s{end+1}=generateTableElementLink('alpha',alphaFontWeight,'MATLAB:profiler:FunctionNameTableElement');
        s{end+1}='</td>';
        s{end+1}=generateTableElementLink('numcalls',numCallsFontWeight,'MATLAB:profiler:CallsTableElement');
        s{end+1}='</td>';
        s{end+1}=generateTableElementLink('totaltime',totalTimeFontWeight,'MATLAB:profiler:TotalTimeTableElement');
        s{end+1}='</td>';
        s{end+1}=generateTableElementLink('selftime',selfTimeFontWeight,'MATLAB:profiler:SelfTimeTableElement');
        s{end+1}='*</td>';


        if hasMem
            s{end+1}=generateTableElementLink('allocmem',allocMemFontWeight,'MATLAB:profiler:AllocatedMemoryTableElement');
            s{end+1}='</td>';

            s{end+1}=generateTableElementLink('freedmem',freeMemFontWeight,'MATLAB:profiler:FreedMemoryTableElement');
            s{end+1}='</td>';

            s{end+1}=generateTableElementLink('selfmem',selfMemFontWeight,'MATLAB:profiler:SelfMemoryTableElement');
            s{end+1}='</td>';

            s{end+1}=generateTableElementLink('peakmem',peakMemFontWeight,'MATLAB:profiler:PeakMemoryTableElement');
            s{end+1}='</td>';

        end

        s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0" valign="top">',getString(message('MATLAB:profiler:TotalTimePlotTableElement')),'<br/>'];
        s{end+1}=[getString(message('MATLAB:profiler:DarkBandSelfTime')),'</td>'];
        s{end+1}='</tr>';

        for i=1:length(profileInfo.FunctionTable),
            n=sortIndex(i);

            name=profileInfo.FunctionTable(n).FunctionName;

            s{end+1}='<tr>';


            displayFunctionName=truncateDisplayName(name,40);
            s{end+1}='<td class="td-linebottomrt">';
            s{end+1}=matlab.internal.profileviewer.printfProfilerLink('profview(%d);','%s',n,displayFunctionName);

            if isempty(regexp(profileInfo.FunctionTable(n).Type,'^M-','once'))
                s{end+1}=sprintf(' (%s)</td>',...
                typeToDisplayValue(profileInfo.FunctionTable(n).Type));
            else
                s{end+1}='</td>';
            end

            s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',...
            profileInfo.FunctionTable(n).NumCalls);



            if profileInfo.FunctionTable(n).TotalTime>0,
                s{end+1}=sprintf('<td class="td-linebottomrt">%4.3f s</td>',...
                profileInfo.FunctionTable(n).TotalTime);
            else
                s{end+1}='<td class="td-linebottomrt">0 s</td>';
            end

            if maxTime>0,
                timeRatio=profileInfo.FunctionTable(n).TotalTime/maxTime;
                selfTime=profileInfo.FunctionTable(n).TotalTime-sum([profileInfo.FunctionTable(n).Children.TotalTime]);
                selfTimeRatio=selfTime/maxTime;
            else
                timeRatio=0;
                selfTime=0;
                selfTimeRatio=0;
            end

            s{end+1}=sprintf('<td class="td-linebottomrt">%4.3f s</td>',selfTime);


            if hasMem

                totalAlloc=profileInfo.FunctionTable(n).TotalMemAllocated;
                totalFreed=profileInfo.FunctionTable(n).TotalMemFreed;
                netMem=totalAlloc-totalFreed;
                childAlloc=sum([profileInfo.FunctionTable(n).Children.TotalMemAllocated]);
                childFreed=sum([profileInfo.FunctionTable(n).Children.TotalMemFreed]);
                childMem=childAlloc-childFreed;
                selfMem=netMem-childMem;
                peakMem=profileInfo.FunctionTable(n).PeakMem;
                s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalAlloc));
                s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalFreed));
                s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,selfMem));
                s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,peakMem));
            end

            s{end+1}=sprintf('<td class="td-linebottomrt"><img src="data:image/gif;base64, %s" width=%d height=10><img src="data:image/gif;base64, %s" width=%d height=10></td>',...
            bluePixelGif,round(100*selfTimeRatio),...
            cyanPixelGif,round(100*(timeRatio-selfTimeRatio)));

            s{end+1}='</tr>';
        end
        s{end+1}='</table>';

        if profileInfo.Overhead==0
            s{end+1}=sprintf(['<p><a name="selftimedef"></a>',getString(message('MATLAB:profiler:SelfTime1st')),' ']);
        else
            s{end+1}=sprintf(['<p><a name="selftimedef"></a>',getString(message('MATLAB:profiler:SelfTime2nd',profileInfo.Overhead))]);
        end

        s{end+1}=matlab.internal.profileviewer.makeprofilerfooter;






        function s=makefilepage(profileInfo,idx,key_data_field)











            ftItem=profileInfo.FunctionTable(idx);
            hasMem=hasMemoryData(ftItem);













            if~hasMem

                key_data_field=1;
                field_order=1;
                key_unit='time';
                key_unit_up=getString(message('MATLAB:profiler:Time1'));
            else
                num_fields=1;
                if hasMem
                    num_fields=num_fields+3;
                end
                field_order=1:num_fields;
                if key_data_field==1
                    key_unit='time';
                    key_unit_up=getString(message('MATLAB:profiler:Time1'));
                elseif hasMem&&key_data_field<=4


                    switch(key_data_field)
                    case 2
                        field_order(1:4)=[2,3,4,1];
                        key_unit='allocated memory';
                        key_unit_up=getString(message('MATLAB:profiler:AllocatedMemoryTableElement'));
                    case 3
                        field_order(1:4)=[3,4,2,1];
                        key_unit='freed memory';
                        key_unit_up=getString(message('MATLAB:profiler:FreedMemoryTableElement'));
                    case 4
                        field_order(1:4)=[4,2,3,1];
                        key_unit='peak memory';
                        key_unit_up=getString(message('MATLAB:profiler:PeakMemoryTableElement'));
                    end
                else
                    error(message('MATLAB:profiler:BadSortKey',key_data_field));
                end
            end

            pixelPath=matlab.internal.profileviewer.getPathToPixelImage();
            bluePixelGif=[pixelPath,'one-pixel.gif'];
            bluePixelGif=matlab.internal.profileviewer.convertFileToBase64string(bluePixelGif);




            totalData(1)=ftItem.TotalTime;
            if hasMem
                totalData(2)=ftItem.TotalMemAllocated;
                totalData(3)=ftItem.TotalMemFreed;
                totalData(4)=ftItem.PeakMem;
            end


            targetHash=[];
            for n=1:length(ftItem.Children)
                targetName=profileInfo.FunctionTable(ftItem.Children(n).Index).FunctionName;

                if~any(targetName=='.')&&~any(targetName=='@')


                    targetName=regexprep(targetName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
                    if~isempty(targetName)&&targetName(1)~='_'
                        targetHash.(targetName)=ftItem.Children(n).Index;
                    end
                end
            end


            mFileFlag=1;
            pFileFlag=0;
            filteredFileFlag=false;
            if(isempty(regexp(ftItem.Type,'^(M-|Coder|generated)','once'))||...
                strcmp(ftItem.Type,'M-anonymous-function')||...
                isempty(ftItem.FileName))
                mFileFlag=0;
            else

                if~isempty(regexp(ftItem.FileName,'\.p$','once'))
                    pFileFlag=1;
                    pFullName=ftItem.FileName;


                    fullName=regexprep(ftItem.FileName,'\.p$','.m');



                    mTimeDir=dir(fullName);
                    pTimeDir=dir(pFullName);



                    if isempty(mTimeDir)||mTimeDir.datenum>pTimeDir.datenum
                        mFileFlag=0;
                    end
                else
                    fullName=ftItem.FileName;
                end

                if~exist(fullName,'file')
                    mFileFlag=0;
                end
            end

            badListingDisplayMode=false;
            if mFileFlag
                f=getmcode(fullName);

                if isempty(ftItem.ExecutedLines)&&ftItem.NumCalls>0




                    f=[];
                    filteredFileFlag=true;
                elseif length(f)<ftItem.ExecutedLines(end,1)




                    badListingDisplayMode=true;
                end
            elseif~pFileFlag






                badListingDisplayMode=true;
            end

            s={};
            s{1}=matlab.internal.profileviewer.makeprofilerheader();
            s{end+1}=['<title>',getString(message('MATLAB:profiler:FunctionDetailsFor',escapeHtml(ftItem.FunctionName))),'</title>'];
            cssfile=which('matlab-report-styles.css');
            s{end+1}=sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
            s{end+1}='</head>';
            s{end+1}='<body>';


            displayName=escapeHtml(ftItem.FunctionName);
            s{end+1}=sprintf('<span style="font-size:14pt; background:#FFE4B0">%s',...
            displayName);

            callStr=getString(message('MATLAB:profiler:CallsTimeTitle',...
            sprintf('%d',ftItem.NumCalls),...
            sprintf('%4.3f s',totalData(1))));
            status=profile('status');


            str=sprintf(' (%s',callStr);

            if hasMem
                str=[str,sprintf(', %s, %s, %s',formatData(2,totalData(2)),...
                formatData(2,totalData(3)),...
                formatData(2,totalData(4)))];
            end

            str=[str,')</span><br/>'];
            s{end+1}=str;
            s{end+1}=['<i>',getString(message('MATLAB:profiler:GeneratedUsing',datestr(now),status.Timer)),'</i><br/>'];

            if mFileFlag
                s{end+1}=[getString(message('MATLAB:profiler:InFile',typeToDisplayValue(ftItem.Type))),' ',matlab.internal.profileviewer.printfProfilerLink('edit(urldecode(''%s''))','%s',urlencode(fullName),fullName)];
                s{end+1}='<br/>';
            elseif isequal(ftItem.Type,'M-subfunction')
                s{end+1}=[getString(message('MATLAB:profiler:AnonymousFunction')),'<br/>'];
            else
                s{end+1}=[getString(message('MATLAB:profiler:InFile1',typeToDisplayValue(ftItem.Type),ftItem.FileName)),'<br/>'];
            end

            s{end+1}=matlab.internal.profileviewer.printfProfilerLink('stripanchors',getString(message('MATLAB:profiler:CopyToNewWindow')));

            if pFileFlag&&~mFileFlag
                s{end+1}=['<p><span class="warning">',getString(message('MATLAB:profiler:PFileWithNoMATLABCode')),'</span></p>'];
            end

            didChange=callstats('has_changed',ftItem.CompleteName);
            if didChange
                s{end+1}=['<p><span class="warning">',getString(message('MATLAB:profiler:FileChangedDuringProfiling1')),'</span></p>'];
            end

            s{end+1}='<div class="grayline"/>';





            profilerSettings=settings;
            parentDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowParentFunctions.ActiveValue;
            busylineDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowBusyLines.ActiveValue;
            childrenDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowChildFunctions.ActiveValue;
            mlintDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowCodeAnalyzerResults.ActiveValue;
            coverageDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowFileCoverage.ActiveValue;
            listingDisplayMode=profilerSettings.matlab.profiler.showfeature.ShowFunctionListing.ActiveValue;


            oldListingDisplayMode=listingDisplayMode;
            if badListingDisplayMode
                listingDisplayMode=false;
            end

            s{end+1}='<form method="GET" action="matlab:matlab.internal.profileviewer.profviewgateway">';
            s{end+1}=matlab.internal.profileviewer.printProfilerRefreshButton();
            s{end+1}=sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);

            s{end+1}='<table>';
            s{end+1}='<tr><td>';


            checkOptions={'','checked'};

            s{end+1}=sprintf('<input type="checkbox" name="parentDisplayMode" %s />',...
            checkOptions{parentDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowParentFunctions')),'</td><td>'];

            s{end+1}=sprintf('<input type="checkbox" name="busylineDisplayMode" %s />',...
            checkOptions{busylineDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowBusyLines')),'</td><td>'];

            s{end+1}=sprintf('<input type="checkbox" name="childrenDisplayMode" %s />',...
            checkOptions{childrenDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowChildFunctions')),'</td></tr><tr><td>'];

            s{end+1}=sprintf('<input type="checkbox" name="mlintDisplayMode" %s />',...
            checkOptions{mlintDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowCodeAnalyzerResults')),'</td><td>'];

            s{end+1}=sprintf('<input type="checkbox" name="coverageDisplayMode" %s />',...
            checkOptions{coverageDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowFileCoverage')),'</td><td>'];

            s{end+1}=sprintf('<input type="checkbox" name="listingDisplayMode" %s />',...
            checkOptions{listingDisplayMode+1});
            s{end+1}=[getString(message('MATLAB:profiler:ShowFunctionListing')),'</td>'];

            s{end+1}='</tr></table>';

            s{end+1}='</form>';

            if hasMem





                s{end+1}='<form method="GET" action="matlab:matlab.internal.profileviewer.profviewgateway">';
                s{end+1}=[getString(message('MATLAB:profiler:SortBusyLines')),' '];
                s{end+1}=sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
                s{end+1}='<select name="busyLineSortKey" onChange="this.form.submit()">';
                optionsList={};
                optionsList{end+1}='time';
                if hasMem
                    optionsList{end+1}='allocated memory';
                    optionsList{end+1}='freed memory';
                    optionsList{end+1}='peak memory';
                end
                for n=1:length(optionsList)
                    if strcmp(busyLineSortKeyNum2Str(key_data_field),optionsList{n})
                        selectStr='selected';
                    else
                        selectStr='';
                    end
                    s{end+1}=sprintf('<option %s>%s</option>',selectStr,optionsList{n});
                end
                s{end+1}='</select>';
                s{end+1}='</form>';
            end

            s{end+1}='<div class="grayline"/>';






            if parentDisplayMode
                parents=ftItem.Parents;

                s{end+1}=[getString(message('MATLAB:profiler:Parents')),'<br/>'];
                if isempty(parents)
                    s{end+1}=[' ',getString(message('MATLAB:profiler:NoParent')),' '];
                else
                    s{end+1}='<p><table border=0 cellspacing=0 cellpadding=6>';
                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:FunctionNameTableElement')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:FunctionType')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CallsTableElement')),'</td>'];
                    s{end+1}='</tr>';

                    for n=1:length(parents),
                        s{end+1}='<tr>';

                        displayName=truncateDisplayName(profileInfo.FunctionTable(parents(n).Index).FunctionName,40);
                        s{end+1}='<td class="td-linebottomrt">';
                        s{end+1}=matlab.internal.profileviewer.printfProfilerLink('profview(%d);','%s',parents(n).Index,displayName);
                        s{end+1}='</td>';

                        s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',...
                        typeToDisplayValue(profileInfo.FunctionTable(parents(n).Index).Type));

                        s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',...
                        parents(n).NumCalls);

                        s{end+1}='</tr>';
                    end
                    s{end+1}='</table>';
                end
                s{end+1}='<div class="grayline"/>';
            end










            ln_index=key_data_field+2;


            [sortedDataList(:,key_data_field),sortedDataIndex]=sort(ftItem.ExecutedLines(:,ln_index));
            sortedDataList=flipud(sortedDataList);

            maxDataLineList=flipud(ftItem.ExecutedLines(sortedDataIndex,1));
            maxDataLineList=maxDataLineList(1:min(5,length(maxDataLineList)));
            maxNumCalls=max(ftItem.ExecutedLines(:,2));
            dataSortedNumCallsList=flipud(ftItem.ExecutedLines(sortedDataIndex,2));



            for i=1:length(field_order)
                fi=field_order(i);
                if fi==key_data_field,continue;end
                sortedDataList(:,fi)=flipud(ftItem.ExecutedLines(sortedDataIndex,fi+2));
            end





            fmt=ones(1,length(field_order));


            data_fields={getString(message('MATLAB:profiler:TotalTimeTableElement'))};


            if hasMem
                fmt(2:4)=2;
                data_fields=[data_fields,getString(message('MATLAB:profiler:AllocatedMemoryTableElement')),getString(message('MATLAB:profiler:FreedMemoryTableElement')),getString(message('MATLAB:profiler:PeakMemoryTableElement'))];
            end

            if busylineDisplayMode
                s{end+1}=['<strong>',getString(message('MATLAB:profiler:LinesSpent',lower(key_unit_up))),'</strong><br/> '];

                if~mFileFlag||filteredFileFlag
                    s{end+1}=getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
                else
                    if totalData(key_data_field)==0
                        s{end+1}=getString(message('MATLAB:profiler:NoMeasurableSpentInThisFunction',lower(key_unit_up)));
                    end

                    s{end+1}='<p><table border=0 cellspacing=0 cellpadding=6>';

                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:LineNumber')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:Code')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CallsTableElement')),'</td>'];


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',data_fields{fidx},'</td>'];
                    end


                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">% ',key_unit_up,'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',key_unit_up,' ',getString(message('MATLAB:profiler:Plot')),'</td>'];
                    s{end+1}='</tr>';

                    for n=1:length(maxDataLineList),
                        s{end+1}='<tr>';
                        if listingDisplayMode
                            s{end+1}=sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>',...
                            maxDataLineList(n),maxDataLineList(n));
                        else
                            s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',...
                            maxDataLineList(n));
                        end

                        if maxDataLineList(n)>length(f)
                            codeLine='';
                        else
                            codeLine=f{maxDataLineList(n)};
                        end


                        codeLine(cumsum(1-isspace(codeLine))==0)=[];

                        codeLine=code2html(codeLine);

                        maxLineLen=30;
                        if length(codeLine)>maxLineLen
                            s{end+1}=sprintf('<td class="td-linebottomrt"><pre>%s...</pre></td>',codeLine(1:maxLineLen));
                        else
                            s{end+1}=sprintf('<td class="td-linebottomrt"><pre>%s</pre></td>',codeLine);
                        end

                        s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',dataSortedNumCallsList(n));


                        for fi=1:length(field_order)
                            fidx=field_order(fi);
                            t=sortedDataList(n,fidx);
                            s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx),t));
                        end


                        s{end+1}=sprintf('<td class="td-linebottomrt" class="td-linebottomrt">%s</td>',...
                        formatNicePercent(sortedDataList(n,key_data_field),totalData(key_data_field)));

                        if totalData(key_data_field)>0
                            dataRatio=sortedDataList(n,key_data_field)/totalData(key_data_field);
                        else
                            dataRatio=0;
                        end


                        s{end+1}=sprintf('<td class="td-linebottomrt"><img src="data:image/gif;base64, %s" width=%d height=10></td>',...
                        bluePixelGif,round(100*dataRatio));
                        s{end+1}='</tr>';

                    end


                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt">',getString(message('MATLAB:profiler:AllOtherLines')),'</td>'];
                    s{end+1}='<td class="td-linebottomrt">&nbsp;</td>';
                    s{end+1}='<td class="td-linebottomrt">&nbsp;</td>';


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        if~hasMem||fidx~=4

                            allOtherLineData(fidx)=totalData(fidx)-sum(sortedDataList(1:length(maxDataLineList),fidx));
                        else

                            allOtherLineData(fidx)=max(sortedDataList(1:length(maxDataLineList),fidx));
                        end
                        s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx),allOtherLineData(fidx)));
                    end


                    s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(allOtherLineData(key_data_field),totalData(key_data_field)));

                    if totalData(key_data_field)>0,
                        dataRatio=allOtherLineData(key_data_field)/totalData(key_data_field);
                    else
                        dataRatio=0;
                    end


                    s{end+1}=sprintf('<td class="td-linebottomrt"><img src="data:image/gif;base64, %s" width=%d height=10></td>',...
                    bluePixelGif,round(100*dataRatio));
                    s{end+1}='</tr>';


                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:Totals')),'</td>'];
                    s{end+1}='<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';
                    s{end+1}='<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        s{end+1}=sprintf('<td class="td-linebottomrt" style="background-color:#F0F0F0">%s</td>',formatData(fmt(fidx),totalData(fidx)));
                    end
                    if totalData(key_data_field)>0,
                        s{end+1}='<td class="td-linebottomrt" style="background-color:#F0F0F0">100%</td>';
                    else
                        s{end+1}='<td class="td-linebottomrt" style="background-color:#F0F0F0">0%</td>';
                    end


                    s{end+1}='<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';

                    s{end+1}='</tr>';

                    s{end+1}='</table>';
                end
                s{end+1}='<div class="grayline"/>';

            end








            if childrenDisplayMode


                children=ftItem.Children;
                s{end+1}=[getString(message('MATLAB:profiler:Children')),'<br/>'];

                if isempty(children)
                    s{end+1}=getString(message('MATLAB:profiler:NoChildren'));
                else

                    childrenData(:,1)=[ftItem.Children.TotalTime];
                    if hasMem
                        childrenData(:,2)=[ftItem.Children.TotalMemAllocated];
                        childrenData(:,3)=[ftItem.Children.TotalMemFreed];
                        childrenData(:,4)=[ftItem.Children.PeakMem];
                    end
                    [~,dataSortIndex]=sort(childrenData(:,key_data_field));

                    s{end+1}='<p><table border=0 cellspacing=0 cellpadding=6>';
                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:FunctionNameTableElement')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:FunctionType')),'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:CallsTableElement')),'</td>'];


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',data_fields{fidx},'</td>'];
                    end


                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">% ',key_unit_up,'</td>'];
                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',key_unit_up,' ',getString(message('MATLAB:profiler:Plot')),'</td>'];
                    s{end+1}='</tr>';

                    for i=length(children):-1:1,
                        n=dataSortIndex(i);
                        s{end+1}='<tr>';


                        displayFunctionName=truncateDisplayName(profileInfo.FunctionTable(children(n).Index).FunctionName,40);

                        s{end+1}='<td class="td-linebottomrt">';
                        s{end+1}=matlab.internal.profileviewer.printfProfilerLink('profview(%d);','%s',children(n).Index,displayFunctionName);
                        s{end+1}='</td>';

                        s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',...
                        typeToDisplayValue(profileInfo.FunctionTable(children(n).Index).Type));

                        s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',...
                        children(n).NumCalls);


                        for fi=1:length(field_order)
                            fidx=field_order(fi);
                            t=childrenData(n,fidx);
                            s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx),t));
                        end


                        s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',...
                        formatNicePercent(childrenData(n,key_data_field),totalData(key_data_field)));

                        if totalData(key_data_field)>0,
                            dataRatio=childrenData(n,key_data_field)/totalData(key_data_field);
                        else
                            dataRatio=0;
                        end


                        s{end+1}=sprintf('<td class="td-linebottomrt"><img src="data:image/gif;base64, %s" width=%d height=10></td>',...
                        bluePixelGif,round(100*dataRatio));
                        s{end+1}='</tr>';
                    end


                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt">',getString(message('MATLAB:profiler:SelfBuiltIns',lower(key_unit_up))),'</td>'];
                    s{end+1}='<td class="td-linebottomrt">&nbsp;</td>';
                    s{end+1}='<td class="td-linebottomrt">&nbsp;</td>';


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        if fidx~=4

                            selfData(fidx)=totalData(fidx)-sum(childrenData(:,fidx));
                        else

                            selfData(fidx)=totalData(fidx);
                        end
                        s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx),selfData(fidx)));
                    end


                    s{end+1}=sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(selfData(key_data_field),totalData(key_data_field)));

                    if totalData(key_data_field)>0,
                        dataRatio=selfData(key_data_field)/totalData(key_data_field);
                    else
                        dataRatio=0;
                    end


                    s{end+1}=sprintf('<td class="td-linebottomrt"><img src="data:image/gif;base64, %s" width=%d height=10></td>',...
                    bluePixelGif,round(100*dataRatio));
                    s{end+1}='</tr>';


                    s{end+1}='<tr>';
                    s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:Totals')),'</td>'];
                    s{end+1}='<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
                    s{end+1}='<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';


                    for fi=1:length(field_order)
                        fidx=field_order(fi);
                        s{end+1}=sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%s</td>',formatData(fmt(fidx),totalData(fidx)));
                    end


                    if totalData(key_data_field)>0,
                        s{end+1}='<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
                    else
                        s{end+1}='<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
                    end


                    s{end+1}='<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';

                    s{end+1}='</tr>';

                    s{end+1}='</table>';
                end

                s{end+1}='<div class="grayline"/>';
            end





            if mFileFlag&&~filteredFileFlag





                ftok=xmtok(f);
                try
                    runnableLineIndex=callstats('file_lines',ftItem.FileName);
                catch e
                    warning(message('MATLAB:profiler:NoCoverageInfo',ftItem.FileName,e.message));
                    runnableLineIndex=[];
                end
                runnableLines=zeros(size(f));
                runnableLines(runnableLineIndex)=runnableLineIndex;




                if length(runnableLines)>length(f)
                    runnableLines=runnableLines(1:length(f));
                end























                fNameMatches=regexp(ftItem.FunctionName,'((set|get)\.)?(\w+)$','tokens','once');
                fname=fNameMatches{2};

                strc=getcallinfo(fullName,'-v7.8');
                fcnList={strc.name};
                fcnIdx=find(strcmp(fcnList,fname)==1);




                if isempty(fcnIdx)&&~isempty(fNameMatches{1})



                    possibleFullName=[fNameMatches{1},fNameMatches{2}];
                    fcnIdx=find(strcmp(fcnList,possibleFullName)==1);




                    if~isempty(fcnIdx)
                        fname=possibleFullName;
                    end
                end

                if length(fcnIdx)>1



                    fcnIdx=fcnIdx(1);
                    warning(message('MATLAB:profiler:FunctionAppearsMoreThanOnce',fname));
                end

                if isempty(fcnIdx)




                    startLine=1;
                    endLine=length(f);
                    lineMask=ones(length(f),1);
                else
                    startLine=strc(fcnIdx).firstline;
                    endLine=strc(fcnIdx).lastline;
                    lineMask=strc(fcnIdx).linemask;
                end

                runnableLines=runnableLines.*lineMask;

                moreSubfunctionsInFileFlag=0;
                if endLine<length(f)
                    moreSubfunctionsInFileFlag=1;
                end



                hiliteOption='time';
                profilerSettings=settings;
                if profilerSettings.matlab.profiler.functionlisting.HighlightMode.hasPersonalValue
                    hiliteOption=profilerSettings.matlab.profiler.functionlisting.HighlightMode.PersonalValue;
                end




                if~hasMem&&(strcmp(hiliteOption,'allocated memory')||...
                    strcmp(hiliteOption,'freed memory')||...
                    strcmp(hiliteOption,'peak memory'))
                    hiliteOption=key_unit;
                end

                mlintstrc=struct('line',{},'message',{});
                if strcmp(hiliteOption,'code analyzer')||mlintDisplayMode
                    try
                        mlintstrc=checkcode(fullName,'-struct');
                    catch


                    end




                    sortFlag=false;
                    for i=1:length(mlintstrc)
                        if length(mlintstrc(i).line)>1
                            mlintLineList=mlintstrc(i).line;



                            sortFlag=true;
                            mlintstrc(i).line=mlintLineList(1);
                            for j=2:length(mlintLineList)
                                mlintstrc(end+1)=mlintstrc(i);
                                mlintstrc(end).line=mlintLineList(j);
                            end
                        end
                    end



                    if sortFlag

                        mlintLines=[mlintstrc.line];
                        [~,sortIndex]=sort(mlintLines);
                        mlintstrc=mlintstrc(sortIndex);
                    end

                end
            end




            if mlintDisplayMode
                s{end+1}=['<strong>',getString(message('MATLAB:profiler:CodeAnalyzerResults')),'</strong><br/>'];

                if~mFileFlag||filteredFileFlag
                    s{end+1}=getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
                else
                    if isempty(mlintstrc)
                        s{end+1}=getString(message('MATLAB:profiler:NoCodeAnalyzerMessages'));
                    else

                        mlintLines=[mlintstrc.line];
                        mlintstrc([find(mlintLines<startLine),find(mlintLines>endLine)])=[];
                        s{end+1}='<table border=0 cellspacing=0 cellpadding=6>';
                        s{end+1}='<tr>';
                        s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:LineNumberSoft')),'</td>'];
                        s{end+1}=['<td class="td-linebottomrt" bgcolor="#F0F0F0">',getString(message('MATLAB:profiler:Message')),'</td>'];
                        s{end+1}='</tr>';

                        for n=1:length(mlintstrc)
                            if(mlintstrc(n).line<=endLine)&&(mlintstrc(n).line>=startLine)
                                s{end+1}='<tr>';
                                if listingDisplayMode
                                    s{end+1}=sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>',mlintstrc(n).line,mlintstrc(n).line);
                                else
                                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td>',mlintstrc(n).line);
                                end
                                s{end+1}=sprintf('<td class="td-linebottomrt"><span class="mono">%s</span></td>',mlintstrc(n).message);
                                s{end+1}='</tr>';
                            end
                        end
                        s{end+1}='</table>';
                    end
                end
                s{end+1}='<div class="grayline"/>';
            end








            if coverageDisplayMode
                s{end+1}=['<strong>',getString(message('MATLAB:profiler:CoverageResults')),'</strong><br/>'];

                if~mFileFlag||filteredFileFlag
                    s{end+1}=getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
                else
                    s{end+1}=matlab.internal.profileviewer.printfProfilerLink('coveragerpt(fileparts(urldecode(''%s'')))',getString(message('MATLAB:profiler:ShowCoverageForParentDir')),urlencode(fullName));
                    s{end+1}='<br/>';

                    linelist=(1:length(f))';
                    canRunList=find(linelist(startLine:endLine)==runnableLines(startLine:endLine))+startLine-1;
                    didRunList=ftItem.ExecutedLines(:,1);
                    notRunList=setdiff(canRunList,didRunList);
                    neverRunList=find(runnableLines(startLine:endLine)==0);

                    s{end+1}='<table border=0 cellspacing=0 cellpadding=6>';
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:TotalLinesInFunction')),'</td>'];
                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td></tr>',endLine-startLine+1);
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:NoncodeLines')),'</td>'];
                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td></tr>',length(neverRunList));
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CodeLines')),'</td>'];
                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td></tr>',length(canRunList));
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CodeLinesThatDidRun')),'</td>'];
                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td></tr>',length(didRunList));
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CodeLinesThatDidNotRun')),'</td>'];
                    s{end+1}=sprintf('<td class="td-linebottomrt">%d</td></tr>',length(notRunList));
                    s{end+1}=['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">',getString(message('MATLAB:profiler:CoverageDidCanRun')),'</td>'];
                    if~isempty(canRunList)
                        s{end+1}=sprintf('<td class="td-linebottomrt">%4.2f %%</td></tr>',100*length(didRunList)/length(canRunList));
                    else
                        s{end+1}=sprintf('<td class="td-linebottomrt">N/A</td></tr>');
                    end
                    s{end+1}='</table>';

                end
                s{end+1}='<div class="grayline"/>';
            end












            if oldListingDisplayMode&&badListingDisplayMode
                s{end+1}=['<p><span class="warning">',getString(message('MATLAB:profiler:FileModifiedDuringProfiling')),'</span></p>'];
            end

            if listingDisplayMode
                s{end+1}=['<b>',getString(message('MATLAB:profiler:FunctionListing')),'</b><br/>'];

                if~mFileFlag||filteredFileFlag
                    s{end+1}=getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
                else

                    executedLines=zeros(length(f),1);
                    executedLines(ftItem.ExecutedLines(:,1))=1:size(ftItem.ExecutedLines,1);


                    alphanumericList=['a':'z','A':'Z','0':'9','_'];
                    alphanumericArray=zeros(1,128);
                    alphanumericArray(alphanumericList)=1;



                    ftItem=adjustExecutionTimeForLineContinuations(startLine,endLine,ftItem,executedLines,ftok);

                    [bgColorCode,bgColorTable,textColorCode,textColorTable]=makeColorTables(...
                    f,hiliteOption,ftItem,ftok,startLine,endLine,executedLines,runnableLines,...
                    mlintstrc,maxNumCalls);
                    s{end+1}='<form method="GET" action="matlab:matlab.internal.profileviewer.profviewgateway">';
                    s{end+1}=[getString(message('MATLAB:profiler:ColorHighlightCodeAccordingTo')),' '];
                    s{end+1}=sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
                    s{end+1}=generateProfilerSelect();
                    optionsList={};
                    shownString={};



                    optionsList{end+1}='time';
                    shownString{end+1}=getString(message('MATLAB:profiler:Time'));
                    optionsList{end+1}='numcalls';
                    shownString{end+1}=getString(message('MATLAB:profiler:Numcalls'));
                    optionsList{end+1}='coverage';
                    shownString{end+1}=getString(message('MATLAB:profiler:Coverage'));
                    optionsList{end+1}='noncoverage';
                    shownString{end+1}=getString(message('MATLAB:profiler:Noncoverage'));
                    optionsList{end+1}='code analyzer';
                    shownString{end+1}=getString(message('MATLAB:profiler:CodeAnalyzer'));
                    if hasMem

                        optionsList{end+1}='allocated memory';
                        shownString{end+1}=getString(message('MATLAB:profiler:AllocatedMemory'));
                        optionsList{end+1}='freed memory';
                        shownString{end+1}=getString(message('MATLAB:profiler:FreedMemory'));
                        optionsList{end+1}='peak memory';
                        shownString{end+1}=getString(message('MATLAB:profiler:PeakMemory'));
                    end
                    optionsList{end+1}='none';
                    shownString{end+1}=getString(message('MATLAB:profiler:None'));
                    for n=1:length(optionsList)
                        if strcmp(hiliteOption,optionsList{n})
                            selectStr='selected';
                        else
                            selectStr='';
                        end
                        s{end+1}=sprintf('<option %s value="%s">%s</option>',selectStr,optionsList{n},shownString{n});
                    end
                    s{end+1}='</select>';
                    s{end+1}='</form>';




                    s{end+1}='<table id="FunctionListingTable">';

                    s{end+1}='<tr style="height:20px;">';
                    s{end+1}='<th>';
                    s{end+1}='<pre>';
                    s{end+1}=['<span style="color:#FF0000;">',getString(message('MATLAB:profiler:Time')),'</span> '];
                    s{end+1}='</pre>';
                    s{end+1}='</th>';
                    s{end+1}='<th>';
                    s{end+1}='<pre>';
                    s{end+1}=['<span style="color:#0000FF;">',getString(message('MATLAB:profiler:CallsTableElement')),'</span> '];
                    s{end+1}='</pre>';
                    s{end+1}='</th>';

                    if hasMem
                        s{end+1}='<th>';
                        s{end+1}='<pre>';
                        s{end+1}='<span style="color:#20AF20;">mem</span> ';
                        s{end+1}='</pre>';
                        s{end+1}='</th>';
                    end

                    s{end+1}='<th class="leftAligned" COLSPAN=2>';
                    s{end+1}='<pre>';
                    s{end+1}=['<span> ',getString(message('MATLAB:profiler:Line')),'</span>'];
                    s{end+1}='</pre>';
                    s{end+1}='</th>';




                    if strcmp(hiliteOption,'code analyzer')&&length(mlintstrc)>0
                        s{end+1}='<th>';
                        s{end+1}='<pre>';
                        s{end+1}=['<span style="color:#000;">',getString(message('MATLAB:profiler:CodeAnalyzerMessage')),'</span>'];
                        s{end+1}='</pre>';
                        s{end+1}='</th>';
                    end

                    s{end+1}='</tr>';


                    for n=startLine:endLine

                        s{end+1}='<tr>';

                        lineIdx=executedLines(n);
                        if lineIdx>0,
                            callsPerLine=ftItem.ExecutedLines(lineIdx,2);
                            timePerLine=ftItem.ExecutedLines(lineIdx,3);
                            if hasMem
                                memAlloc=ftItem.ExecutedLines(lineIdx,4);
                                memFreed=ftItem.ExecutedLines(lineIdx,5);
                                peakMem=ftItem.ExecutedLines(lineIdx,6);
                            end
                        else
                            timePerLine=0;
                            callsPerLine=0;
                            memAlloc=0;
                            memFreed=0;
                            peakMem=0;
                        end


                        color=bgColorTable{bgColorCode(n)};
                        textColor=textColorTable{textColorCode(n)};

                        if mlintDisplayMode
                            if any([mlintstrc.line]==n)
                                s{end+1}=sprintf('<a name="Line%d"></a>',n);
                            end
                        end


                        if n>length(f)
                            codeLine='';
                        else
                            codeLine=code2html(f{n});
                        end


                        s{end+1}='<td>';
                        s{end+1}='<pre>';
                        if timePerLine>0.001
                            s{end+1}=sprintf('<span style="color: #FF0000"> %6.3f </span>',...
                            timePerLine);
                        elseif timePerLine>0
                            s{end+1}='<span style="color: #FF0000">&lt; 0.001 </span>';
                        end
                        s{end+1}='</pre>';
                        s{end+1}='</td>';


                        s{end+1}='<td>';
                        s{end+1}='<pre>';
                        if callsPerLine>0,
                            s{end+1}=sprintf('<span style="color: #0000FF">%7d </span>',...
                            callsPerLine);
                        end
                        s{end+1}='</pre>';
                        s{end+1}='</td>';


                        if hasMem
                            s{end+1}='<td>';
                            s{end+1}='<pre>';
                            if memAlloc>0||memFreed>0||peakMem>0

                                str=sprintf('%s/%s/%s',...
                                toKb(memAlloc,'%0.3g',true),...
                                toKb(memFreed,'%0.3g',true),...
                                toKb(peakMem,'%0.3g',true));

                                str=sprintf('<span style="color: #20AF20">%19s </span>',str);
                            end
                            s{end+1}=str;
                            s{end+1}='</pre>';
                            s{end+1}='</td>';
                        end


                        s{end+1}='<td>';
                        s{end+1}='<pre>';
                        if callsPerLine>0
                            s{end+1}='<span style="color: #000000; font-weight: bold; margin:0; ">';
                            s{end+1}=matlab.internal.profileviewer.printfProfilerLink('opentoline(urldecode(''%s''),%d)','%4d',urlencode(fullName),n,n);
                            s{end+1}='</span>';
                        else
                            s{end+1}=sprintf('<span style="color: #A0A0A0; margin:0;">%4d</span> ',n);
                        end

                        if~isempty(find(n==maxDataLineList,1)),

                            s{end+1}=sprintf('<a name="Line%d"></a>',n);
                        end
                        s{end+1}='</pre>';
                        s{end+1}='</td>';

                        if callsPerLine>0


                            codeLine=[codeLine,' '];

                            codeLineOut='';

                            state='between';

                            substr=[];
                            for m=1:length(codeLine),
                                ch=codeLine(m);


                                if ch>=0&&ch<=127
                                    alphanumeric=alphanumericArray(ch);
                                else
                                    alphanumeric=0;
                                end

                                switch state
                                case 'identifier'
                                    if alphanumeric,
                                        substr=[substr,ch];
                                    else
                                        state='between';
                                        if isfield(targetHash,substr)
                                            substr=matlab.internal.profileviewer.printfProfilerLink('profview(%d);','%s',targetHash.(substr),substr);
                                        end
                                        codeLineOut=[codeLineOut,substr,ch];
                                    end
                                case 'between'
                                    if alphanumeric,
                                        substr=ch;
                                        state='identifier';
                                    else
                                        codeLineOut=[codeLineOut,ch];
                                    end
                                otherwise

                                    error(message('MATLAB:profiler:UnexpectedState',state));

                                end
                            end
                            codeLine=codeLineOut;
                        end


                        s{end+1}='<td class="leftAligned">';
                        s{end+1}='<pre>';
                        s{end+1}=sprintf('<span style="color: %s; background: %s; padding:1px;">%s</span><br/>',...
                        textColor,color,codeLine);
                        s{end+1}='</pre>';
                        s{end+1}='</td>';

                        if strcmp(hiliteOption,'code analyzer')&&length(mlintstrc)>0




                            mlintIdx=find([mlintstrc.line]==n);
                            s{end+1}='<td>';
                            for nMsg=1:length(mlintIdx)
                                s{end+1}=sprintf('<span style="color: #F00">%s</span><br/>',...
                                mlintstrc(mlintIdx(nMsg)).message);
                            end
                            s{end+1}='</td>';
                        end

                        s{end+1}='</tr>';

                    end

                    s{end+1}='</table>';
                    if moreSubfunctionsInFileFlag
                        s{end+1}=['<p><p>',getString(message('MATLAB:profiler:SubfunctionsNotIncluded'))];
                    end
                end
            end





            s{end+1}=matlab.internal.profileviewer.makeprofilerfooter();


            function adjustedFtItem=adjustExecutionTimeForLineContinuations(startLine,endLine,ftItem,executedLines,ftok)






































                continuationStartLineIdx=-1;



                for n=startLine:endLine
                    executableLineIdx=executedLines(n);


                    tokenLineNumber=ftok(n);
                    if isequal(tokenLineNumber,0)||isequal(tokenLineNumber,n)
                        continuationStartLineIdx=-1;
                        continue;
                    end





                    if isequal(executableLineIdx,0)
                        continue;
                    end




                    if isequal(continuationStartLineIdx,-1)
                        if~isequal(executedLines(tokenLineNumber),0)
                            continuationStartLineIdx=executedLines(tokenLineNumber);
                        else
                            continuationStartLineIdx=executableLineIdx;
                        end
                    end




                    continuationTimingData=...
                    ftItem.ExecutedLines(executableLineIdx,3);



                    continuationSumData=...
                    ftItem.ExecutedLines(continuationStartLineIdx,3);


                    ftItem.ExecutedLines(continuationStartLineIdx,3)=...
                    continuationSumData+continuationTimingData;


                    ftItem.ExecutedLines(executableLineIdx,3)=0;
                end
                adjustedFtItem=ftItem;

                function escapedString=escapeHtml(originalString)

                    escapedString=originalString;
                    escapedString=strrep(escapedString,'&','&amp;');
                    escapedString=strrep(escapedString,' ','&nbsp;');
                    escapedString=strrep(escapedString,'<','&lt;');
                    escapedString=strrep(escapedString,'>','&gt;');
                    escapedString=strrep(escapedString,'"','&quot;');
                    escapedString=strrep(escapedString,'''','&apos;');


                    function shortFileName=truncateDisplayName(longFileName,maxNameLen)



                        if length(longFileName)>maxNameLen
                            shortFileName=['...',longFileName(end-maxNameLen+1:end)];
                        else
                            shortFileName=longFileName;
                        end
                        shortFileName=escapeHtml(shortFileName);



                        function b=hasMemoryData(s)

                            b=(isfield(s,'PeakMem')||...
                            (isfield(s,'FunctionTable')&&isfield(s.FunctionTable,'PeakMem')));

                            function s=formatData(key_data_field,num)


                                switch(key_data_field)
                                case 1
                                    if num>0
                                        s=sprintf('%4.3f s',num);
                                    else
                                        s='0 s';
                                    end
                                case 2
                                    num=num./1024;
                                    s=sprintf('%4.2f Kb',num);
                                case 3
                                    s=num2str(num);
                                end


                                function s=formatNicePercent(a,b)


                                    if b>0&&a>0
                                        s=sprintf('%3.1f%%',100*a/b);
                                    else
                                        s='0%';
                                    end


                                    function x=toKb(y,fmt,terse)


                                        values={1,1024,1024,1024,1024};
                                        if nargin==3&&terse
                                            suffixes={'b','k','m','g','t'};
                                        else
                                            suffixes={' bytes',' Kb',' Mb',' Gb',' Tb'};
                                        end

                                        suff=suffixes{1};

                                        for i=1:length(values)
                                            if abs(y)>=values{i}
                                                suff=suffixes{i};
                                                y=y./values{i};
                                            else
                                                break;
                                            end
                                        end

                                        if nargin==1
                                            if strcmp(suff,suffixes{1})
                                                fmt='%4.0f';
                                            else
                                                fmt='%4.2f';
                                            end
                                        end

                                        x=sprintf([fmt,suff],y);


                                        function n=busyLineSortKeyStr2Num(str)


                                            if strcmp(str,'time')
                                                n=1;
                                                return;
                                            elseif strcmp(str,'allocated memory')
                                                n=2;
                                                return;
                                            elseif strcmp(str,'freed memory')
                                                n=3;
                                                return;
                                            elseif strcmp(str,'peak memory')
                                                n=4;
                                                return;
                                            end

                                            error(message('MATLAB:profiler:UnknownSortKind',str));


                                            function str=busyLineSortKeyNum2Str(n)


                                                strs={'time'};



                                                if(callstats('memory')>1)
                                                    strs=[strs,'allocated memory','freed memory','peak memory'];
                                                end

                                                str=strs{n};


                                                function[bgColorCode,bgColorTable,textColorCode,textColorTable]=makeColorTables(...
                                                    f,hiliteOption,ftItem,ftok,startLine,endLine,executedLines,...
                                                    runnableLines,mlintstrc,maxNumCalls)



                                                    bgColorCode=ones(length(f),1);
                                                    textColorCode=ones(length(f),1);
                                                    textColorTable={'#228B22','#000000','#A0A0A0'};


                                                    memColorTable={'#FFFFFF','#00FF00','#00EE00','#00DD00','#00CC00'...
                                                    ,'#00BB00','#00AA00','#009900','#008800','#007700'};

                                                    switch hiliteOption
                                                    case 'time'

                                                        bgColorTable={'#FFFFFF','#FFF0F0','#FFE2E2','#FFD4D4','#FFC6C6',...
                                                        '#FFB8B8','#FFAAAA','#FF9C9C','#FF8E8E','#FF8080'};
                                                        key_data_field=1;
                                                    case 'numcalls'

                                                        bgColorTable={'#FFFFFF','#F5F5FF','#ECECFF','#E2E2FF','#D9D9FF',...
                                                        '#D0D0FF','#C6C6FF','#BDBDFF','#B4B4FF','#AAAAFF'};
                                                    case 'coverage'
                                                        bgColorTable={'#FFFFFF','#E0E0FF'};
                                                    case 'noncoverage'
                                                        bgColorTable={'#FFFFFF','#E0E0E0'};
                                                    case 'code analyzer'
                                                        bgColorTable={'#FFFFFF','#FFE0A0'};

                                                    case 'allocated memory'
                                                        bgColorTable=memColorTable;
                                                        key_data_field=2;

                                                    case 'freed memory'
                                                        bgColorTable=memColorTable;
                                                        key_data_field=3;

                                                    case 'peak memory'
                                                        bgColorTable=memColorTable;
                                                        key_data_field=4;

                                                    case 'none'
                                                        bgColorTable={'#FFFFFF'};

                                                    otherwise
                                                        error(message('MATLAB:profiler:UnknownHiliteOption',hiliteOption));
                                                    end

                                                    maxData(1)=max(ftItem.ExecutedLines(:,3));

                                                    if hasMemoryData(ftItem)
                                                        maxData(2)=max(ftItem.ExecutedLines(:,4));
                                                        maxData(3)=max(ftItem.ExecutedLines(:,5));
                                                        maxData(4)=max(ftItem.ExecutedLines(:,6));
                                                    end

                                                    for n=startLine:endLine

                                                        if ftok(n)==0

                                                            textColorCode(n)=1;
                                                        elseif ftok(n)<n


                                                            bgColorCode(n)=bgColorCode(ftok(n));
                                                            textColorCode(n)=textColorCode(ftok(n));
                                                        else

                                                            lineIdx=executedLines(n);

                                                            if(strcmp(hiliteOption,'time')||...
                                                                strcmp(hiliteOption,'allocated memory')||...
                                                                strcmp(hiliteOption,'freed memory')||...
                                                                strcmp(hiliteOption,'peak memory'))

                                                                if lineIdx>0
                                                                    textColorCode(n)=2;
                                                                    if ftItem.ExecutedLines(lineIdx,key_data_field+2)>0
                                                                        dataPerLine=ftItem.ExecutedLines(lineIdx,key_data_field+2);
                                                                        ratioData=dataPerLine/maxData(key_data_field);
                                                                        bgColorCode(n)=ceil(10*ratioData);
                                                                    else

                                                                        bgColorCode(n)=1;
                                                                    end
                                                                else

                                                                    textColorCode(n)=3;
                                                                    bgColorCode(n)=1;
                                                                end

                                                            elseif strcmp(hiliteOption,'numcalls')

                                                                if lineIdx>0
                                                                    textColorCode(n)=2;
                                                                    if ftItem.ExecutedLines(lineIdx,2)>0;
                                                                        callsPerLine=ftItem.ExecutedLines(lineIdx,2);
                                                                        ratioNumCalls=callsPerLine/maxNumCalls;
                                                                        bgColorCode(n)=ceil(10*ratioNumCalls);
                                                                    else

                                                                        bgColorCode(n)=1;
                                                                    end
                                                                else

                                                                    textColorCode(n)=3;
                                                                    bgColorCode(n)=1;
                                                                end

                                                            elseif strcmp(hiliteOption,'coverage')

                                                                if lineIdx>0
                                                                    textColorCode(n)=2;
                                                                    bgColorCode(n)=2;
                                                                else

                                                                    textColorCode(n)=3;
                                                                    bgColorCode(n)=1;
                                                                end

                                                            elseif strcmp(hiliteOption,'noncoverage')




                                                                if(lineIdx>0)||(runnableLines(n)==0)
                                                                    textColorCode(n)=2;
                                                                    bgColorCode(n)=1;
                                                                else

                                                                    textColorCode(n)=2;
                                                                    bgColorCode(n)=2;
                                                                end

                                                            elseif strcmp(hiliteOption,'code analyzer')

                                                                if any([mlintstrc.line]==n)
                                                                    bgColorCode(n)=2;
                                                                    textColorCode(n)=2;
                                                                else
                                                                    bgColorCode(n)=1;
                                                                    if lineIdx>0
                                                                        textColorCode(n)=2;
                                                                    else

                                                                        textColorCode(n)=3;
                                                                    end
                                                                end

                                                            elseif strcmp(hiliteOption,'none')

                                                                if lineIdx>0
                                                                    textColorCode(n)=2;
                                                                else

                                                                    textColorCode(n)=3;
                                                                end

                                                            end
                                                        end
                                                    end

                                                    function str=typeToDisplayValue(type)

                                                        switch type
                                                        case 'M-function'
                                                            str=getString(message('MATLAB:profiler:Function'));
                                                        case 'M-subfunction'
                                                            str=getString(message('MATLAB:profiler:Subfunction'));
                                                        case 'M-anonymous-function'
                                                            str=getString(message('MATLAB:profiler:AnonymousFunctionShort'));
                                                        case 'M-nested-function'
                                                            str=getString(message('MATLAB:profiler:NestedFunction'));
                                                        case 'M-method'
                                                            str=getString(message('MATLAB:profiler:Method'));
                                                        case 'M-script'
                                                            str=getString(message('MATLAB:profiler:Script'));
                                                        case 'MEX-function'
                                                            str=getString(message('MATLAB:profiler:MEXfile'));
                                                        case 'Builtin-function'
                                                            str=getString(message('MATLAB:profiler:BuiltinFunction'));
                                                        case 'Java-method'
                                                            str=getString(message('MATLAB:profiler:JavaMethod'));
                                                        case 'constructor-overhead'
                                                            str=getString(message('MATLAB:profiler:ConstructorOverhead'));
                                                        case 'MDL-function'
                                                            str=getString(message('MATLAB:profiler:SimulinkModelFunction'));
                                                        case 'Root'
                                                            str=getString(message('MATLAB:profiler:Root'));
                                                        otherwise
                                                            str=type;
                                                        end

                                                        function str=generateTableElementLink(pref,fontWeight,msgID)

                                                            str=['<td class="td-linebottomrt" style="background-color:#F0F0F0" valign="top">'...
                                                            ,matlab.internal.profileviewer.printfProfilerLink(['setpref(''profiler'',''sortMode'',''',pref,''');profview(0);'],'<span style="font-weight:%s">%s</span>',fontWeight,getString(message(msgID)))];

                                                            function matlabCodeAsCellArray=getmcode(filename)



                                                                fileContentsAsString=matlab.internal.getCode(filename);
                                                                if(isempty(fileContentsAsString))
                                                                    matlabCodeAsCellArray={};
                                                                else
                                                                    matlabCodeAsCellArray=strsplit(fileContentsAsString,{'\r\n','\n','\r'},'CollapseDelimiters',false)';
                                                                end
