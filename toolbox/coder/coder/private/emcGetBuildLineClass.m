function lineClass=emcGetBuildLineClass(line,compilerName)




    function lineClass=microsoft_recognizer(line)
        lineClass='normal';
        expr={'^[^\n]+\(\d+\)\s?: (error|warning|fatal) (\w|#)+\d+:','^[^\n]+ (error|warning|fatal) \w+\d+ :'};
        matches=regexp(line,expr,'tokens');
        matches=[matches{:}];
        if~isempty(matches)
            if strcmp(matches{1}{1},'warning')
                lineClass='warning';
            else
                lineClass='error';
            end
        end
        linker_expr='^[^\n]+.obj\s?: (error|warning|fatal) \w+\d+:';
        linker_matches=regexp(line,linker_expr,'tokens');
        if~isempty(linker_matches)
            if strcmp(linker_matches{1}{1},'warning')
                lineClass='warning';
            else
                lineClass='error';
            end
        end
    end


    function tokens=gcc_tokens()
        persistent ptokens
        function appendTokens(list)
            for i=1:numel(list)
                if isempty(ptokens.tokens)
                    token=list{i};
                else
                    token=['|',list{i}];
                end
                ptokens.tokens=[ptokens.tokens,token];
            end
        end

        if isempty(ptokens)
            ptokens=struct('tokens','');
            ptokens.errorStr={'error'};
            ptokens.warningStr={'warning'};
            ptokens.fatalStr={'fatal'};
            if strcmpi(feature('DefaultCharacterSet'),'utf-8')
                jpError=native2unicode(uint8([227,130,168,227,131,169,227,131,188]));
                ptokens.errorStr{end+1}=jpError;
                jpWarning=native2unicode(uint8([232,173,166,229,145,138]));
                ptokens.warningStr{end+1}=jpWarning;
            end
            appendTokens(ptokens.errorStr);
            appendTokens(ptokens.warningStr);
            appendTokens(ptokens.fatalStr);
        end
        tokens=ptokens;
    end


    function lineClass=gcc_recognizer(line)
        tokens=gcc_tokens();
        meta='^[^\n]+:\d+:\d+';
        expr=sprintf('%s: (%s): ',meta,tokens.tokens);
        matches=regexp(line,expr,'tokens');
        lineClass='normal';
        if~isempty(matches)
            switch matches{1}{1}
            case tokens.warningStr
                lineClass='warning';
            otherwise
                lineClass='error';
            end
        end
        linker_expr='^[^\n]+:(.*\+0x.*)?:\s?.*';
        linker_match=regexp(line,linker_expr,'once');
        if~isempty(linker_match)
            lineClass='error';
        end
    end

    function lineClass=lcc_recognizer(line)
        lineClass='normal';
        expr='^(Error|Warning|Fatal) [^\n]+: \d+';
        matches=regexp(line,expr,'tokens');
        if~isempty(matches)
            if strcmp(matches{1}{1},'Warning')
                lineClass='warning';
            else
                lineClass='error';
            end
        end
    end

    function lineClass=unknown_recognizer(~)
        lineClass='normal';
    end

    recognizer=@unknown_recognizer;
    if ispc
        if startsWith(compilerName,'msvc')||startsWith(compilerName,'intel')
            recognizer=@microsoft_recognizer;
        elseif strcmp(compilerName,'lcc64')
            recognizer=@lcc_recognizer;
        elseif startsWith(compilerName,'mingw64')
            recognizer=@gcc_recognizer;
        end
    elseif ismac
        if strcmp(compilerName,'clang')
            recognizer=@gcc_recognizer;
        end
    else
        if strcmp(compilerName,'gcc')
            recognizer=@gcc_recognizer;
        end
    end

    lineClass=recognizer(line);
end
