function validatePropertyValue(value,propertyName,choices)




    if~iscell(value)

        if any(strcmpi(value,choices))
            return;
        end
        notMatchValue=value;
    else

        allMatch=true;
        for ii=1:length(value)
            aValue=value{ii};
            if~any(strcmpi(aValue,choices))
                allMatch=false;
                break;
            end
        end
        if allMatch
            return;
        end
        notMatchValue=aValue;
    end

    len=length(choices);
    if len==1
        choiceStr=choices{1};
    else
        choiceStr='';
        for ii=1:len
            aChoice=choices{ii};
            if ii==len
                msg=message('hdlcommon:plugin:InvalidPropertyValueOR',aChoice);
                choiceStr=sprintf('%s%s',choiceStr,msg.getString);
            else
                choiceStr=sprintf('%s%s, ',choiceStr,aChoice);
            end
        end
    end

    error(message('hdlcommon:plugin:InvalidPropertyValue',...
    notMatchValue,propertyName,choiceStr));

end