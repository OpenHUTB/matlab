function checkRestorable(ref,parameter)







    [~,me]=configset.internal.reference.isRestorable(ref,parameter);
    if~isempty(me)
        throw(me);
    end
