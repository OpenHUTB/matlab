classdef InstrProfilingInfo<handle



    methods(Static)

        function[srcFiles,hdrFiles,startEndExpr,startExpr,endExpr]=buildRegexp...
            (srcFilesList,headerFilesList,startSymbol,endSymbol)









            if~iscell(srcFilesList)
                pattern='(?<=\s|^)(?!=\s).*?(?=(\s)|($))';
                srcFiles=regexp(srcFilesList,pattern,'match');
                hdrFiles=regexp(headerFilesList,pattern,'match');
            else
                srcFiles=strtrim(srcFilesList);
                hdrFiles=strtrim(headerFilesList);
            end

            traceIdExpr='([0-9]+)(U|u)(L|l)*';
            startEndExpr=sprintf('((%s)|(%s))\\(%s\\);',...
            startSymbol,...
            endSymbol,...
            traceIdExpr);
            startExpr=sprintf('(%s)\\(%s\\);',...
            startSymbol,...
            traceIdExpr);
            endExpr=sprintf('(%s)\\(%s\\);',...
            endSymbol,...
            traceIdExpr);
        end

        function[idUnique,idxStart,idxEnd]=matchStartEndProbes...
            (tokens,startSymbol)

            flat=[tokens{1,:}];
            probeNames=flat(1:length(tokens{1}):numel(flat));
            probeIds=flat(2:length(tokens{1}):numel(flat));

            assert(length(probeNames)==length(probeIds),...
            'Size of probe names and their identification tags must be the same');

            [idUnique,~,ic]=unique(probeIds);

            idxStart=cell(size(idUnique));
            idxEnd=cell(size(idUnique));

            for i=1:length(idUnique)
                idx=find(ic==i);
                assert(length(idx)==2,'Must have start and end for each probe');
                idxStart_=strcmp(probeNames(idx),startSymbol);
                idxStart{i}=idx(idxStart_);
                idxEnd{i}=idx(~idxStart_);
                assert(length(idxStart{i})==1,'Must have one start for each probe');
            end
        end


    end

end
