
function prefStruct=getPrefOptions(appVariant)
    if nargin<1
        appVariant='sdi';
    end
    prefStruct=Simulink.sdi.getViewPreferences(appVariant);
end