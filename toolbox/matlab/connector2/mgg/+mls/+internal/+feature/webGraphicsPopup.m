function value=webGraphicsPopup(value)







    mlock;
    persistent webGraphicsPopupOn;

    if isempty(webGraphicsPopupOn)
        webGraphicsPopupOn=false;
    end

    webGraphicsStatus=mls.internal.feature('webGraphics');
    if strcmp(value,'on')...
        &&strcmp(webGraphicsStatus,'on')...
        &&~webGraphicsPopupOn
        webGraphicsPopupOn=true;

    elseif strcmp(value,'off')==1
        webGraphicsPopupOn=false;

    else

        if webGraphicsPopupOn
            value='on';
        else
            value='off';
        end
    end
end
