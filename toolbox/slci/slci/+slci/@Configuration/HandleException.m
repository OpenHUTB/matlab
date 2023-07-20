




function HandleException(aObj,varargin)
    if(nargin==2)
        aException=varargin{1};
        errorStr=DAStudio.message('Slci:ui:Error');
    elseif(nargin==3)
        aException=varargin{1};
        aReason=varargin{2};
        errorStr=message(aReason);
    end
    if aObj.fViaGUI
        slci.internal.outputMessage(aException,'error');
    else
        if ischar(aException)
            disp([errorStr,': ',aException]);
        else
            if(nargin==3)
                msg=message(aReason,aException.message).getString;
                disp(msg);
            else
                disp([errorStr,': ',aException.message]);
            end
            for p=1:numel(aException.cause)
                exCause=aException.cause{p};
                aObj.HandleException(exCause);
            end
        end
    end
end
