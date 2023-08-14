function caption=gr_getCaption(this,fName,sysName,varargin)%#ok








    switch this.CaptionType
    case 'auto'
        try
            caption=get_param(sysName,'Description');
        catch
            caption='';
        end

    case 'manual'
        caption=rptgen.parseExpressionText(this.Caption);

    otherwise
        caption='';
    end
