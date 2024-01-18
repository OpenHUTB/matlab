function yesno=isHarnessIdString(id)

    id=convertStringsToChars(id);

    if ischar(id)
        yesno=contains(id,':urn:uuid:');
    else
        yesno=false;
    end
end
