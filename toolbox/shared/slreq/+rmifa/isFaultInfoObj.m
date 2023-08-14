function yesno=isFaultInfoObj(obj)





    obj=convertStringsToChars(obj);

    if rmifa.isLinkingForFaultObjAllowed(obj)
        yesno=true;
    elseif rmifa.isFaultIdString(obj)
        yesno=true;
    else
        yesno=false;
    end
end
