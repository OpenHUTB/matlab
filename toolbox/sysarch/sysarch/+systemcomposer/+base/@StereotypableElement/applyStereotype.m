function applyStereotype(this,stereotypeName)





    try
        systemcomposer.profile.Stereotype.find(stereotypeName);
        systemcomposer.internal.arch.applyPrototype(this.getPrototypable,stereotypeName);
    catch ex
        throw(ex);
    end
end