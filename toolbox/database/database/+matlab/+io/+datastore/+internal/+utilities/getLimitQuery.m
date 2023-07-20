function limitquery=getLimitQuery(dbProductName)
























    dbProdName=char(dbProductName);

    sqliteconn=sqlite(fullfile(toolboxdir('database'),'database','+matlab','+io','+datastore','+internal','+jdbcodbc','relationalDBInfo.db'));
    limitquery=fetch(sqliteconn,['SELECT LimitQuerySyntax from DBINFO where DatabaseProductName=''',dbProdName,''''],'DataReturnFormat','cellarray');
    close(sqliteconn);

end


