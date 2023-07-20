function string=getMsgString(this,tag)





    msgPrefix='dspshared:SpectrumAnalyzer:';
    if iscell(tag)
        string=cell(size(tag));
        for i=1:numel(tag)
            idx=~isspace(tag{i});
            thisTag=tag{i}(idx);
            string{i}=getMsgString(this,thisTag);
        end
    else
        msgId=[msgPrefix,tag];
        try
            [lastMsg,lastID]=lasterr;%#ok<*LERR>
            msg=message(msgId);
            string=getString(msg);
        catch %#ok<CTCH>
            string=tag;
            lasterr(lastMsg,lastID);
        end
    end
end
