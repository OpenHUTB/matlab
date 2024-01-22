function retVal=ssr2xls(ssrFileName)
    import si.utilities.*
    [cmd,args,classpath]=launchCommand("ssr2xls");
    setenv("CLASSPATH",classpath)
    cmdArgs=[cmd,args,ssrFileName];
    pb=java.lang.ProcessBuilder(cmdArgs);
    proc=pb.start;
    proc.waitFor;
    retVal=proc.exitValue;
end

