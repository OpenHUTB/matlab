function runPostEMLHDLCodeGenTasks(topScriptName,topFcnName)







    try
        tbGen=emlhdlcoder.Driver.PostCodeGenDriver(topFcnName,topScriptName);
        tbGen.doIt;
    catch me
        disp('Error occurred when running post codegeneration tasks');
        rethrow(me);
    end

end
