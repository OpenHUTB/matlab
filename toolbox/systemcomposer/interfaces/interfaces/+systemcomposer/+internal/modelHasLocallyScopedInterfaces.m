function flag=modelHasLocallyScopedInterfaces(bdH)



    mf0Model=get_param(bdH,'SystemComposerMF0Model');
    pic=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
    if(pic.isEmpty())
        flag=false;
    else
        flag=true;
    end

end
