function pagequery=getPageQuery(dbProductName)

























    dbProdName=dbProductName;

    sqliteconn=sqlite(fullfile(toolboxdir('database'),'database','+matlab','+io','+datastore','+internal','+jdbcodbc','relationalDBInfo.db'));
    pagequery=fetch(sqliteconn,['SELECT PageQuerySyntax from DBINFO where DatabaseProductName=''',dbProdName,''''],'DataReturnFormat','cellarray');
    close(sqliteconn);

end
