function lGenSettings_out=infoMATGenSettings(lGenSettings_in)






mlock
    persistent lGenSettings

    if nargin==1
        lGenSettings=lGenSettings_in;
    else
        lGenSettings_out=lGenSettings;
    end
