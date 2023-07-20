function errMsg=setPrefix(this,prefixStr)

    if strcmp(prefixStr,'')
        dispMsg(this,'Prefix cannot be set as an empty string. If not set again, default string ''gen_'' will be applied');
    else
        this.fPrefix=prefixStr;
    end



end
