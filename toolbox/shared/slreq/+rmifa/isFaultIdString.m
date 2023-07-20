function yesno=isFaultIdString(id)


    id=convertStringsToChars(id);

    if ischar(id)
        yesno=contains(id,rmifa.itemIDPref());
    else
        yesno=false;
    end
end
