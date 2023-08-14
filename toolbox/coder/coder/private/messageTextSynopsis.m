function msgText=messageTextSynopsis(message)



    msgText='';
    instring=false;
    for i=1:numel(message.MsgText)
        c=message.MsgText(i);
        switch c
        case newline
            return;
        case ''''
            instring=~instring;
            msgText(i)=c;
        otherwise
            msgText(i)=c;
            if c=='.'&&~instring
                if i==1||msgText(i-1)==' '
                    continue;
                end
                if i+1<=numel(message.MsgText)&&message.MsgText(i+1)~=' '
                    continue;
                end
                return;
            end
        end
    end

