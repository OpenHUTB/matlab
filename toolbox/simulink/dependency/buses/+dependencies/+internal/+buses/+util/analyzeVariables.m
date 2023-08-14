function deps=analyzeVariables(varsOfTypeFcn,busNode,fileNode,baseType)








    import dependencies.internal.buses.util.analyzeBusObjects;
    import dependencies.internal.buses.util.analyzeBusElementObjects;
    import dependencies.internal.buses.util.analyzeSignalObjects;
    import dependencies.internal.buses.util.analyzeBusStructs;

    deps=dependencies.internal.graph.Dependency.empty;

    buses=varsOfTypeFcn('Simulink.Bus');
    if~isempty(buses)
        deps=[deps,analyzeBusObjects(busNode,fileNode,buses,baseType)];
    end

    bus_elements=varsOfTypeFcn('Simulink.BusElement');
    if~isempty(bus_elements)
        deps=[deps,analyzeBusElementObjects(busNode,fileNode,bus_elements,baseType)];
    end

    signals=varsOfTypeFcn('Simulink.Signal');
    if~isempty(signals)
        deps=[deps,analyzeSignalObjects(busNode,fileNode,signals,baseType)];
    end

    structs=varsOfTypeFcn('struct');
    if~isempty(structs)
        deps=[deps,analyzeBusStructs(busNode,fileNode,structs,baseType)];
    end
end
