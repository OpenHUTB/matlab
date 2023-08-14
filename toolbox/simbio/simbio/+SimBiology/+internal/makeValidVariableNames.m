function varNames=makeValidVariableNames(varNames)








    tfValid=cellfun(@isvarname,varNames);
    varNamesReordered=[varNames(tfValid),varNames(~tfValid)];
    varNamesReordered=matlab.internal.tabular.makeValidVariableNames(varNamesReordered,'silent');
    nValid=sum(tfValid);
    varNames(tfValid)=varNamesReordered(1:nValid);
    varNames(~tfValid)=varNamesReordered(nValid+1:end);
end