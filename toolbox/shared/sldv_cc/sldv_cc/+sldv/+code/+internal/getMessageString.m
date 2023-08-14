



function msgStr=getMessageString(productName,msgId,varargin)
    if isempty(productName)
        productName='Simulink Design Verifier';
    end
    msg=message(msgId,varargin{:});
    msgStr=msg.getString();
    msgStr=strrep(msgStr,'$PRODUCT$',productName);
