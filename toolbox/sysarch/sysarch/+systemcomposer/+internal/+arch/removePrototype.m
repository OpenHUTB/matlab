function removePrototype(elem,prototypeName)









    if(isa(elem,'systemcomposer.architecture.model.design.BaseComponent'))
        elem=elem.getArchitecture;
    end
    elem.removePrototype(prototypeName);
