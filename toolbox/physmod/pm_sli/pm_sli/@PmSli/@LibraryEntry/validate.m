function valid=validate(hObj)









    if~hObj.IsValid
        files=which(hObj.Name,'-all');
        fileExists=cellfun(@exist,files)==4;
        if any(fileExists);



            hObj.File=files{find(fileExists,1)};
            hObj.IsValid=true;
        else
            pm_warning('physmod:pm_sli:PmSli:LibraryEntry:InvalidLibraryName',hObj.Name);
        end
    end
    valid=hObj.IsValid;
end
