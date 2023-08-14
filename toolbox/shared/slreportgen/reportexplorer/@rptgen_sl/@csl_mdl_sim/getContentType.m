function ct=getContentType(this)


























    if strcmp(this.MessageDisplay,'report')
        ct='paragraph';
    else
        ct='';
    end
