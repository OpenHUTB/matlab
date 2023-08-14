function updateConfigurationPreferences(this)





    slRoot=slroot;
    slRootAcs=slRoot.getActiveConfigSet;
    slRootCC=slRootAcs.getComponent(SSC.SimscapeCC.getComponentName);
    if isempty(slRootCC)
        slRootAcs.attachComponent(this.makeCleanCopy);
    end

