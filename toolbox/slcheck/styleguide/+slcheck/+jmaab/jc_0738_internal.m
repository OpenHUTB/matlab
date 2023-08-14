classdef jc_0738_internal
    methods(Static)

        function result=hasViolationNewline(labelStr,expr)
            result=false;
            if isempty(labelStr)||isempty(expr)
                return;
            end

            strs=splitlines(labelStr);
            for ctr=1:length(strs)
                line=strtrim(cell2mat(strs(ctr)));
                if~isempty(regexp([line,newline],expr,'once'))
                    result=true;
                    return;
                end
            end
        end

        function result=hasViolationNesting(labelStr,expr)
            result=false;
            [~,matches]=regexp(labelStr,expr,'tokens','match');

            if~isempty(matches)
                for ctr=1:numel(matches)
                    if contains(matches{ctr},["*/","/*","//"])
                        result=true;
                        return;
                    end
                end
            end
        end

    end
end

