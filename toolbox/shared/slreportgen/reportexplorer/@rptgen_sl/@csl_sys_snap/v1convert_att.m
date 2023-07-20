function att=v1convert_att(this,att,varargin)%#ok








    if isempty(att.PaperOrientation)
        att.PaperOrientation='inherit';
    end

    if isfield(att,'TitleString')
        att.Title=att.TitleString;
        att=rmfield(att,'TitleString');
    end

    if isfield(att,'CaptionString')
        att.Caption=att.CaptionString;
        att=rmfield(att,'CaptionString');
    end

    if isfield(att,'CaptionType')

        att.CaptionType=att.CaptionType(2:end);
    end