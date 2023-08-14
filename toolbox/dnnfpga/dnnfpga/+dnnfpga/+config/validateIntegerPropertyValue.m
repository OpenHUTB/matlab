function validateIntegerPropertyValue(value,propertyName,choices)





    len=length(choices);


    for ii=1:len
        aChoice=choices{ii};
        if isequal(value,aChoice)
            return;
        end
    end

    notMatchValueStr=sprintf('%d',value);

    if len==1
        choiceStr=sprintf('%d',choices{1});
    else
        choiceStr='';
        for ii=1:len
            aChoiceStr=sprintf('%d',choices{ii});
            if ii==len
                msg=message('hdlcommon:plugin:InvalidPropertyValueOR',aChoiceStr);
                choiceStr=sprintf('%s%s',choiceStr,msg.getString);
            else
                choiceStr=sprintf('%s%s, ',choiceStr,aChoiceStr);
            end
        end
    end

    error(message('hdlcommon:plugin:InvalidPropertyValue',...
    notMatchValueStr,propertyName,choiceStr));

end
