function search(searchData,searchQueries,token)




    file=char(searchData.getResult.getAbsolutePath);
    queries={searchQueries.ValueQuery;searchQueries.PathQuery};

    results=cell(size(queries));
    [results{:}]=Simulink.loadsave.findAll(file,queries{:});

    for n=1:length(results)
        [values,paths]=results{:,n};
        searchQueries(n).addResults(searchData,token,values{1},paths{1});
    end

end