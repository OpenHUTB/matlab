function profviewgateway(inStr)












    if nargin==0
        inStr='?parentDisplayMode=table';
    end

    if inStr(1)=='?'
        inStr(1)='&';
    end

    strc=[];
    match1=regexp(inStr,'&([^&]*)','tokens');
    for n=1:length(match1)
        match2=regexp(match1{n}{1},'([^=]*)=([^=]*)','tokens');
        for m=1:length(match2)
            prop=urldecode(match2{m}{1});
            val=urldecode(match2{m}{2});
            strc.(prop)=val;
        end
    end

    profileIndex=str2double(strc.profileIndex);




    if profileIndex==0

    else
        fld=fieldnames(strc);
        for n=1:length(fld)
            setpref('profiler',fld{n},strc.(fld{n}));
        end
        if(~isfield(strc,'hiliteOption')&&...
            ~isfield(strc,'busyLineSortKey'))
            interpretCheckbox(strc,'parentDisplayMode')
            interpretCheckbox(strc,'busylineDisplayMode')
            interpretCheckbox(strc,'childrenDisplayMode')
            interpretCheckbox(strc,'mlintDisplayMode')
            interpretCheckbox(strc,'listingDisplayMode')
            interpretCheckbox(strc,'coverageDisplayMode')
        end
    end

    htmlOut=profview(profileIndex);
    com.mathworks.mde.profiler.OldProfiler.setHtmlText(htmlOut);



    function interpretCheckbox(strc,modeStr)


        setpref('profiler',modeStr,0)
        if isfield(strc,modeStr)
            if strcmpi(strc.(modeStr),'on')
                setpref('profiler',modeStr,1)
            end
        else

            setpref('profiler',modeStr,0)
        end
