function openDownstream(dependency)




    manager=dependencies.internal.action.dependency.HiliteManager.Instance;
    manager.hilite(dependency.DownstreamNode,dependency,@openDownstream);

end
