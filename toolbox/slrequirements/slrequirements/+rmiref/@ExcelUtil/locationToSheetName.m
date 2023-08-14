function[sheet,location]=locationToSheetName(location_string)




    separators=strfind(location_string,'!');
    if~isempty(separators)&&separators(end)>1&&separators(end)<length(location_string)
        sheet=location_string(1:separators(end)-1);
        location=location_string(separators(end)+1:end);
    else
        sheet='';
        location=location_string;
    end
end
