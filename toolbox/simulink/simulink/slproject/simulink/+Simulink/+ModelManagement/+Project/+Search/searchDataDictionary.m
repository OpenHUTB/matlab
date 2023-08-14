function searchDataDictionary(searchData,token)




    queries=[...
    Simulink.ModelManagement.Project.Search.EntryNameQuery,...
    Simulink.ModelManagement.Project.Search.EntryValueQuery
    ];

    Simulink.ModelManagement.Project.Search.search(searchData,queries,token);

end

