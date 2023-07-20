function[messageStr,qualifiedId]=message(id,varargin)



    validateattributes(id,{'char'},{});
    qualifiedId=['Coder:FxpConvDisp:FXPCONVDISP:',id];

    messageObj=message(qualifiedId,varargin{:});
    messageStr=messageObj.getString();
end