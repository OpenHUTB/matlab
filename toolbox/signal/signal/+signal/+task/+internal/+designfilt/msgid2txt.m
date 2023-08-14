function[txt,msg]=msgid2txt(id,varargin)

    msg=message(['signal:task:designfiltTask:designfiltTask:',char(id)],varargin{:});
    txt=msg.getString;
end