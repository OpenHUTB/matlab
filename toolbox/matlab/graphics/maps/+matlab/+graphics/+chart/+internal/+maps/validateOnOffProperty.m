function tf=validateOnOffProperty(name,value)





    validClasses={'char','string','numeric','logical'};
    if isempty(value)||(~ischar(value)&&~isscalar(value))

        validateattributes(value,validClasses,{'nonempty','scalar'},'',name);
    end
    try
        onOff=matlab.lang.OnOffSwitchState(value);
        tf=logical(onOff);
    catch

        if ischar(value)||isstring(value)

            validatestring(value,{'on','off'},'',name);
        else

            validateattributes(value,validClasses,{'finite','real'},'',name);
        end
    end
end
