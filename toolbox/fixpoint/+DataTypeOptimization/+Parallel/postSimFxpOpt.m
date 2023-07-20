function newSimOut=postSimFxpOpt(simOut,objectiveFunction,solution,baselineSimOut,options,userPostSimFcn)








    userFunctionErrorDiag=[];

    if~isempty(userPostSimFcn)
        try
            try




                newSimOut=userPostSimFcn(simOut);
            catch
                userPostSimFcn(simOut);
            end
        catch userFunctionErrorDiag
        end
    end


    newSimOut.pass=false;
    newSimOut.maxDifferences=Inf;
    newSimOut.simOut=simOut;
    newSimOut.cost=Inf;
    newSimOut.float_pass=double(newSimOut.pass);
    baselineRunID=[];
    newRunID=[];




    if isempty(simOut.ErrorMessage)&&isempty(userFunctionErrorDiag)






        baselineRunID=Simulink.sdi.createRun(baselineSimOut.SimulationMetadata.UserString,'vars',baselineSimOut);
        if~isempty(baselineRunID)

            newRunID=Simulink.sdi.createRun(simOut.SimulationMetadata.UserString,'vars',simOut);

            baselineComparisonUtil=DataTypeOptimization.SDIBaselineComparison();



            baselineComparisonUtil.bindConstraints(baselineRunID,options.Constraints.values);


            [pass,maxDifferences]=baselineComparisonUtil.evaluateConstraints(baselineRunID,newRunID);


            newSimOut.pass=pass;
            newSimOut.float_pass=double(newSimOut.pass);
            newSimOut.maxDifferences=maxDifferences;
        else


            newSimOut.pass=true;
            newSimOut.float_pass=double(newSimOut.pass);
            newSimOut.maxDifferences=0;
        end

        if~isempty(objectiveFunction)
            newSimOut.cost=objectiveFunction.measure(solution);
        end

    elseif~isempty(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic)&&...
        isequal(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic.identifier,'Simulink:blocks:AssertionAssert')&&...
        ~isempty(objectiveFunction)



        newSimOut.cost=objectiveFunction.measure(solution);

    end


    newSimOut.baselineRunID=baselineRunID;


    newSimOut.newRunID=newRunID;

    if~isempty(userFunctionErrorDiag)

        newSimOut.UserFunctionErrorDiagnostic=userFunctionErrorDiag;
    end

    if options.AdvancedOptions.ClearSDIOnEval
        Simulink.sdi.clear();
    end
end