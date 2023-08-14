function time_in_ms=getTimeDuration(timeExp)


    if strcmpi(timeExp,'<empty>')
        time_in_ms=[];
        return
    end

    timeStartPattern='^\s*t#';
    if isempty(regexpi(timeExp,timeStartPattern))

        time_in_ms=timeExp;
        return
    end


    diagMsg=sprintf('Wrong time day format %s that should be like ''T#5d14h12m18s4ms''',timeExp);
    msgId='slplc:wrongTimeFormat';
    timeStrPattern='^\s*t#(\d+d)?(\d+h)?(\d+m)?(\d+s)?(\d+ms)?\s*$';
    assert(~isempty(regexpi(timeExp,timeStrPattern)),msgId,diagMsg);

    timeExp=strtrim(timeExp);
    timeExp=strrep(lower(timeExp),'t#','');
    timeExp=strrep(lower(timeExp),'ms','z');

    formatChar={'d','h','m','s','z'};
    timeVec=[0,0,0,0,0];

    for charCount=1:numel(formatChar)
        charIdx=strfind(timeExp,formatChar{charCount});
        if~isempty(charIdx)
            theNum=str2double(timeExp(1:charIdx-1));
            timeVec(charCount)=theNum;
            timeExp(1:charIdx)=[];
        end
    end

    time_in_ms=(((timeVec(1)*24+timeVec(2))*60+timeVec(3))*60+timeVec(4))*1000+timeVec(5);
    time_in_ms=num2str(time_in_ms);
end
