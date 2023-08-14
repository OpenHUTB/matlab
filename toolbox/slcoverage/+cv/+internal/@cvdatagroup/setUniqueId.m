function setUniqueId(this)




    if isempty(this.uniqueId)
        guidStr=char(matlab.lang.internal.uuid);
        this.uniqueId=guidStr;
    end
