function ret=is_auto_allocation(allocation)















    ret=~isempty(allocation.realloc_callback);
