function att=v1convert_att(h,att,varargin)





    att.PrintSize=att.PaperSize;
    att=rmfield(att,'PaperSize');


    att.PrintUnits=att.PaperUnits;
    att=rmfield(att,'PaperUnits');


    if isempty(att.PaperOrientation)
        att.PaperOrientation='inherit';
    end







    if isfield(att,'isInvertHardcopy')
        if att.isInvertHardcopy
            att.InvertHardcopy='on';
        else
            att.InvertHardcopy='off';
        end
        att=rmfield(att,'isInvertHardcopy');
    end

    if isfield(att,'CaptionType')
        att.CaptionType=att.CaptionType(2:end);

    end