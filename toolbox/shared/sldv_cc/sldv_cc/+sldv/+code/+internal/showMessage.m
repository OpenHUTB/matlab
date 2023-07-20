



function showMessage(testcomp,criticity,msgId,varargin)

    msg=message(msgId,varargin{:});
    sldv.code.internal.showString(testcomp,criticity,msg.getString());


