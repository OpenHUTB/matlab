function iTitle=gr_getTitle(this,fName,sysName,varargin)%#ok










    switch this.TitleType
    case 'manual'
        iTitle=rptgen.parseExpressionText(this.Title);

    case 'sysname'
        try
            iTitle=get_param(sysName,'Name');
        catch
            iTitle=sysName;
        end

    case 'fullname'
        iTitle=sysName;

    otherwise
        iTitle='';
    end
