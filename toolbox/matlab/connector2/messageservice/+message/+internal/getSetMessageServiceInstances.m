
function ms=getSetMessageServiceInstances(msOrName)

    persistent instances;

    if isempty(instances)
        mlock;
        instances=containers.Map;
    end

    if isstring(msOrName)||ischar(msOrName)
        wh=instances(msOrName);
        if wh.isDestroyed()
            prune();
            error('MessageService instance has been destroyed');
        end
        ms=wh.get();
    else
        instances(msOrName.Name)=matlab.internal.WeakHandle(msOrName);
        ms=msOrName;
        prune();
    end

    function prune()

        for name=instances.keys()
            if instances(name{1}).isDestroyed()
                instances=instances.remove(name{1});
            end
        end
    end
end
