function jTable=getForwardingTable(jLibrary)




    jTable=java.util.HashMap;

    libraryPath=char(jLibrary.getPath());
    [~,library]=fileparts(libraryPath);
    if~bdIsLoaded(library)
        load_system(libraryPath);
    end

    table=get_param(library,'ForwardingTable');
    for k=1:numel(table)
        jTable.put(java.lang.String(table{k}{1}),java.lang.String(table{k}{2}));
    end
end

