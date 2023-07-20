function allSame=homogenousMarkups(markups)

    allSame=true;
    if~isempty(markups)
        name=markups(1).clientName;
        for(i=2:length(markups))
            if~strcmp(name,markups(i).clientName)
                allSame=false;
                break;
            end
        end
    end