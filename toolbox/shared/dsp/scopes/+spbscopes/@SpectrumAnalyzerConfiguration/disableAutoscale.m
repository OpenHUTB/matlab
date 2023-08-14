function disableAutoscale(obj)







    if~isLaunched(obj.Scope)
        setScopeParamOnConfig(obj.Scope,'Tools','Plot Navigation','OnceAtStop','bool',false);
        setScopeParamOnConfig(obj.Scope,'Tools','Plot Navigation','AutoscaleMode','string','Manual');
    end
end
