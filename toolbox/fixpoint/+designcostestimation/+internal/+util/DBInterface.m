function result=DBInterface(model)





    activeConfigSet=getActiveConfigSet(model);
    if isa(activeConfigSet,'Simulink.ConfigSetRef')
        activeConfigSet=activeConfigSet.getRefConfigSet;
    end
    origGenCodeOnly=get_param(activeConfigSet,'GenCodeOnly');
    set_param(activeConfigSet,'GenCodeOnly','on');
    restoreGenCodeOnly=onCleanup(@()set_param(activeConfigSet,'GenCodeOnly',origGenCodeOnly));

    internal.cgir.Debug.enable;
    x=internal.cgir.Debug;
    x.NodeInfoDatabaseController.Enabled=1;
    x.NodeInfoDatabaseController.Mode='STATIC';
    x.NodeInfoDatabaseController.Operators={'VAR_EXPR','ADD_EXPR','MINUS_EXPR','MULTIPLY_EXPR','DIVISION_EXPR','GREATER_EXPR','GREATER_OR_EQUAL_EXPR','LESS_EXPR','LESS_OR_EQUAL_EXPR','NOT_EQUAL_EXPR','EQUAL_EXPR','SHIFT_LEFT_EXPR','SHIFT_RIGHT_EXPR','SHIFT_RIGHT_ARITHMETIC_EXPR','CONDITIONAL_EXPR','BITWISE_AND_EXPR','BITWISE_NOT_EXPR','BITWISE_OR_EXPR','BITWISE_XOR_EXPR','LOGICAL_AND_EXPR','LOGICAL_NOT_EXPR','LOGICAL_OR_EXPR','MODULO_EXPR','UNARY_MINUS_EXPR','ADD_ASSIGN_EXPR','ASSIGN_EXPR','BITWISE_OR_ASSIGN_EXPR','BITWISE_XOR_ASSIGN_EXPR','DIVIDE_ASSIGN_EXPR','MINUS_ASSIGN_EXPR','MODULO_ASSIGN_EXPR','MULTIPLY_ASSIGN_EXPR','SHIFT_LEFT_ASSIGN_EXPR','SHIFT_RIGHT_ASSIGN_EXPR','SHIFT_RIGHT_LOGICAL_EXPR','MATRIX_MULTIPLY_EXPR','CALL_EXPR','CAST_EXPR','FIXPOINT_CAST_EXPR'};
    x.NodeInfoDatabaseController.Filename='profiling.db';
    x.NodeInfoDatabaseController.TransformRegex='SLCG[.]FinalTagCheck';
    x.NodeInfoDatabaseController.clearNodeInfo

    evalc('rtwgen(model)');
    x.NodeInfoDatabaseController.writeNodeInfo
    internal.cgir.Debug.disable;

    db_connect=matlab.depfun.internal.database.SqlDbConnector;
    dbname='profiling.db';
    db_connect.connect(dbname);

    db_query='select SequenceId,NodeName,NodeValue,NodeExpr,TypeName,Count from NodeCount where NodeValue != ''VAR'';';

    db_connect.doSql(db_query);
    data=db_connect.fetchRows;
    db_connect.disconnect();

    if isempty(data)
        result={};
        return
    end
    result=designcostestimation.internal.util.processResultsFromDB(data,model);
end
