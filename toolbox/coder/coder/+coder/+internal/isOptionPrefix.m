function is=isOptionPrefix(charOrString)









    if~coder.internal.isCharOrScalarString(charOrString)
        is=false;
    else
        is=startsWith(charOrString,'-')||startsWith(charOrString,char(8211));
    end

end
