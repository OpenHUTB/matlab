






function InitModel(aObj)

    try

        slci.internal.initSFSimFolder(aObj.getModelName());
    catch ME
        DAStudio.error('Slci:slci:ErrorInitModelOnInspect',aObj.getModelName());
    end

end
