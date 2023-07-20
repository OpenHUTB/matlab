function cap=gr_makeCaption(c,fName,figH,blkTitle,blkName,varargin)






    switch lower(c.CaptionType)
    case 'auto'
        try
            cap=get_param(blkName,'Description');
        catch
            cap='';
        end
    otherwise
        cap=rptgen.parseExpressionText(c.Caption);
    end