function tv2slsv_Out=tv2slsv(tv2slsv_Inp)








    if isempty(tv2slsv_Inp)
        tv2slsv_Out=[];
        return;
    end

    if isa(tv2slsv_Inp,'Simulink.Simulation.Variable')
        tv2slsv_Out=tv2slsv_Inp;
        return;
    end


    for tv2slsv_Idx=1:numel(tv2slsv_Inp)
        eval(tv2slsv_Inp(tv2slsv_Idx).QualifiedName...
        +"= tv2slsv_Inp(tv2slsv_Idx).Value;");
    end
    tv2slsv_VarNames=setdiff(string(who),["tv2slsv_Inp","tv2slsv_Idx"]);


    for tv2slsv_Idx=1:numel(tv2slsv_VarNames)
        eval("tv2slsv_VarValue = "+tv2slsv_VarNames(tv2slsv_Idx)+";");

        tv2slsv_Out(tv2slsv_Idx)=...
        Simulink.Simulation.Variable(...
        tv2slsv_VarNames(tv2slsv_Idx),...
        tv2slsv_VarValue,...
        'Workspace',tv2slsv_Inp(tv2slsv_Idx).Workspace);%#ok<AGROW>
    end
end
