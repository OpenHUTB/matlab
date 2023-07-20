function out=getDialogCustomization(cs)











    if~isempty(cs.getModel)&&(bdIsLibrary(cs.getModel)||bdIsSubsystem(cs.getModel))

        out=configset.internal.util.getLibraryDialogCustomization();
    elseif isa(cs,'Simulink.ConfigSetRef')

        out=configset.internal.util.getConfigSetRefCustomization();
    else
        out=configset.internal.util.getPlatformCustomization(cs);
    end
