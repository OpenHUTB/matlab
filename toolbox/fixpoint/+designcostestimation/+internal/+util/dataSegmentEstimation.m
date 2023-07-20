function result=dataSegmentEstimation(model)




    activeConfigSet=getActiveConfigSet(model);
    origGenCodeOnly=get_param(activeConfigSet,'GenCodeOnly');
    set_param(activeConfigSet,'GenCodeOnly','on');
    restoreGenCodeOnly=onCleanup(@()set_param(activeConfigSet,'GenCodeOnly',origGenCodeOnly));

    internal.cgir.Debug.enable;
    x=internal.cgir.Debug;
    x.NodeInfoDatabaseController.Enabled=1;
    x.NodeInfoDatabaseController.Mode='STATIC';
    x.NodeInfoDatabaseController.Operators={'VAR_EXPR','DIRECT_MEMBER_REF_EXPR','POINTER_MEMBER_REF_EXPR','STRUCT_MEMBER_REF_EXPR','STRUCT_MEMBER_VAL_EXPR','FIELD_EXPR'};
    x.NodeInfoDatabaseController.Filename='profiling.db';
    x.NodeInfoDatabaseController.TransformRegex='SLCG[.]FinalTagCheck';
    x.NodeInfoDatabaseController.clearNodeInfo

    evalc('rtwgen(model)');
    x.NodeInfoDatabaseController.writeNodeInfo
    internal.cgir.Debug.disable;

    db_connect=matlab.depfun.internal.database.SqlDbConnector;
    dbname='profiling.db';
    db_connect.connect(dbname);

    db_query='select VariableName,Field,GlobalVisibility,StaticLifetime,Size,ifnull(SourceLocation,''''),IsAStruct from FullVariableReport order by VariableName, Field';
    db_connect.doSql(db_query);
    data=db_connect.fetchRows;
    db_connect.disconnect();
    if isempty(data)
        result=table;
        return
    end
    result=designcostestimation.internal.util.processVarsFromDB(data);
    result=cell2table(result,'VariableNames',{'Variable Name','Field','Static Lifetime','Global Visibility','Size','Source Location','Is A Struct'});
end


