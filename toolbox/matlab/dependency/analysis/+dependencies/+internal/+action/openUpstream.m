function openUpstream(dependency)
    manager=dependencies.internal.action.dependency.HiliteManager.Instance;
    manager.hilite(dependency.UpstreamNode,dependency,@openUpstream);

end
