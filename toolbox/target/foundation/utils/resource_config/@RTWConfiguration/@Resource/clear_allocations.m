function clear_allocations(resource)













    old=resource.allocations;
    resource.allocations=RTWConfiguration.Terminator;
    old.delete;


