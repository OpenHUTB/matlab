function yesno=isDataEntry(obj)




    obj=convertStringsToChars(obj);

    if isa(obj,'Simulink.DDEAdapter')
        yesno=true;
    elseif isa(obj,'char')&&~isempty(strfind(obj,'.sldd|'))
        yesno=true;
    else
        yesno=false;
    end
end
