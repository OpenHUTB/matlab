function checkOverridable(ref,parameter)







    [~,me]=configset.internal.reference.isOverridable(ref,parameter);
    if~isempty(me)
        throw(me);
    end
