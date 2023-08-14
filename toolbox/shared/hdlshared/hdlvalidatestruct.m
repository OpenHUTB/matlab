function v=hdlvalidatestruct(status,msg,msgid)













    if nargin==0
        status=0;
        msgtxt='';
        msgid='';
    elseif nargin==2
        msgtxt=msg.getString;
        msgid=msg.Identifier;
    else
        msgtxt=msg;
    end

    v=struct('Status',status,'Message',msgtxt,'MessageID',msgid);
