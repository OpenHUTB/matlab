function filteredPorts=filterPortSelectionQuery(ports,portQuery)









    if isempty(portQuery)
        filteredPorts=ports;
        return;
    end

    if isempty(ports)
        filteredPorts=ports;
        return;
    end

    constraint=systemcomposer.query.Constraint.createFromString(portQuery);
    portsThatSatisfy=arrayfun(@(p)constraint.isSatisfied(systemcomposer.arch.ComponentPort(p)),ports);
    filteredPorts=ports(portsThatSatisfy);

end
