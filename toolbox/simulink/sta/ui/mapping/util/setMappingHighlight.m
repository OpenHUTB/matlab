function setMappingHighlight(portH,status)





















    highlight='none';
    for kHandle=1:length(portH)

        switch status
        case 0
            highlight='error';
        case 1
            highlight='none';
        case 2
            highlight='reqHere';
        end

        hilite_system(portH,highlight);
    end
end
