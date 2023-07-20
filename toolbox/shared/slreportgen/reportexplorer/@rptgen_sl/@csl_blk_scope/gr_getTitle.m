function imTitle=gr_getTitle(c,fName,hFig,blkName,varargin)









    switch c.TitleType
    case 'none'
        imTitle='';
    case 'blkname'
        try
            imTitle=get_param(blkName,'Name');
        catch
            imTitle=blkName;
        end
    case 'fullname'
        imTitle=blkName;
    otherwise
        imTitle=rptgen.parseExpressionText(c.Title);
    end


