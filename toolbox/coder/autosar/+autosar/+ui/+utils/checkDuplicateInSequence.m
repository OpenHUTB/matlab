



function isValid=checkDuplicateInSequence(listObjs,propValue)
    isValid=true;
    for i=1:listObjs.size
        if strcmp(propValue,listObjs.at(i).Name)
            isValid=false;
            break;
        end
    end
end
