function out=readResults(str)




    out=[];


    lines=strsplit(str,';');


    for l=1:length(lines)-1


        tokens=regexp(lines{l},'([A-Z]+)\(([^;]*)\)','tokens');



        if length(tokens)==1&&strcmp(tokens{1}{1},'TESTCASE')

            out=addTestCase(out,tokens{1}{2});

        elseif length(tokens)==1&&strcmp(tokens{1}{1},'SIMOUTPUT')

            out=addSimOutput(out,tokens{1}{2});

        elseif length(tokens)==1&&strcmp(tokens{1}{1},'RANGE')

            out=addRange(out,tokens{1}{2});

        elseif length(tokens)==1&&strcmp(tokens{1}{1},'ECHO')
































            out=addMsgDetails(out,tokens{1}{2});

        else









            tokens=regexp(lines{l},'(\d*):([A-Z_]+):?([^;]*)','tokens');


            if length(tokens)==1

                if isfield(out,'goals')&&isfield(out.goals,lower(tokens{1}{2}))
                    out.goals.(lower(tokens{1}{2}))(end+1)=str2double(tokens{1}{1});
                    out.goals.([lower(tokens{1}{2}),'_str']){end+1}=tokens{1}{3};
                else
                    out.goals.(lower(tokens{1}{2}))=str2double(tokens{1}{1});
                    out.goals.([lower(tokens{1}{2}),'_str'])=tokens{1}{3};
                end

            else

                tokens=regexp(lines{l},'STATUS: ([^;]*)','tokens');


                if length(tokens)==1

                    out.status=tokens{1}{1};

                else

                    tokens=regexp(lines{l},'PROFILE ([^;]*)','tokens');


                    if length(tokens)==1

                        profileStr=tokens{1}{1};
                        [cmd,args]=strtok(profileStr,' ');
                        switch(cmd)
                        case 'start'


                            out.profiler=strtrim(args);
                        case 'end'
                            out.profiler=-1;
                        case 'info'
                            [field,value]=strtok(args,' ');
                            value=strtok(value,' ');
                            if any(value(1)=='-1234567890')
                                value=str2double(value);
                            end
                            try
                                out.profiler=struct(field,value);
                            catch

                            end
                        case 'REPLAY'
                            fileToReplay=strtrim(args);
                            out.profileReplay=fileToReplay;
                        end
                    end
                end
            end
        end
    end

end

function out=addRange(out,str)
    try
        rTokens=regexp(str,'(\d+)| ([^,]+), ([^,]+)','tokens');
        id=str2double(rTokens{1}{1});

        lb=strrep(rTokens{2}{1},'~','-');
        ub=strrep(rTokens{2}{2},'~','-');
        numRanges=size(rTokens,2)-1;
        ranges=cell(numRanges,2);
        rangeCount=1;
        ranges(rangeCount,:)={lb,ub};

        for i=3:length(rTokens)
            rangeCount=rangeCount+1;
            lb=strrep(rTokens{i}{1},'~','-');
            ub=strrep(rTokens{i}{2},'~','-');
            ranges(rangeCount,:)={lb,ub};
        end

        if isfield(out,'Ranges')
            out.Ranges{end+1}={id,{ranges}};
        else
            out.Ranges={{id,{ranges}}};
        end
    catch MEx %#ok<NASGU>

    end
end

function out=addTestCase(out,tc)
    tokens=regexp(tc,'(.*)\|(.*)','tokens');
    goals=tokens{1}{1};
    values=tokens{1}{2};

    gTokens=regexp(goals,'(\d+):(\d+)','tokens');
    mxGoals=zeros([length(gTokens),2]);
    for i=1:length(gTokens)
        mxGoals(i,1)=str2double(gTokens{i}{1});
        mxGoals(i,2)=str2double(gTokens{i}{2});
    end

    if isfield(out,'testcases')
        out.testcases(end+1).goals=mxGoals;
    else
        out.testcases.goals=mxGoals;
    end

    out.testcases(end).values={};
    vTokens=regexp(values,'\((\d+):([^\)]*)\)','tokens');
    for i=1:length(vTokens)
        var=str2double(vTokens{i}{1});
        [val,dc]=readValues(vTokens{i}{2});

        out.testcases(end).values{end+1}{1}=var;
        out.testcases(end).values{end}{2}=val;
        out.testcases(end).values{end}{3}=dc;
    end
end

function out=addSimOutput(out,outputval)
    if isfield(out,'simoutputs')
        out.simoutputs(end+1).values={};
    else
        out.simoutputs.values={};
    end
    vTokens=regexp(outputval,'\((\d+):([^\)]*)\)','tokens');
    for i=1:length(vTokens)
        var=str2double(vTokens{i}{1});
        [val,dc]=readValues(vTokens{i}{2});

        out.simoutputs(end).values{end+1}{1}=var;
        out.simoutputs(end).values{end}{2}=val;
        out.simoutputs(end).values{end}{3}=dc;
    end
end















function[val,dc]=readValues(str)
    val={};
    dc=[];

    bTokens=regexp(str,'\[([^\]]*)]','tokens');
    if isempty(bTokens)
        valTokens=regexp(str,',','split');
        valTokens=strtrim(valTokens);







        dc=strcmp('_',valTokens);
        val=valTokens;
        val(dc|strcmpi('F',val))={'0'};
        val(strcmpi('T',val))={'1'};

        dc=double(dc);
    else
        for i=1:length(bTokens)
            [v,d]=readValues(bTokens{i}{1});
            val=[val,v'];%#ok<AGROW>
            dc=[dc,d'];%#ok<AGROW>
        end
    end
end

function out=addMsgDetails(out,str)








    msgType=strtok(str,',');
    msgId='';
    msgargs={};

    if strcmpi(msgType,'EXTERNAL_MESSAGE')


        msgId='Sldv:DVOTOOLS:ExtMsg';
        argstoken=regexp(str,'\w+\s*,\s*(.+)','tokens');

        if~isempty(argstoken)
            msgargs=argstoken{1}{1};
        end
    else



        spltStr=regexp(str,'\s*,\s*','split');
        if length(spltStr)>1

            msgId=spltStr{2};
            if length(spltStr)>2

                msgargs=spltStr(3:end);
            end
        end
    end

    if~isfield(out,'msg')
        out.msg={};
    end
    out.msg{end+1}={msgType,msgId,msgargs};
end


