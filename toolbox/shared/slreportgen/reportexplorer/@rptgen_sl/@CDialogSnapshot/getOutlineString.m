function s=getOutlineString(this)






    adSL=rptgen_sl.appdata_sl;
    ct=adSL.getContextType(this,false);

    if isempty(ct)||strcmpi(ct,'none')
        s=this.getName;
    else
        s=[ct,' ',this.getName];
    end