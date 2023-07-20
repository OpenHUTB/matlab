function isABC=isAbstractBaseClass(this,implementationName)








    isABC=any(strcmpi(this.abstractClasses,implementationName));