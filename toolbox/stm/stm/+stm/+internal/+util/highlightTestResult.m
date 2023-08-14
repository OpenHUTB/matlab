function highlightTestResult(rsltID)



    callback=@()stm.internal.highlightTestResult(rsltID);
    sltest.internal.invokeFunctionAfterWindowRenders(callback);
end
