function options=extractThreeWayOptions(options)




    if~isa(options,'comparisons.internal.ThreeWayOptions')


        options=options.threeWayOptions;
    end
end
