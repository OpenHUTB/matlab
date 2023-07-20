function val=getDisplayLabel(this)



    if~isempty(this.displayLabel)
        val=this.displayLabel;
    else
        [pathstr,docname,extension]=fileparts(this.documentName);
        val=[docname,extension];
    end



