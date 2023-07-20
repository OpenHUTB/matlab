function fcns=getOrderedFunctions(bd)
    schedule=get_param(bd,'Schedule');
    order=schedule.Order;
    fcns=order.Partition;
end