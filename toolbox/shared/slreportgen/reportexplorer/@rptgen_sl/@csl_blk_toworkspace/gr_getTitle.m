function imTitle=gr_getTitle(c,fName,figH,varName,blkName,prefix,varargin)









    switch(c.TitleType)
    case 'varname'
        imTitle=[prefix,' ',varName];
    case 'blkname'
        imTitle=[prefix,' ',blkName];
    case 'manual'
        imTitle=[prefix,' ',rptgen.parseExpressionText(c.Title)];
    otherwise
        imTitle='';
    end