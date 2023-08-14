function name=getTopModelName(this)






    if isempty(this.hParent)
        name=this.getBdRoot;
    else
        name=this.topMdlName;
    end
end
