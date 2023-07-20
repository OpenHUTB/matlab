



function result=feature_FMU2CSExport()

    result=(license('test','Simulink_Compiler')>0)&&~isempty(ver('simulinkcompiler'));
end
