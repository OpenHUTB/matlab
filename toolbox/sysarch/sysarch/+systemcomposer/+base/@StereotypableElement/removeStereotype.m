function removeStereotype(this,stereotypeName)





    try
        systemcomposer.internal.arch.removePrototype(this.getPrototypable,stereotypeName);
    catch ex
        throw(ex);
    end
