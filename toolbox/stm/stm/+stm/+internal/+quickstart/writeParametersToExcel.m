function prCnt=writeParametersToExcel(paramSetID,spreadSheet,sheetName)




    ps=sltest.testmanager.ParameterSet(paramSetID);


    ids=stm.internal.getParameterOverrides(ps.getID,true);
    prCnt=numel(ids);
    ids=ids(:).';


    pOvrObjs=sltest.internal.Helper.getParameterOverride(ids);


    variables(1:length(pOvrObjs))=arrayfun(@getVariable,pOvrObjs);


    wt=xls.internal.WriteTable('Parameters',variables,'File',spreadSheet,...
    'sheet',sheetName,'Simulation',ps.SimIndex);
    wt.write;
end

function vr=getVariable(param)

    args={};


    if param.SourceType=="mask workspace"
        args=["Workspace",param.Source];
    elseif strlength(param.Workspace)>0
        args=["Workspace",param.Workspace];
    end
    vr=Simulink.Simulation.Variable(param.Name,param.Value,args{:});
end
