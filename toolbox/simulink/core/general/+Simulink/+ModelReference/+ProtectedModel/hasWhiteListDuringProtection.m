function out=hasWhiteListDuringProtection(modelName)




    assert(bdIsLoaded(modelName));

    out=false;
    creator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(modelName);
    if~isempty(creator)
        out=~creator.AreAllParameterAccessible();
    end
end
