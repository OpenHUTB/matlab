function[cellarr]=str2CellArr(this,str,sep)




    if(isempty(str))
        cellarr={};
    else
        cellarr=strsplit(str,sep);
    end

end

