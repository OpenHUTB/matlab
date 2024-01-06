function client=initializeDiagramMarkupClient(clientName)

    mlock;
    persistent persistentClient;
    if isempty(persistentClient)
        persistentClient=diagram.markup.getClient(clientName);
    end

    client=persistentClient;
end
