function profile_subsystem_execution_report(profData)












    subsystemTimes=[];
    subsystemNameList=profData.taskNameList;
    subsystemTs=profData.taskTs;
    dataLoggingDuration=subsystemTs(end)-subsystemTs(1);
    modelName=profData.modelName;


    for i=1:length(subsystemNameList)
        [tMax,tMaxAt,tAv,eMax,eMaxAt,eAv,tSampleAv]=...
        i_subsystem_times(profData.taskActivity(:,i),subsystemTs);
        subsystemTimes=[subsystemTimes;tMax,tMaxAt,tAv,eMax,eMaxAt,eAv,tSampleAv];%#ok<AGROW>
    end


    subsystemTimesHtml=i_subsystemTimesToHtml(subsystemTimes,subsystemNameList,profData,modelName);
    maxTurnaroundTimesHtml=i_turnaroundTimesToHtml(profData.tMax,subsystemNameList);
    timePerTickHtml=i_format(profData.timePerTick);
    dataLoggingDurationHtml=i_format(dataLoggingDuration);


    output_file=fullfile(tempdir,['ex_profile_',regexprep(num2str(fix(clock)),'\s+','_'),'.html']);
    i_html_insert(output_file,...
    '====subsystem timing analysis table====',subsystemTimesHtml,...
    '====Insert duration of data logging====',dataLoggingDurationHtml,...
    '====timer resolution====',timePerTickHtml,...
    '====maximum turnaround times====',maxTurnaroundTimesHtml);


    web(['file:///',output_file]);


    if exist('qeTestProfileReportLinks.m','file')
        evalin('base',['profile_report_html = ''',output_file,''';']);
    end




    function tableRows=i_subsystemTimesToHtml(times,subsystemNameList,profData,modelName)

        tableRows=[...
'<TR><TD><b>Atomic Subsystem</b>'...
        ,'<TD><b>Maximum turnaround time</b>'...
        ,'<TD><b>Average turnaround time</b>'...
        ,'<TD><b>Maximum execution time</b>'...
        ,'<TD><b>Average execution time</b>'...
        ,'</TR>'];

        for i=1:length(times(:,1))
            name=subsystemNameList{i};
            name=openSystemHyperlink(modelName,name,name);

            if~isinf(times(i,1))
                maxTurn=[i_format(times(i,1)),' at t = ',i_format(times(i,2))];
            else
                maxTurn='N/A';
            end

            if~isinf(times(i,3))
                avTurn=i_format(times(i,3));
            else
                avTurn='N/A';
            end
            if~isinf(times(i,4))
                maxExec=[i_format(times(i,4)),' at t = ',i_format(times(i,5))];
            else
                maxExec='N/A';
            end
            if~isinf(times(i,6))
                avExec=i_format(times(i,6));
            else
                avExec='N/A';
            end
            if~isinf(times(i,7))
                avSample=i_format(times(i,7));
            else
                avSample='N/A';
            end
            row=[...
            '<TR><TD><b>',name,'</b>'...
            ,'<TD>',maxTurn...
            ,'<TD>',avTurn...
            ,'<TD>',maxExec...
            ,'<TD>',avExec...
            ,'</TR>'];
            tableRows=sprintf('%s\n%s',tableRows,row);
        end

        for i=(length(times(:,1))+1):length(subsystemNameList)
            name=subsystemNameList{i};
            row=[...
            '<TR><TD><b>',name,'</b>'...
            ,'<TD colspan=5>',profData.warning...
            ,'</TR>'];
            tableRows=sprintf('%s\n%s',tableRows,row);
        end




        function tableRows=i_turnaroundTimesToHtml(times,subsystemNameList)

            tableRows=[...
'<TR><TD><b>Subsystem</b>'...
            ,'<TD><b>Maximum turnaround time</b>'...
            ,'</TR>'];



            function[tMax,tMaxAt,tAv,eMax,eMaxAt,eAv,tSampleAv]=...
                i_subsystem_times(subsystemEvents,subsystemTs)


                eventDiff=diff(double(subsystemEvents));
                changedIdx=[1;(find(eventDiff~=0)+1)];
                subsystemEvents=subsystemEvents(changedIdx);
                subsystemTs=subsystemTs(changedIdx);


                execIdx=find(subsystemEvents=='e');

                idleIdx=find(subsystemEvents=='i');


                startIdx=idleIdx(1:end-1)+1;


                endIdx=idleIdx(2:end);

                if(~isempty(execIdx)&&execIdx(1)==1)

                    numSamples=length(idleIdx);
                    if(~isempty(numSamples)&&(numSamples>0))

                        startIdx=[1;startIdx];
                        endIdx=[idleIdx(1);endIdx];
                    end
                end


                nSamples=length(idleIdx)-1;


                tTurnaround=zeros(nSamples,1);
                tExecution=zeros(nSamples,1);

                for i=1:nSamples
                    eIdx=endIdx(i);
                    sIdx=startIdx(i);
                    tTurnaround(i)=subsystemTs(eIdx)-subsystemTs(sIdx);
                    tExecution(i)=sum(subsystemTs(eIdx:(-2):(sIdx+1)))...
                    -sum(subsystemTs(sIdx:2:(eIdx-1)));
                end


                tMax=max(tTurnaround);
                if isempty(tMax)
                    tMax=Inf;
                end


                tMaxAt=subsystemTs(startIdx(find(tTurnaround==tMax,1,'first')));
                if isempty(tMaxAt)
                    tMaxAt=Inf;
                end


                if(~isempty(tTurnaround))
                    tAv=sum(tTurnaround)/length(tTurnaround);
                else
                    tAv=Inf;
                end


                eMax=max(tExecution);
                if isempty(eMax)
                    eMax=Inf;
                end


                eMaxAt=subsystemTs(startIdx(find(tExecution==eMax,1,'first')));
                if isempty(eMaxAt)
                    eMaxAt=Inf;
                end


                if(~isempty(tExecution))
                    eAv=sum(tExecution)/length(tExecution);
                else
                    eAv=Inf;
                end

                if(nSamples>=2)
                    firstSampleStart=idleIdx(1)+1;
                    lastSampleStart=idleIdx(end-1)+1;
                    tSampleAv=(subsystemTs(lastSampleStart)-subsystemTs(firstSampleStart))/(nSamples-1);
                else
                    tSampleAv=Inf;
                end







                function i_html_insert(outfile,varargin)


                    myDir=fileparts(which(mfilename));
                    fid=fopen(fullfile(myDir,'profile_subsystem_execution_report.html'));
                    buf=fread(fid,Inf,'uchar');
                    buf=char(buf');
                    fclose(fid);


                    for i=1:2:length(varargin)
                        oldstr=varargin{i};
                        newstr=varargin{i+1};
                        bufout=strrep(buf,oldstr,newstr);
                        buf=bufout;
                    end


                    fid=fopen(outfile,'w');
                    fwrite(fid,bufout,'uchar');
                    fclose(fid);




                    function str=i_format(inval)
                        [inval,prefix1,fmt1]=i_format_operator(inval);
                        if strcmpi(fmt1,'exp')
                            str=sprintf('%0.3g s',inval);
                        else
                            str=sprintf('%15.3f %ss',inval,prefix1);
                        end





                        function[inval,prefix,fmt]=i_format_operator(inval)

                            if inval>=1e6||inval<1e-9
                                fmt='exp';
                                prefix='';
                            else
                                prefixopt={'','m','&micro;','n'};
                                fmt='fix';
                                pidx=1;
                                while inval~=0.0&&inval<1&&pidx~=length(prefixopt)
                                    inval=inval*1000;
                                    pidx=pidx+1;
                                end
                                prefix=prefixopt{pidx};
                            end


                            function str=openSystemHyperlink(modelName,sysName,linkText)


                                sysName2=strrep(sysName,sprintf('\n'),'\n');

                                linkText2=strrep(linkText,sprintf('\n'),'');

                                if strcmp(sysName,'<Root>'),
                                    str=['<A href = "matlab:'...
                                    ,'open_system(''',modelName,'''), '...
                                    ,'">',linkText2,'</A>'];
                                else
                                    str=['<A href = "matlab:'...
                                    ,'load_system(''',modelName,'''), '...
                                    ,'pause(.1), '...
                                    ,'open_system(sprintf(''',sysName2,'''),''force'')'...
                                    ,'">',linkText2,'</A>'];
                                end