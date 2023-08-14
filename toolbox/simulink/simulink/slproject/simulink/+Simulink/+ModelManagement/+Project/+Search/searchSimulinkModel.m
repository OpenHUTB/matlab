function searchSimulinkModel(searchData,token)




    queries=[...
    Simulink.ModelManagement.Project.Search.BlockQuery,...
    Simulink.ModelManagement.Project.Search.AnnotationQuery
    ];

    Simulink.ModelManagement.Project.Search.search(searchData,queries,token);

end

