function ret=getContextMenuEnabled(obj,menu,param)





    ret.enabled=true;
    ret.reason='';

    fromDialog=true;
    switch menu
    case 'override'
        csref=obj.Source.getConfigSetRoot;
        [ret.enabled,me]=configset.internal.reference.isOverridable(csref,param,fromDialog);
        if~isempty(me)
            ret.reason=me.message;
        end
    case 'restore'
        csref=obj.Source.getConfigSetRoot;
        [ret.enabled,me]=configset.internal.reference.isRestorable(csref,param,fromDialog);
        if~isempty(me)
            ret.reason=me.message;
        end
    end
