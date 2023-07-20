


function SimulinkTest(filename)
    callback=@()loadFile(filename);
    sltest.internal.invokeFunctionAfterWindowRenders(callback);
end

function loadFile(filename)

    desc=matlabshared.mldatx.internal.getDescription(filename);
    if strcmp(desc,message('stm:general:ResultFileDescription').getString())
        sltest.testmanager.importResults(filename);
    else
        sltest.testmanager.load(filename);
    end
end
