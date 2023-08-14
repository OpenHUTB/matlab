function oStr=opcblkitemlist(itemStr,block)













    if isempty(strtrim(itemStr)),
        oStr='';
        return
    end
    str=strtrim(strread(itemStr,'%s','delimiter',','));
    if~iscell(str),
        str=cellstr(str);
    end

    pos=get_param(block,'Position');
    width=pos(3)-pos(1);
    fs=get_param(block,'FontSize');
    if fs==-1,
        fs=get_param(strtok(block,'/'),'DefaultBlockFontSize');
    end
    maxLen=2*(width-30)*72/96/fs;
    itmList=str;
    for k=1:length(str)
        tL=length(str{k});
        if tL>maxLen,
            itmList{k}=[str{k}(1:floor((maxLen-3)/2)),'...',str{k}(end-ceil((maxLen-3)/2)+1:end)];
        end
    end
    oStr=sprintf('%s\n',itmList{:});


