function parsedResults=parseCGIRResults(obj,key)



    parsedResults=[];
    if isKey(obj.resultMap,key)
        parsedResults=obj.resultMap(key);
    else
        return;
    end
    if isempty(parsedResults)||~isfield(parsedResults,'tag')
        return;
    end
    for i=1:length(parsedResults.tag)
        parsedResults.tag{i}.sid=pruneSID(parsedResults.tag{i}.sid);
        parsedResults.tag{i}.source=pruneSource(parsedResults.tag{i}.source);
    end

    function sid=pruneSID(sid)

        lines=Advisor.BaseRegisterCGIRInspectorResults.splitUp(sid);

        ii=false(size(lines));
        for i=1:numel(ii)



            ii(i)=~isempty(regexp(regexprep(lines{i},filesep,''),regexprep(matlabroot,filesep,''),'once'))&&...
            isempty(regexp(regexprep(lines{i},filesep,''),regexprep(fullfile(matlabroot,'test','toolbox','coder'),filesep,''),'once'));
        end
        lines(ii)=[];

        sid=strjoin(lines,'\n');

        function source=pruneSource(source)

            lines=Advisor.BaseRegisterCGIRInspectorResults.splitUp(source);

            ii=false(size(lines));
            mtimesFound=false;
            for i=numel(ii):-1:1
                if~mtimesFound
                    mtimesFound=~isempty(regexp(lines{i},'''mtimes''','once'));
                    ii(i)=mtimesFound;
                else
                    ii(i)=~isempty(regexp(lines{i},'''mtimes''|''times''|''eml_fixpt_times''','once'));
                end
            end
            lines(ii)=[];

            ii=false(size(lines));
            for i=1:numel(ii)-1

                thisLine=lines{i};
                nextLine=lines{i+1};

                if(thisLine(end)=='A'&&...
                    nextLine(end)=='P'&&...
                    strcmp(thisLine(1:(end-1)),nextLine(1:(end-1))))
                    ii(i)=1;
                end
            end
            lines(ii)=[];

            source=strjoin(lines,'\n');
