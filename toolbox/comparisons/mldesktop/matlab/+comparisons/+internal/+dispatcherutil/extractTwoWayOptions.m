function options=extractTwoWayOptions(options)




    if~isa(options,'comparisons.internal.TwoWayOptions')







        options=options.twoWayOptions;
    end
end
