function choiceStr=getPropertyChoiceString(choices)





    len=length(choices);

    if len==1
        choiceStr=sprintf('%s',choices{1});
    else
        choiceStr='';
        for ii=1:len
            aChoiceStr=sprintf('%s',choices{ii});
            if ii==len
                msg=message('hdlcommon:plugin:InvalidPropertyValueOR',aChoiceStr);
                choiceStr=sprintf('%s%s',choiceStr,msg.getString);
            else
                choiceStr=sprintf('%s%s, ',choiceStr,aChoiceStr);
            end
        end
    end

end
