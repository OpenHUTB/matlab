function showPrototypeHierarchy(prototype)

    if~isempty(prototype.parent)
        internal.systemcomposer.showPrototypeHierarchy(prototype.parent);
        disp('     ^');
    end
    disp(prototype.fullyQualifiedName);
