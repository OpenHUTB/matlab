function emcError(fname,report)



    if isempty(report)||(numel(fieldnames(report))==1&&isfield(report,'internal'))
        if is_demo_publish_mode
            msgstruct.identifier='emlc:compilationError';
            if isfield(report,'internal')
                msgstruct.message=report.internal.message;
                for i=1:numel(report.internal.stack)
                    stk=report.internal.stack(i);
                    msgstruct.message=[msgstruct.message,10,stk.file,':',num2str(stk.line)];
                end
            end
            error(msgstruct);
        end
        report=struct();
        report.summary.passed=false;
    end
    if~report.summary.passed
        msgstruct.identifier='emlc:compilationError';
        msgstruct.message='';
        if is_demo_publish_mode
            msgstruct.message=get_useful_info(report);
        end
        msgstruct.stack(1).file='';
        msgstruct.stack(1).name=fname;
        msgstruct.stack(1).line=0;
        try
            error(msgstruct);
        catch ME
            ME.throwAsCaller;
        end
    end

    if isfield(report.summary,'testBenchPassed')&&~report.summary.testBenchPassed
        msgstruct.identifier='Coder:FE:TestBenchFail';
        msgstruct.message=report.summary.testBenchDetails;
        try
            error(msgstruct);
        catch ME
            ME.throwAsCaller;
        end
    end



    function ok=is_demo_publish_mode
        data=snapnow('get');
        if isempty(data)||~isstruct(data)||~isfield(data,'options')
            ok=false;
            return
        end
        data=data.options;
        if~isfield(data,'stylesheet')||~isfield(data,'outputDir')||...
            ~isfield(data,'catchError')
            ok=false;
            return
        end
        ok=true;

        function txt=get_useful_info(report)
            txt='';
            if isfield(report,'summary')
                if isfield(report.summary,'messageList')&&~isempty(report.summary.messageList)
                    txt=report.summary.messageList{1}.MsgText;
                    txt=[txt,10];
                end
                if isfield(report.summary,'buildResults')&&~isempty(report.summary.buildResults)
                    for i=1:numel(report.summary.buildResults)
                        buildResult=report.summary.buildResults{i};
                        if~isempty(buildResult.Log)
                            txt=[txt,buildResult.Log];%#ok<AGROW>
                        end
                    end
                end
            end
