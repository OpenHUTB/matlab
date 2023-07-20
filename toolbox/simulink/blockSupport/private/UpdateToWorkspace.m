function UpdateToWorkspace(block,h)








    reason=DAStudio.message('SimulinkBlocks:upgrade:updateParameters');

    maxDataPoints=get_param(block,'MaxDataPoints');
    origMaxDataPoints=maxDataPoints;




    maxDataPoints=strtrim(maxDataPoints);




    maxDataPoints=strrep(maxDataPoints,',',' ');
    maxDataPoints=strrep(maxDataPoints,';',' ');




    bracket=strfind(maxDataPoints,'[');
    if isempty(bracket),
        return;
    end



    if~(askToReplace(h,block))
        return;
    end







    parens=strfind(maxDataPoints,'(');
    colons=strfind(maxDataPoints,':');

    if~isempty(parens)||~isempty(colons),
        MSLDiagnostic('SimulinkBlocks:upgrade:toWksSyntaxError',block).reportAsWarning;
        return;
    end


    while isspace(maxDataPoints(bracket+1)),
        maxDataPoints(bracket+1)=[];
    end

    maxDataPoints=fliplr(maxDataPoints);
    bracket=strfind(maxDataPoints,']');
    while isspace(maxDataPoints(bracket+1)),
        maxDataPoints(bracket+1)=[];
    end
    maxDataPoints=fliplr(maxDataPoints);


    maxDataPoints(1)=[];
    maxDataPoints(end)=[];







    [word1,r]=strtok(maxDataPoints);
    [word2,r]=strtok(r);
    [word3,r]=strtok(r);

    if~isempty(r),
        MSLDiagnostic('SimulinkBlocks:upgrade:toWksSyntaxError',block).reportAsWarning;
        return;
    end

    if~isempty(word1),
        pvPair{1}='MaxDataPoints';
        pvPair{2}=word1;
    end

    if~isempty(word2),
        pvPair{3}='Decimation';
        pvPair{4}=word2;
    end

    if~isempty(word3),
        pvPair{5}='SampleTime';
        pvPair{6}=word3;
    end

    dec=get_param(block,'Decimation');
    ts=get_param(block,'SampleTime');

    try
        funcSet=uSafeSetParam(h,block,pvPair{:});
        appendTransaction(h,block,reason,{funcSet});
    catch %#ok<CTCH>
        MSLDiagnostic('SimulinkBlocks:upgrade:toWksSyntaxError',block).reportAsWarning;

        if doUpdate(h)
            warn=warning;
            warning('off');%#ok
            uSafeSetParam(h,block,'MaxDataPoints',origMaxDataPoints,...
            'Decimation',dec,'SampleTime',ts);
            warning(warn);
        end
    end

end
