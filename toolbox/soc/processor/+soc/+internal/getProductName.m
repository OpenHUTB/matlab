function ret=getProductName(shortname)




    if nargin<1
        shortname=false;
    end

    if shortname
        msgid='soc:utils:ShortName';
    else
        msgid='soc:utils:LongName';
    end
    msg=message(msgid);
    ret=msg.getString();
end


