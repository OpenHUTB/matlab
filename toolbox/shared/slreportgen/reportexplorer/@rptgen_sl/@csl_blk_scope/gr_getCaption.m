function cap=gr_makeCaption(c,fName,hFig,blkName,varargin)






    switch c.CaptionType
    case 'auto'
        try
            cap=get_param(blkName,'Description');
        catch
            cap='';
        end
    case 'manual'
        cap=rptgen.parseExpressionText(c.Caption);
    otherwise

        cap='';
    end