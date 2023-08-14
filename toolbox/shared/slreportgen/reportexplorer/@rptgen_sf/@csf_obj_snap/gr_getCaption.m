function caption=gr_getCaption(this,fName,sfobj,varargin)%#ok








    switch this.CaptionType
    case 'auto'
        try
            caption=get(sfobj,'Description');
        catch
            caption='';
        end

    case 'manual'
        caption=rptgen.parseExpressionText(this.Caption);

    otherwise
        caption='';
    end


