function setModelCallbacks(modelH)




    mdlObj=get_param(modelH,'Object');
    if~mdlObj.hasCallback('PreClose','AutosarCloseMdl')
        mdlObj.addCallback('PreClose','AutosarCloseMdl',@()autosarcore.checkCloseMdl());
    end

end
