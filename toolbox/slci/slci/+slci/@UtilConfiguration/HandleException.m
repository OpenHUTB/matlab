

function HandleException(aObj,aException)
    errorStr=DAStudio.message('Slci:ui:Error');
    if ischar(aException)
        disp([errorStr,': ',aException]);
    else
        disp([errorStr,': ',aException.message]);
        for p=1:numel(aException.cause)
            exCause=aException.cause{p};
            aObj.HandleException(exCause);
        end
    end
end
